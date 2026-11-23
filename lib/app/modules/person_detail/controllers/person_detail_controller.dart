import 'dart:async';

import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/person_day.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/modules/scan/controllers/scan_controller.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';

/// One person of the team with everything known about their day.
@injectable
class PersonDetailController extends GetxController {
  PersonDetailController(this.appService, @factoryParam this.matricule);

  final AppService appService;
  final String matricule;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final person = Rxn<Person>();
  final state = Rxn<DayState>();

  /// Where the person works today: what they were clocked in on, or what the
  /// planning proposes.
  final assignment = Rxn<Assignment>();

  /// When the face was enrolled, when the server says.
  final enrolDate = Rxn<DateTime>();

  /// Anomalies reported about this person today.
  final anomalies = <Declaration>[].obs;

  StreamSubscription<void>? _changes;

  @override
  void onInit() {
    super.onInit();
    load();
    // Refresh when a clock-in is saved from another screen.
    _changes = appService.changes.listen((_) => load());
  }

  Future<void> load() => pageState.run(() async {
    final today = DateTime.now();
    final dateKey = AttendanceRules.dateKey(today);
    final nowMinute = AttendanceRules.minuteOfDay(today);

    final schedule = await appService.getSchedule();
    final team = await appService.getTeam();
    final enrolled = await appService.getEnrolledMatricules();
    final declarations = await appService.getDeclarations(dateKey);

    anomalies.assignAll(
      declarations.where(
        (d) => d.matricule == matricule && d.kind == DeclarationKind.anomaly,
      ),
    );

    final found = team.where((p) => p.matricule == matricule).firstOrNull;
    person.value = found;
    if (found != null) {
      final records = await appService.getPersonRecords(found);
      state.value = AttendanceRules.dayState(
        matricule: matricule,
        dateKey: dateKey,
        records: records,
        declarations: declarations,
        enrolled: enrolled.contains(matricule),
        shift: schedule.shiftAt(nowMinute),
        toleranceMinutes: schedule.toleranceMinutes,
        nowMinute: nowMinute,
        isToday: true,
      );
      enrolDate.value = (await appService.getEnrolmentDates())[matricule];
      assignment.value = await _assignmentOf(found, state.value!);
    }
  });

  Future<Assignment?> _assignmentOf(Person found, DayState day) async {
    final clocked = day.arrival?.assignment;
    if (clocked != null) return clocked;
    try {
      return await appService.getAssignmentFor(found);
    } on ApiException {
      // Only informative: the sheet works without it.
      return null;
    }
  }

  /// The last 14 days of this person.
  Future<List<PersonDay>> loadHistory() {
    final found = person.value;
    if (found == null) return Future.value(const []);
    return appService.getPersonHistory(found, 14);
  }

  /// Clocks this person: the face is checked against them only.
  void openScan() => Get.toNamed(
        Routes.SCAN,
        arguments: ScanArgs(mode: ScanMode.team, matricule: matricule),
      );

  void openEnrolment() => Get.toNamed(Routes.FACE_ENROL, arguments: matricule);

  @override
  void onClose() {
    _changes?.cancel();
    super.onClose();
  }
}
