import 'dart:async';

import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/modules/clock_done/controllers/clock_done_controller.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

/// A person the supervisor can clock in or out by hand.
class ManualCandidate {
  const ManualCandidate(this.person, this.state);

  final Person person;
  final DayState state;

  /// Someone already inside is clocked out, otherwise clocked in.
  ClockKind get kind => state.isInside ? ClockKind.exit : ClockKind.arrival;
}

/// How the manual clock-in is opened.
class ManualClockArgs {
  const ManualClockArgs({required this.mode, this.matricule});

  final ScanMode mode;

  /// Person already chosen (opened from their detail screen).
  final String? matricule;
}

/// Manual clock-in: person, reason and a proof photo.
@injectable
class ManualClockController extends GetxController {
  ManualClockController(this.appService, @factoryParam this._args);

  final AppService appService;
  final ManualClockArgs _args;

  ScanMode get mode => _args.mode;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final saving = false.obs;
  final sector = Rxn<Sector>();
  final shift = Rxn<Shift>();
  final now = DateTime.now().obs;

  final candidates = <ManualCandidate>[].obs;
  final selected = Rxn<ManualCandidate>();
  final reason = RxnString();

  /// Choices of `motifs.manuel`.
  final reasons = <String>[].obs;

  /// Path (blob URL on the web) of the proof photo.
  final photoPath = RxnString();

  /// What is missing after a tap on the confirm button (shown in red).
  final personMissing = false.obs;
  final reasonMissing = false.obs;
  final photoMissing = false.obs;

  final _picker = ImagePicker();
  Timer? _clock;

  @override
  void onInit() {
    super.onInit();
    load();
    // The time on the confirm button.
    _clock = Timer.periodic(
      const Duration(seconds: 15),
      (_) => now.value = DateTime.now(),
    );
  }

  Future<void> load() => pageState.run(() async {
    final today = DateTime.now();
    final dateKey = AttendanceRules.dateKey(today);
    final nowMinute = AttendanceRules.minuteOfDay(today);

    final results = await Future.wait<Object>([
      appService.getSector(),
      appService.getSchedule(),
      appService.getTeam(),
      appService.getEnrolledMatricules(),
      appService.getRecords(dateKey),
      appService.getDeclarations(dateKey),
    ]);
    final schedule = results[1] as ScheduleConfig;
    final team = results[2] as List<Person>;
    final enrolled = results[3] as Set<String>;
    final records = results[4] as List<AttendanceRecord>;
    final declarations = results[5] as List<Declaration>;
    final currentShift = schedule.shiftAt(nowMinute);

    reasons.assignAll((await appService.getMotifs()).manual);
    sector.value = results[0] as Sector;
    shift.value = currentShift;
    now.value = today;

    final all =
        [
            for (final p in team)
              // The supervisor only clocks themself in with the front camera mode.
              if (p.isSupervisor == (mode == ScanMode.self))
                ManualCandidate(
                  p,
                  AttendanceRules.dayState(
                    matricule: p.matricule,
                    dateKey: dateKey,
                    records: records,
                    declarations: declarations,
                    enrolled: enrolled.contains(p.matricule),
                    shift: currentShift,
                    toleranceMinutes: schedule.toleranceMinutes,
                    nowMinute: nowMinute,
                    isToday: true,
                  ),
                ),
          ]
          // People already out for the day have nothing left to clock.
          ..removeWhere((c) => c.state.exit != null)
          ..sort((a, b) {
            final byRank = a.state.sortRank.compareTo(b.state.sortRank);
            return byRank != 0
                ? byRank
                : a.person.name.compareTo(b.person.name);
          });

    candidates.assignAll(all);
    if (mode == ScanMode.self && all.isNotEmpty) {
      selected.value = all.first;
    } else if (_args.matricule != null) {
      selected.value = all
          .where((c) => c.person.matricule == _args.matricule)
          .firstOrNull;
    }
  });

  void selectPerson(ManualCandidate candidate) {
    selected.value = candidate;
    personMissing.value = false;
  }

  /// Selecting the reason again clears it.
  void selectReason(String value) {
    reason.value = reason.value == value ? null : value;
    if (reason.value != null) reasonMissing.value = false;
  }

  Future<void> takePhoto(String errorMessage) async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: mode == ScanMode.self
            ? CameraDevice.front
            : CameraDevice.rear,
        maxWidth: 1280,
        imageQuality: 75,
      );
      if (photo != null) {
        photoPath.value = photo.path;
        photoMissing.value = false;
      }
    } catch (_) {
      showAppToast(errorMessage);
    }
  }

  void removePhoto() => photoPath.value = null;

  Future<void> confirm() async {
    if (saving.value) return;

    final candidate = selected.value;
    final chosenReason = reason.value;
    final photo = photoPath.value;

    // Say what is missing instead of silently doing nothing.
    personMissing.value = candidate == null;
    reasonMissing.value = chosenReason == null;
    photoMissing.value = photo == null;
    if (candidate == null || chosenReason == null || photo == null) return;

    saving.value = true;
    try {
      final today = DateTime.now();
      final Assignment assignment = candidate.kind == ClockKind.exit
          ? candidate.state.arrival!.assignment
          : await appService.getAssignmentFor(candidate.person);

      final saved = await appService.saveRecord(
        AttendanceRecord(
          id: const Uuid().v4(),
          matricule: candidate.person.matricule,
          dateKey: AttendanceRules.dateKey(today),
          kind: candidate.kind,
          minute: AttendanceRules.minuteOfDay(today),
          method: ClockMethod.manual,
          inZone: true,
          assignment: assignment,
          manualReason: chosenReason,
          photoPath: photo,
        ),
      );

      Get.offNamed(
        Routes.CLOCK_DONE,
        arguments: ClockDoneArgs(
          person: candidate.person,
          kind: saved.kind,
          minute: saved.minute,
          method: ClockMethod.manual,
          assignment: assignment,
          pending: false,
          mode: mode,
        ),
      );
    } on ApiException catch (e) {
      showAppToast(e.message);
    } finally {
      saving.value = false;
    }
  }

  void close() => Get.back<void>();

  @override
  void onClose() {
    _clock?.cancel();
    super.onClose();
  }
}
