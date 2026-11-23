import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/face/head_turn_liveness.dart';
import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/data/models/face_match.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/modules/clock_done/controllers/clock_done_controller.dart';
import 'package:casa_pointage/app/modules/manual_clock/controllers/manual_clock_controller.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

enum ScanPhase { detect, analyse, live, matched, failed }

/// A recognized person waiting for the supervisor's confirmation.
class ScanResult {
  const ScanResult({
    required this.person,
    required this.score,
    required this.kind,
    required this.assignment,
    required this.isLate,
    required this.lateMinutes,
    this.lateReason,
  });

  final Person person;
  final int score;
  final ClockKind kind;
  final Assignment assignment;

  /// Arriving after the shift start + tolerance.
  final bool isLate;
  final int lateMinutes;
  final String? lateReason;

  ScanResult copyWith({Assignment? assignment, String? lateReason}) =>
      ScanResult(
        person: person,
        score: score,
        kind: kind,
        assignment: assignment ?? this.assignment,
        isLate: isLate,
        lateMinutes: lateMinutes,
        lateReason: lateReason ?? this.lateReason,
      );

  ScanResult withoutLateReason() => ScanResult(
        person: person,
        score: score,
        kind: kind,
        assignment: assignment,
        isLate: isLate,
        lateMinutes: lateMinutes,
      );
}

/// How the scan screen is opened: who is clocked in, and with which camera.
class ScanArgs {
  const ScanArgs({required this.mode, this.matricule});

  final ScanMode mode;

  /// Verify the face against this person only (their sheet); `null` identifies
  /// the person among the team.
  final String? matricule;
}

@injectable
class ScanController extends GetxController {
  ScanController(
    this.appService,
    this._recognizer,
    this._analyzer,
    @factoryParam this.mode,
    @factoryParam this.matricule,
  );

  /// Frames kept as good in a row before the next step.
  static const _framesToDetect = 4;
  static const _framesToAnalyse = 5;

  /// Time to turn the head before the scan is given up.
  static const _liveTimeout = Duration(seconds: 15);

  final AppService appService;
  final FaceRecognizer _recognizer;
  final FaceFrameAnalyzer _analyzer;
  final ScanMode mode;
  final String? matricule;

  final phase = ScanPhase.detect.obs;
  final result = Rxn<ScanResult>();
  final saving = false.obs;

  /// Where the head turn is, to tell the user what to do.
  final liveStep = HeadTurnStep.firstSide.obs;

  /// What is wrong with the frame, while the face is being found.
  final hint = FaceHint.none.obs;

  /// Camera in use: back for the team, front for the supervisor.
  late final lens = (mode == ScanMode.self
          ? CameraLensDirection.front
          : CameraLensDirection.back)
      .obs;

  final sector = Rxn<Sector>();

  /// Choices of `motifs.retard`.
  final lateReasons = <String>[].obs;
  final shift = Rxn<Shift>();
  final now = DateTime.now().obs;

  ScheduleConfig? _schedule;
  Timer? _clock;
  Timer? _liveTimer;

  final _liveness = HeadTurnLiveness();
  final _clockStart = Stopwatch();
  Future<void> _prepared = Future.value();
  bool _scanning = false;
  bool _busy = false;
  int _goodFrames = 0;

  @override
  void onInit() {
    super.onInit();
    _loadContext();
    _clock = Timer.periodic(
      const Duration(seconds: 15),
      (_) => now.value = DateTime.now(),
    );
    startScan();
  }

  Future<void> _loadContext() async {
    sector.value = await appService.getSector();
    _schedule = await appService.getSchedule();
    shift.value = _schedule!.shiftAt(AttendanceRules.minuteOfDay(DateTime.now()));
    lateReasons.assignAll((await appService.getMotifs()).lateness);
  }

  /// Starts (or restarts) the scan: find a good face, hold still, turn the head, then
  /// recognise the face.
  void startScan() {
    _liveTimer?.cancel();
    result.value = null;
    phase.value = ScanPhase.detect;
    hint.value = FaceHint.none;
    _goodFrames = 0;
    _liveness.reset();
    liveStep.value = HeadTurnStep.firstSide;
    _clockStart
      ..reset()
      ..start();
    _scanning = true;
    // Templates of the team, from the server or from the phone.
    _prepared = _recognizer.prepare().catchError((Object _) {});
  }

  /// One camera frame. Frames are dropped while the previous one is analysed.
  void onFrame(CameraImage image, CameraDescription camera) {
    if (!_scanning || _busy) return;
    _busy = true;
    _process(image, camera).whenComplete(() => _busy = false);
  }

  Future<void> _process(CameraImage image, CameraDescription camera) async {
    final reading = await _analyzer.analyze(image, camera);
    if (!_scanning) return;
    hint.value = reading.hint;

    switch (phase.value) {
      case ScanPhase.detect:
        _goodFrames = reading.ok ? _goodFrames + 1 : 0;
        if (_goodFrames >= _framesToDetect) {
          _goodFrames = 0;
          phase.value = ScanPhase.analyse;
        }
      case ScanPhase.analyse:
        if (!reading.ok) {
          _goodFrames = 0;
          phase.value = ScanPhase.detect;
          return;
        }
        if (++_goodFrames >= _framesToAnalyse) {
          _goodFrames = 0;
          _liveness.reset();
          liveStep.value = HeadTurnStep.firstSide;
          phase.value = ScanPhase.live;
          _liveTimer = Timer(_liveTimeout, _giveUp);
        }
      case ScanPhase.live:
        // The turn is read whatever the other hints say: a turned head is
        // "not straight" by design.
        liveStep.value = _liveness.feed(
          _clockStart.elapsed,
          yaw: reading.face?.yaw,
        );
        if (_liveness.passed && reading.ok) await _recognize(reading);
      case ScanPhase.matched:
      case ScanPhase.failed:
        break;
    }
  }

  void _giveUp() {
    if (phase.value != ScanPhase.live) return;
    _scanning = false;
    phase.value = ScanPhase.failed;
  }

  Future<void> _recognize(FaceReading reading) async {
    _scanning = false;
    _liveTimer?.cancel();
    try {
      final template = await _analyzer.templateOf(reading);
      await _prepared;
      final match = await _recognizer.recognize(
        template,
        mode: mode,
        matricule: matricule,
      );
      if (match == null) {
        phase.value = ScanPhase.failed;
        return;
      }
      await _showResult(match);
    } on Object catch (e) {
      debugPrint('[FACE] $e');
      phase.value = ScanPhase.failed;
    }
  }

  Future<void> _showResult(FaceMatch match) async {
    final schedule = _schedule ?? await appService.getSchedule();
    final today = DateTime.now();
    final dateKey = AttendanceRules.dateKey(today);
    final nowMinute = AttendanceRules.minuteOfDay(today);
    final currentShift = schedule.shiftAt(nowMinute);

    final state = AttendanceRules.dayState(
      matricule: match.person.matricule,
      dateKey: dateKey,
      records: await appService.getRecords(dateKey),
      declarations: await appService.getDeclarations(dateKey),
      enrolled: true,
      shift: currentShift,
      toleranceMinutes: schedule.toleranceMinutes,
      nowMinute: nowMinute,
      isToday: true,
    );

    // Someone already inside is being clocked out, otherwise clocked in.
    final leaving = state.isInside;
    final assignment = leaving
        ? state.arrival!.assignment
        : await appService.getAssignmentFor(match.person);
    final late = !leaving &&
        nowMinute > currentShift.startMinute + schedule.toleranceMinutes;

    shift.value = currentShift;
    result.value = ScanResult(
      person: match.person,
      score: match.score,
      kind: leaving ? ClockKind.exit : ClockKind.arrival,
      assignment: assignment,
      isLate: late,
      lateMinutes: late ? nowMinute - currentShift.startMinute : 0,
    );
    phase.value = ScanPhase.matched;
  }

  void flipCamera() => lens.value = lens.value == CameraLensDirection.back
      ? CameraLensDirection.front
      : CameraLensDirection.back;

  /// Selects the lateness reason; selecting it again clears it (it is optional).
  void selectLateReason(String reason) {
    final current = result.value;
    if (current == null) return;
    result.value = current.lateReason == reason
        ? current.withoutLateReason()
        : current.copyWith(lateReason: reason);
  }

  void changeAssignment(Assignment assignment) {
    final current = result.value;
    if (current == null) return;
    result.value = current.copyWith(assignment: assignment);
  }

  Future<void> confirm() async {
    final current = result.value;
    if (current == null || saving.value) return;
    saving.value = true;

    try {
      final today = DateTime.now();
      // The server decides between arrival and departure: use what it returns.
      final saved = await appService.saveRecord(
        AttendanceRecord(
          id: const Uuid().v4(),
          matricule: current.person.matricule,
          dateKey: AttendanceRules.dateKey(today),
          kind: current.kind,
          minute: AttendanceRules.minuteOfDay(today),
          method: ClockMethod.face,
          score: current.score,
          inZone: true,
          assignment: current.assignment,
          lateReason: current.lateReason,
        ),
      );

      Get.offNamed(
        Routes.CLOCK_DONE,
        arguments: ClockDoneArgs(
          person: current.person,
          kind: saved.kind,
          minute: saved.minute,
          method: ClockMethod.face,
          assignment: current.assignment,
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

  /// Replaces the scan by the manual clock-in of the same mode.
  void openManual() => Get.offNamed(
        Routes.MANUAL_CLOCK,
        arguments: ManualClockArgs(mode: mode),
      );

  void close() => Get.back<void>();

  @override
  void onClose() {
    _scanning = false;
    _liveTimer?.cancel();
    _clock?.cancel();
    super.onClose();
  }
}
