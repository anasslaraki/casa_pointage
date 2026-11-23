import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../data/models/absence_type.dart';
import '../data/models/assignment.dart';
import '../data/models/attendance_record.dart';
import '../data/models/declaration.dart';
import '../data/models/person.dart';
import '../data/models/person_day.dart';
import '../data/models/schedule.dart';
import '../data/models/sector.dart';
import '../data/models/team_page.dart';
import '../data/repo/face_template_repo.dart';
import '../data/repo/team_repo.dart';

/// What the controllers call for the team, the attendance and the reference
/// data. Each method goes to the repo, which goes to the remote datasource.
@lazySingleton
class AppService {
  AppService(this.teamRepo, this.faceTemplateRepo);

  final TeamRepo teamRepo;
  final FaceTemplateRepo faceTemplateRepo;

  /// Emits whenever attendance data changed, so open screens can refresh.
  Stream<void> get changes => teamRepo.changes;

  Future<Sector> getSector() => teamRepo.getSector();

  Future<ScheduleConfig> getSchedule() => teamRepo.getSchedule();

  /// The whole team, including the supervisor.
  Future<List<Person>> getTeam() => teamRepo.getTeam();

  /// Matricules of people whose face is enrolled.
  Future<Set<String>> getEnrolledMatricules() =>
      teamRepo.getEnrolledMatricules();

  Future<List<AttendanceRecord>> getRecords(String dateKey) =>
      teamRepo.getRecords(dateKey);

  Future<List<Declaration>> getDeclarations(String dateKey) =>
      teamRepo.getDeclarations(dateKey);

  Future<Map<String, DateTime>> getEnrolmentDates() =>
      teamRepo.getEnrolmentDates();

  Future<TeamPage> getTeamPage({
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) =>
      teamRepo.getTeamPage(
        filter: filter,
        search: search,
        page: page,
        pageSize: pageSize,
      );

  Future<HistoryPage> getHistoryPage({
    required String dateKey,
    String? filter,
    int page = 1,
    int pageSize = 10,
  }) =>
      teamRepo.getHistoryPage(
        dateKey: dateKey,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

  Future<List<AttendanceRecord>> getPersonRecords(Person person) =>
      teamRepo.getPersonRecords(person);

  Future<List<PersonDay>> getPersonHistory(Person person, int days) =>
      teamRepo.getPersonHistory(person, days);

  Future<Motifs> getMotifs() => teamRepo.getMotifs();

  Future<List<AbsenceType>> getAbsenceTypes() => teamRepo.getAbsenceTypes();

  /// Sends the face template of [person] and refreshes the enrolment state.
  Future<void> saveEnrolment(
    Person person,
    Float32List template,
    double quality,
  ) async {
    await faceTemplateRepo.enrol(
      agentId: person.agentId,
      matricule: person.matricule,
      template: template,
      quality: quality,
    );
    teamRepo.refresh();
  }

  Future<Assignment> getAssignmentFor(Person person) =>
      teamRepo.getAssignmentFor(person);

  Future<AssignmentOptions> getAssignmentOptions(AssignmentKind kind) =>
      teamRepo.getAssignmentOptions(kind);

  /// The returned record is what the server registered (arrival or departure).
  Future<AttendanceRecord> saveRecord(AttendanceRecord record) =>
      teamRepo.saveRecord(record);

  Future<void> saveDeclaration(Declaration declaration) =>
      teamRepo.saveDeclaration(declaration);

  /// Loads everything again from the server on every open screen.
  void refresh() => teamRepo.refresh();

  Future<void> syncPending() => teamRepo.syncPending();
}
