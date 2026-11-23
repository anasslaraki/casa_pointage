import 'package:flutter_test/flutter_test.dart';

import 'package:casa_pointage/app/data/api/location_service.dart';
import 'package:casa_pointage/app/data/datasources/remote/repos/remote_team_repo.dart';
import 'package:casa_pointage/app/data/repo/team_repo.dart';

Json _agent(int id, String matricule, String name, {bool late = false}) => {
      'agentId': id,
      'matricule': matricule,
      'fullName': name,
      'fonction': 'Balayeur',
      'estSuperviseur': false,
      'circuit': 'ASBBM0902',
      'heureDebutPoste': '2026-10-27T07:00:00',
      'heureFinPoste': '2026-10-27T14:00:00',
      'enRetard': late,
      'retardMinutes': late ? 15 : 0,
      'heureEntree': '2026-10-27T07:15:00',
      'heureSortie': null,
      'methodeEntree': 'Visage',
      'typeAbsence': null,
      'enrole': true,
      'dateEnrolement': '2026-10-27T15:13:51.4159279',
    };

/// An `/equipe` that gives one agent per page, whatever size is asked, and the
/// supervisor apart in `moi`.
class _FakeRemote implements RemoteTeamRepo {
  final people = [
    _agent(23, 'M23', 'Ali Test', late: true),
    _agent(24, 'M24', 'Bilal Test'),
    _agent(25, 'M25', 'Chadi Test'),
  ];

  int equipeCalls = 0;

  @override
  Future<Json> getEquipe(
    String dateKey, {
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 50,
  }) async {
    equipeCalls++;
    return {
      'date': dateKey,
      'secteur': 'Belvédère',
      'compteurs': {
        'tous': 4,
        'pointes': 3,
        'nonPointes': 1,
        'presents': 3,
        'retards': 1,
        'absents': 0,
        'sortis': 0,
        'nonEnroles': 1,
      },
      'moi': {
        'agentId': 20,
        'matricule': 'S20',
        'fullName': 'Hassan Idrissi',
        'fonction': 'Superviseur',
        'heureEntree': '2026-10-27T06:55:00',
        'enrole': true,
      },
      'page': page,
      'pageSize': 1,
      'total': people.length,
      'totalPages': people.length,
      'agents': [people[page - 1]],
    };
  }

  @override
  Future<Json> getHistory({
    required String toDateKey,
    required int days,
    int? agentId,
    String? filter,
    int page = 1,
    int pageSize = 50,
  }) async {
    return {
      'page': page,
      'pageSize': pageSize,
      'total': 12,
      'totalPages': 2,
      'lignes': [
        {
          'date': '${toDateKey}T00:00:00',
          'agentId': 23,
          'matricule': 'M23',
          'fullName': 'Ali Test',
          'statut': 'Present',
          'heureEntree': '${toDateKey}T07:02:00',
          'enRetard': true,
          'retardMinutes': 12,
          'typeAbsence': null,
        },
      ],
    };
  }

  @override
  Future<Json> getDay({required int agentId, required String dateKey}) async => {
        'entree': {'motifRetard': 'Panne de bus'},
      };

  @override
  Future<Json> getProfile() async => {
        'secteur': 'Belvédère',
        'delegataire': 'SOS',
        'depots': [
          {'id': 304, 'libelle': 'BELVEDERE'},
        ],
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _today() {
  final t = DateTime.now();
  return '${t.year}-${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}

void main() {
  test('the whole team is read page after page, supervisor included', () async {
    final remote = _FakeRemote();
    final repo = TeamRepoImpl(remote, LocationService());

    final team = await repo.getTeam();
    expect(team.length, 4); // three pages of one, plus the supervisor (moi)
    expect(team.where((p) => p.isSupervisor).single.matricule, 'S20');
    expect(remote.equipeCalls, 3);

    expect(await repo.getEnrolledMatricules(), {'M23', 'M24', 'M25', 'S20'});
    expect((await repo.getEnrolmentDates())['M23']?.day, 27);
    final records = await repo.getRecords(_today());
    expect(records.firstWhere((r) => r.matricule == 'M23').lateMinutes, 15);
    expect((await repo.getSector()).depotName, 'BELVEDERE');
    expect((await repo.getSchedule()).shifts.single.startMinute, 420);
  });

  test('a team page has its people, the supervisor apart, counters and pages',
      () async {
    final repo = TeamRepoImpl(_FakeRemote(), LocationService());

    final page = await repo.getTeamPage(page: 2, pageSize: 1);
    expect(page.people.single.matricule, 'M24');
    expect(page.me?.matricule, 'S20');
    expect(page.counters.all, 4);
    expect(page.counters.late, 1);
    expect(page.counters.notEnrolled, 1);
    expect(page.info.page, 2);
    expect(page.info.totalPages, 3);
    expect(page.info.firstItem, 2);
    expect(page.info.lastItem, 2);
    // What is needed to show the supervisor's card.
    expect(page.records.any((r) => r.matricule == 'S20'), isTrue);
    expect(page.enrolled.contains('S20'), isTrue);
  });

  test('a history page keeps the lateness and the page position', () async {
    final repo = TeamRepoImpl(_FakeRemote(), LocationService());

    final page = await repo.getHistoryPage(dateKey: _today(), page: 1);
    expect(page.rows.single.arrivalMinute, 422);
    expect(page.rows.single.lateMinutes, 12);
    expect(page.info.total, 12);
    expect(page.info.totalPages, 2);
  });

  test('the sheet of a person adds the late reason', () async {
    final repo = TeamRepoImpl(_FakeRemote(), LocationService());

    final ali = (await repo.getTeam()).firstWhere((p) => p.matricule == 'M23');
    final mine = await repo.getPersonRecords(ali);
    expect(mine.single.lateReason, 'Panne de bus');
  });
}
