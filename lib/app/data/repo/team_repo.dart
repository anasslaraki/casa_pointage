import 'dart:async';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../api/api_exception.dart';
import '../api/location_service.dart';
import '../datasources/remote/repos/remote_team_repo.dart';
import '../utils/attendance_rules.dart';

import 'package:casa_pointage/app/data/models/absence_type.dart';
import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/person_day.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/data/models/team_page.dart';

/// The reasons the supervisor can pick, as written by `GET /motifs` (absence
/// reasons come from `GET /types-absence`).
class Motifs {
  const Motifs({
    this.lateness = const [],
    this.anomaly = const [],
    this.manual = const [],
  });

  final List<String> lateness;
  final List<String> anomaly;
  final List<String> manual;
}

/// Reference data and attendance of the supervisor's sector.
///
/// Write methods throw an `ApiException` whose message is meant for the user.
abstract class TeamRepo {
  Future<Sector> getSector();
  Future<ScheduleConfig> getSchedule();

  /// The whole team, including the supervisor.
  Future<List<Person>> getTeam();

  /// Matricules of people whose face is enrolled.
  Future<Set<String>> getEnrolledMatricules();

  Future<List<AttendanceRecord>> getRecords(String dateKey);
  Future<List<Declaration>> getDeclarations(String dateKey);

  /// One page of the team for the Équipe tab: [filter] is the `filtre` of the
  /// API, [search] a part of the name, matricule or function.
  Future<TeamPage> getTeamPage({
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 10,
  });

  /// One page of everyone's clock-ins on [dateKey] (`yyyy-MM-dd`).
  Future<HistoryPage> getHistoryPage({
    required String dateKey,
    String? filter,
    int page = 1,
    int pageSize = 10,
  });

  /// Today's clock-ins of one person, with the reasons given (late, manual).
  Future<List<AttendanceRecord>> getPersonRecords(Person person);

  /// The last [days] days of one person, most recent first.
  Future<List<PersonDay>> getPersonHistory(Person person, int days);

  /// When each enrolled person was enrolled, by matricule (when the server says).
  Future<Map<String, DateTime>> getEnrolmentDates();

  /// Reasons for lateness, anomalies and manual clock-ins.
  Future<Motifs> getMotifs();

  /// Reasons of an absence declaration.
  Future<List<AbsenceType>> getAbsenceTypes();

  /// Today's assignment of a person, from the planning module.
  Future<Assignment> getAssignmentFor(Person person);

  /// Values the supervisor can choose when changing an assignment.
  Future<AssignmentOptions> getAssignmentOptions(AssignmentKind kind);

  /// Sends a clock-in/out. The server decides whether it is an arrival or a
  /// departure: the returned record is what it registered.
  Future<AttendanceRecord> saveRecord(AttendanceRecord record);

  /// Sends everything stored on the phone to the HR module.
  Future<void> syncPending();

  /// Sends an absence or anomaly declaration.
  Future<void> saveDeclaration(Declaration declaration);

  /// Forgets what was loaded from the server and tells the open screens to
  /// load it again.
  void refresh();

  /// Drops the cached data (login of another supervisor, logout).
  void reset();

  /// Emits whenever attendance data changed, so open screens can refresh.
  Stream<void> get changes;
}

class _Snapshot {
  _Snapshot(this.json) : fetchedAt = DateTime.now();

  final Json json;
  final DateTime fetchedAt;

  List<Json> get agents => [
        for (final a in (json['agents'] as List? ?? const []))
          if (a is Map) a.cast<String, dynamic>(),
      ];
}

/// [TeamRepo] on the Pointage API. `GET /equipe` is the source of the team,
/// the attendance and the enrolment state; it is cached for a short time and
/// dropped after every write.
@LazySingleton(as: TeamRepo)
class TeamRepoImpl implements TeamRepo {
  TeamRepoImpl(this._remote, this._location);

  final RemoteTeamRepo _remote;
  final LocationService _location;

  /// Lateness tolerance until the API gives it. TODO(lateness): the real value
  /// is wanted with the face recognition work; the server already flags
  /// `enRetard`, which wins when present.
  static const _toleranceMinutes = 10;

  static const _todayTtl = Duration(seconds: 20);
  static const _pastTtl = Duration(minutes: 10);

  final _snapshots = <String, _Snapshot>{};
  final _inFlight = <String, Future<_Snapshot>>{};
  final _changes = StreamController<void>.broadcast();

  Future<Json>? _profile;
  Future<Motifs>? _motifs;
  Future<List<AbsenceType>>? _absenceTypes;
  Future<List<Json>>? _circuits;
  Future<List<Json>>? _vehicles;
  Future<List<Json>>? _carts;

  /// Assignment proposed by the server per matricule (to send only changes).
  final _proposed = <String, Assignment>{};

  @override
  Stream<void> get changes => _changes.stream;

  @override
  void refresh() {
    _snapshots.clear();
    _profile = _motifs = _circuits = _vehicles = _carts = null;
    _absenceTypes = null;
    _changes.add(null);
  }

  @override
  void reset() {
    _snapshots.clear();
    _inFlight.clear();
    _profile = _motifs = _circuits = _vehicles = _carts = null;
    _absenceTypes = null;
    _proposed.clear();
  }

  // ---- reads ----

  Future<_Snapshot> _equipe(String dateKey) {
    final cached = _snapshots[dateKey];
    final today = AttendanceRules.dateKey(DateTime.now());
    final ttl = dateKey == today ? _todayTtl : _pastTtl;
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < ttl) {
      return Future.value(cached);
    }
    // Several controllers load together: share the call.
    // The callback must not return the removed future: whenComplete would wait
    // for the future it belongs to and never finish.
    return _inFlight[dateKey] ??= _fetchEquipe(dateKey).whenComplete(() {
      _inFlight.remove(dateKey);
    });
  }

  /// The whole team of a day: every page of `GET /equipe`, plus the
  /// supervisor's own card (`moi`) when it is not among them.
  Future<_Snapshot> _fetchEquipe(String dateKey) async {
    final first = await _remote.getEquipe(dateKey, pageSize: 200);
    final agents = _agentsOf(first);
    final pages = (first['totalPages'] as num?)?.toInt() ?? 1;
    for (var page = 2; page <= pages; page++) {
      agents.addAll(
        _agentsOf(await _remote.getEquipe(dateKey, page: page, pageSize: 200)),
      );
    }
    final moi = _moiOf(first);
    if (moi != null && !agents.any((a) => a['agentId'] == moi['agentId'])) {
      agents.add(moi);
    }
    final snapshot = _Snapshot({...first, 'agents': agents});
    _snapshots[dateKey] = snapshot;
    return snapshot;
  }

  static List<Json> _agentsOf(Json json) => [
        for (final a in (json['agents'] as List? ?? const []))
          if (a is Map) a.cast<String, dynamic>(),
      ];

  /// The supervisor's own card, marked as such.
  static Json? _moiOf(Json json) {
    final moi = json['moi'];
    if (moi is! Map) return null;
    return {...moi.cast<String, dynamic>(), 'estSuperviseur': true};
  }

  Future<_Snapshot> get _today =>
      _equipe(AttendanceRules.dateKey(DateTime.now()));

  Future<Json> _loadProfile() => _profile ??= _remote.getProfile().catchError((
    Object e,
  ) {
    _profile = null;
    throw e;
  });

  @override
  Future<Sector> getSector() async {
    final profile = await _loadProfile();
    final depots = profile['depots'] as List? ?? const [];
    return Sector(
      name: '${profile['secteur'] ?? ''}',
      delegate: '${profile['delegataire'] ?? ''}',
      depotName: depots.isEmpty ? '' : '${(depots.first as Map)['libelle']}',
    );
  }

  @override
  Future<ScheduleConfig> getSchedule() async {
    final agents = (await _today).agents;
    final spans = <(int, int)>{};
    for (final a in agents) {
      final start = _minuteOf(a['heureDebutPoste']);
      var end = _minuteOf(a['heureFinPoste']);
      if (start == null || end == null) continue;
      if (end <= start) end += 1440;
      spans.add((start, end));
    }
    final sorted = spans.toList()..sort((a, b) => a.$1.compareTo(b.$1));
    if (sorted.isEmpty) sorted.add((420, 840));
    return ScheduleConfig(
      toleranceMinutes: _toleranceMinutes,
      shifts: [
        for (final s in sorted)
          Shift(
            kind: s.$1 < 720
                ? ShiftKind.morning
                : s.$1 < 1080
                    ? ShiftKind.afternoon
                    : ShiftKind.night,
            startMinute: s.$1,
            endMinute: s.$2,
          ),
      ],
    );
  }

  @override
  Future<List<Person>> getTeam() async => [
        for (final a in (await _today).agents) _personOf(a),
      ];

  @override
  Future<Set<String>> getEnrolledMatricules() async => {
        for (final a in (await _today).agents)
          if (a['enrole'] == true) '${a['matricule']}',
      };

  @override
  Future<Map<String, DateTime>> getEnrolmentDates() async => {
        for (final a in (await _today).agents)
          if (DateTime.tryParse('${a['dateEnrolement'] ?? ''}')
              case final date?)
            '${a['matricule']}': date,
      };

  @override
  Future<List<AttendanceRecord>> getRecords(String dateKey) async =>
      _recordsOf((await _equipe(dateKey)).agents, dateKey);

  List<AttendanceRecord> _recordsOf(List<Json> agents, String dateKey) {
    final records = <AttendanceRecord>[];
    for (final a in agents) {
      final person = _personOf(a);
      final entree = _minuteOf(a['heureEntree']);
      if (entree == null) continue;
      final method = a['methodeEntree'] == 'Manuel'
          ? ClockMethod.manual
          : ClockMethod.face;
      final assignment = _assignmentOf(person, a['circuit']);

      records.add(
        AttendanceRecord(
          id: 'in-${person.agentId}-$dateKey',
          matricule: person.matricule,
          dateKey: dateKey,
          kind: ClockKind.arrival,
          minute: entree,
          method: method,
          inZone: true,
          assignment: assignment,
          isLate: a['enRetard'] == true,
          lateMinutes: (a['retardMinutes'] as num?)?.toInt() ?? 0,
        ),
      );
      final sortie = _minuteOf(a['heureSortie']);
      if (sortie != null) {
        records.add(
          AttendanceRecord(
            id: 'out-${person.agentId}-$dateKey',
            matricule: person.matricule,
            dateKey: dateKey,
            kind: ClockKind.exit,
            minute: sortie,
            method: method,
            inZone: true,
            assignment: assignment,
          ),
        );
      }
    }
    return records;
  }

  @override
  Future<List<Declaration>> getDeclarations(String dateKey) async =>
      _declarationsOf((await _equipe(dateKey)).agents, dateKey);

  List<Declaration> _declarationsOf(List<Json> agents, String dateKey) => [
        for (final a in agents)
          if (a['typeAbsence'] != null)
            Declaration(
              id: 'abs-${a['agentId']}-$dateKey',
              matricule: '${a['matricule']}',
              kind: DeclarationKind.absence,
              absenceReason: '${a['typeAbsence']}',
              fromDateKey: dateKey,
              toDateKey: dateKey,
            ),
      ];

  @override
  Future<TeamPage> getTeamPage({
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final dateKey = AttendanceRules.dateKey(DateTime.now());
    final json = await _remote.getEquipe(
      dateKey,
      filter: filter,
      search: search,
      page: page,
      pageSize: pageSize,
    );

    final agents = _agentsOf(json);
    final others = [
      for (final a in agents)
        if (a['estSuperviseur'] != true) a,
    ];
    final me = _moiOf(json) ??
        agents.where((a) => a['estSuperviseur'] == true).firstOrNull;
    final everyone = [...others, ?me];

    return TeamPage(
      people: [for (final a in others) _personOf(a)],
      me: me == null ? null : _personOf(me),
      records: _recordsOf(everyone, dateKey),
      declarations: _declarationsOf(everyone, dateKey),
      enrolled: {
        for (final a in everyone)
          if (a['enrole'] == true) '${a['matricule']}',
      },
      counters: TeamCounters.of(
        (json['compteurs'] as Map?)?.cast<String, dynamic>(),
      ),
      info: PageInfo.of(json, fallbackTotal: others.length),
    );
  }

  @override
  Future<HistoryPage> getHistoryPage({
    required String dateKey,
    String? filter,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json = await _remote.getHistory(
      toDateKey: dateKey,
      days: 1,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
    final rows = _daysOf(json);
    return HistoryPage(
      rows: rows,
      info: PageInfo.of(json, fallbackTotal: rows.length),
    );
  }

  @override
  Future<List<AttendanceRecord>> getPersonRecords(Person person) async {
    final dateKey = AttendanceRules.dateKey(DateTime.now());
    final records = [
      for (final r in await getRecords(dateKey))
        if (r.matricule == person.matricule) r,
    ];
    if (records.isEmpty) return records;

    try {
      final day = await _remote.getDay(agentId: person.agentId, dateKey: dateKey);
      final entree = day['entree'] is Map ? day['entree'] as Map : const {};
      final late = _text(entree['motifRetard']);
      final manual = _text(entree['motifManuel']);
      return [
        for (final r in records)
          r.kind == ClockKind.arrival
              ? r.copyWith(lateReason: late, manualReason: manual)
              : r,
      ];
    } on SessionExpired {
      rethrow;
    } on ApiException {
      // The sheet still shows what /equipe knows.
      return records;
    }
  }

  @override
  Future<List<PersonDay>> getPersonHistory(Person person, int days) async {
    final json = await _remote.getHistory(
      toDateKey: AttendanceRules.dateKey(DateTime.now()),
      days: days,
      agentId: person.agentId,
    );
    final rows = _daysOf(json);
    rows.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return rows;
  }

  /// The lines of a `GET /historique` answer.
  List<PersonDay> _daysOf(Json json) {
    final rows = <PersonDay>[];
    for (final l in (json['lignes'] as List? ?? const [])) {
      if (l is! Map) continue;
      final line = l.cast<String, dynamic>();
      final arrival = _minuteOf(line['heureEntree']);
      final PersonDayKind kind;
      if ('${line['statut']}' == 'Repos') {
        kind = PersonDayKind.rest;
      } else if (arrival != null) {
        kind = PersonDayKind.worked;
      } else if (line['typeAbsence'] != null) {
        kind = PersonDayKind.absent;
      } else {
        kind = PersonDayKind.missing;
      }
      rows.add(
        PersonDay(
          dateKey: '${line['date']}'.split('T').first,
          kind: kind,
          matricule: '${line['matricule'] ?? ''}',
          name: '${line['fullName'] ?? ''}',
          circuit: _label(line['circuit']),
          arrivalMinute: arrival,
          exitMinute: _minuteOf(line['heureSortie']),
          isLate: line['enRetard'] == true,
          lateMinutes: (line['retardMinutes'] as num?)?.toInt() ?? 0,
          manual: line['methodeEntree'] == 'Manuel' ||
              line['methodeSortie'] == 'Manuel',
        ),
      );
    }
    return rows;
  }

  static String? _text(Object? value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Future<Motifs> getMotifs() => _motifs ??= _remote.getMotifs().then((m) {
        return Motifs(
          lateness: _labels(m['retard']),
          anomaly: _labels(m['anomalie']),
          manual: _labels(m['manuel']),
        );
      }).catchError((Object e) {
        _motifs = null;
        throw e;
      });

  @override
  Future<List<AbsenceType>> getAbsenceTypes() =>
      _absenceTypes ??= _remote.getAbsenceTypes().then((list) {
        return [
          for (final e in list)
            if (e is Map && e['id'] is num)
              if (_labels([e]) case [final label, ...])
                AbsenceType(id: (e['id'] as num).toInt(), label: label),
        ];
      }).catchError((Object e) {
        _absenceTypes = null;
        throw e;
      });

  @override
  Future<Assignment> getAssignmentFor(Person person) async {
    if (person.isSupervisor) {
      return const Assignment(kind: AssignmentKind.supervision);
    }
    final map = await _remote.getAffectation(
      agentId: person.agentId,
      dateKey: AttendanceRules.dateKey(DateTime.now()),
    );
    final data = map['affectation'] is Map
        ? (map['affectation'] as Map).cast<String, dynamic>()
        : map;
    final assignment = _assignmentOf(
      person,
      data['circuit'],
      vehicle: data['chariot'] ?? data['vehicule'],
    );
    _proposed[person.matricule] = assignment;
    return assignment;
  }

  @override
  Future<AssignmentOptions> getAssignmentOptions(AssignmentKind kind) async {
    final circuits = await (_circuits ??= _remote.getCircuits());
    final List<Json> vehicles;
    if (kind == AssignmentKind.manualSweeping) {
      final depots = (await _loadProfile())['depots'] as List? ?? const [];
      vehicles = await (_carts ??= _remote.getCarts(
        depotId: depots.isEmpty ? null : (depots.first as Map)['id'],
      ));
    } else {
      vehicles = await (_vehicles ??= _remote.getVehicles());
    }
    return AssignmentOptions(
      circuits: [for (final c in circuits) '${c['libelle']}'],
      vehicles: [for (final v in vehicles) '${v['libelle']}'],
    );
  }

  // ---- writes ----

  @override
  Future<AttendanceRecord> saveRecord(AttendanceRecord record) async {
    final person = await _personByMatricule(record.matricule);
    final gps = await _location.current();
    final manual = record.method == ClockMethod.manual;

    final body = <String, dynamic>{
      if (!person.isSupervisor) 'agentId': person.agentId,
      'methode': manual ? 'Manuel' : 'Visage',
      'latitude': gps.latitude,
      'longitude': gps.longitude,
      'precisionMetres': gps.accuracyMeters.round(),
    };
    if (manual) {
      body['motifManuel'] = record.manualReason;
      final path = record.photoPath;
      if (path != null) {
        body['photoBase64'] = base64Encode(await XFile(path).readAsBytes());
      }
    } else {
      if (record.score != null) body['scoreVisage'] = record.score! / 100;
      if (record.lateReason != null) body['motifRetard'] = record.lateReason;
    }
    await _addChangedAssignment(body, record);

    final result = await _remote.postPointage(body);
    _snapshots.clear();
    _changes.add(null);
    return _recordOf(result.data, record);
  }

  /// `circuitId` / `vehiculeId` / `chariotId` are sent only when the
  /// supervisor changed what the server proposed.
  Future<void> _addChangedAssignment(Json body, AttendanceRecord r) async {
    final proposed = _proposed[r.matricule];
    final a = r.assignment;
    if (proposed == null) return;
    if (a.circuit != null && a.circuit != proposed.circuit) {
      final id = await _idOf(_circuits ??= _remote.getCircuits(), a.circuit!);
      if (id != null) body['circuitId'] = id;
    }
    if (a.vehicle != null && a.vehicle != proposed.vehicle) {
      final cart = a.kind == AssignmentKind.manualSweeping;
      final id = await _idOf(
        cart ? (_carts ??= _remote.getCarts()) : (_vehicles ??= _remote.getVehicles()),
        a.vehicle!,
      );
      if (id != null) body[cart ? 'chariotId' : 'vehiculeId'] = id;
    }
  }

  Future<int?> _idOf(Future<List<Json>> list, String label) async {
    for (final e in await list) {
      if ('${e['libelle']}' == label) return (e['id'] as num?)?.toInt();
    }
    return null;
  }

  @override
  Future<void> saveDeclaration(Declaration d) async {
    final person = await _personByMatricule(d.matricule);
    final agent = person.isSupervisor ? null : person.agentId;

    if (d.kind == DeclarationKind.absence) {
      await _remote.postAbsence({
        'agentId': ?agent,
        'typeAbsenceId': d.absenceTypeId,
        'dateDebut': d.fromDateKey,
        'dateFin': d.toDateKey,
      });
    } else {
      await _remote.postDeclaration({
        'agentId': ?agent,
        'motif': d.anomalyKind,
        'date': d.fromDateKey,
        'heureCorrecte': ?d.correctTime,
        'commentaire': d.comment,
        'dateAction': DateTime.now().toUtc().toIso8601String(),
      });
    }
    _snapshots.clear();
    _changes.add(null);
  }

  @override
  Future<void> syncPending() async {
    // Everything is sent at once for now; the offline queue comes later.
    _snapshots.clear();
    _changes.add(null);
  }

  // ---- mapping ----

  Future<Person> _personByMatricule(String matricule) async {
    final team = await getTeam();
    return team.firstWhere(
      (p) => p.matricule == matricule,
      orElse: () => throw const ApiException('Choisissez la personne.'),
    );
  }

  Person _personOf(Json a) {
    final fonction = '${a['fonction'] ?? ''}';
    return Person(
      agentId: (a['agentId'] as num).toInt(),
      matricule: '${a['matricule']}',
      name: '${a['fullName']}',
      fonction: fonction,
      shiftStartMinute: _minuteOf(a['heureDebutPoste']),
      shiftEndMinute: _minuteOf(a['heureFinPoste']),
      function: Person.functionFrom(
        fonction,
        supervisor: a['estSuperviseur'] == true,
      ),
    );
  }

  Assignment _assignmentOf(Person person, Object? circuit, {Object? vehicle}) {
    final kind = switch (person.function) {
      PersonFunction.sweeperMale ||
      PersonFunction.sweeperFemale ||
      PersonFunction.teamLead ||
      PersonFunction.other =>
        AssignmentKind.manualSweeping,
      PersonFunction.sweeperDriver => AssignmentKind.mechanicalSweeping,
      PersonFunction.driver || PersonFunction.loader => AssignmentKind.collection,
      PersonFunction.supervisor => AssignmentKind.supervision,
    };
    return Assignment(
      kind: kind,
      circuit: _label(circuit),
      vehicle: _label(vehicle),
    );
  }

  AttendanceRecord _recordOf(Object? data, AttendanceRecord sent) {
    final d = data is Map ? data.cast<String, dynamic>() : <String, dynamic>{};
    final p = d['pointage'] is Map
        ? (d['pointage'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final when = DateTime.tryParse('${p['datePointage']}') ?? DateTime.now();
    final leaving = '${d['type'] ?? p['type']}' == 'Sortie';
    return AttendanceRecord(
      id: 'p${p['id'] ?? sent.id}',
      matricule: sent.matricule,
      dateKey: AttendanceRules.dateKey(when),
      kind: leaving ? ClockKind.exit : ClockKind.arrival,
      minute: AttendanceRules.minuteOfDay(when),
      method: sent.method,
      inZone: d['auDepot'] != false,
      assignment: sent.assignment,
      score: sent.score,
      lateReason: sent.lateReason,
      manualReason: sent.manualReason,
      photoPath: sent.photoPath,
      isLate: d['enRetard'] == true,
      lateMinutes: (d['retardMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  /// Minutes since midnight of `yyyy-MM-ddTHH:mm:ss` (Moroccan time, no offset).
  static int? _minuteOf(Object? iso) {
    if (iso == null) return null;
    final t = DateTime.tryParse('$iso');
    return t == null ? null : t.hour * 60 + t.minute;
  }

  /// A circuit / cart / vehicle comes as text or as `{ libelle }`.
  static String? _label(Object? value) {
    if (value == null) return null;
    if (value is Map) return value['libelle'] == null ? null : '${value['libelle']}';
    final text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  /// A reason comes as text or as an object with a label.
  static List<String> _labels(Object? list) => [
        for (final e in (list as List? ?? const []))
          if (e is Map)
            '${e['libelle'] ?? e['label'] ?? e['motif'] ?? e['nom'] ?? ''}'
          else
            '$e',
      ].where((s) => s.isNotEmpty).toList();
}
