import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/data/face/head_turn_liveness.dart';
import 'package:casa_pointage/app/data/models/kiosk_result.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/app/services/auth_service.dart';
import 'package:casa_pointage/app/services/kiosk_service.dart';

enum KioskPhase { loading, detect, analyse, live, sending, done, failed }

/// The only screen of a kiosk account: look at the camera, turn the head, and
/// the pointage is sent as soon as the face is recognised.
@injectable
class KioskController extends GetxController {
  KioskController(this._service, this._analyzer, this.authService);

  /// Frames kept as good in a row before the next step.
  static const _framesToDetect = 4;
  static const _framesToAnalyse = 5;

  /// Time to turn the head before the attempt is given up.
  static const _liveTimeout = Duration(seconds: 15);

  /// How long the result, or the failure, stays on the screen.
  static const _resultTime = Duration(seconds: 4);
  static const _failureTime = Duration(milliseconds: 2500);

  /// After a pointage the camera waits for the person to leave, so they are
  /// not pointed twice; it waits at most this long.
  static const _leaveTimeout = Duration(seconds: 15);

  /// Templates are downloaded again when the last copy is older than this.
  static const _templatesMaxAge = Duration(minutes: 10);

  final KioskService _service;
  final FaceFrameAnalyzer _analyzer;
  final AuthService authService;

  final phase = KioskPhase.loading.obs;
  final hint = FaceHint.none.obs;
  final liveStep = HeadTurnStep.firstSide.obs;
  final result = Rxn<KioskResult>();

  /// Text of the server when the pointage was refused; empty means "face not
  /// recognised".
  final failureMessage = ''.obs;

  /// Faces known for the dépôt; `-1` until the first download ends.
  final knownFaces = (-1).obs;

  /// Text of the server when the templates could not be downloaded.
  final loadError = ''.obs;

  final lens = CameraLensDirection.front.obs;

  final _liveness = HeadTurnLiveness();
  final _clockStart = Stopwatch();
  Timer? _liveTimer;
  Timer? _restartTimer;
  DateTime? _templatesAt;
  DateTime? _leftAt;
  bool _scanning = false;
  bool _busy = false;
  bool _waitForLeave = false;
  int _goodFrames = 0;

  /// Places of the kiosk, shown under the title.
  String get depots => authService.supervisor.value?.depots.join(' · ') ?? '';

  @override
  void onInit() {
    super.onInit();
    _load().whenComplete(startScan);
    unawaited(_service.warmUpLocation());
  }

  /// Downloads the faces of the dépôt, at the start and every few minutes.
  Future<void> _load() async {
    try {
      knownFaces.value = await _service.prepare();
      loadError.value = '';
      _templatesAt = DateTime.now();
    } on ApiException catch (e) {
      loadError.value = e.message;
    } on Object catch (e) {
      debugPrint('[KIOSK] templates: $e');
    }
  }

  void startScan() {
    _liveTimer?.cancel();
    _restartTimer?.cancel();
    result.value = null;
    failureMessage.value = '';
    hint.value = FaceHint.none;
    liveStep.value = HeadTurnStep.firstSide;
    _liveness.reset();
    _goodFrames = 0;
    _clockStart
      ..reset()
      ..start();
    phase.value = KioskPhase.detect;
    _scanning = true;

    final at = _templatesAt;
    if (at == null || DateTime.now().difference(at) > _templatesMaxAge) {
      unawaited(_load());
    }
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
      case KioskPhase.detect:
        if (_waitForLeave) {
          final since = _leftAt;
          final gone = reading.face == null;
          final tooLong =
              since != null && DateTime.now().difference(since) > _leaveTimeout;
          if (!gone && !tooLong) return;
          _waitForLeave = false;
        }
        _goodFrames = reading.ok ? _goodFrames + 1 : 0;
        if (_goodFrames >= _framesToDetect) {
          _goodFrames = 0;
          phase.value = KioskPhase.analyse;
        }
      case KioskPhase.analyse:
        if (!reading.ok) {
          _goodFrames = 0;
          phase.value = KioskPhase.detect;
          return;
        }
        if (++_goodFrames >= _framesToAnalyse) {
          _goodFrames = 0;
          _liveness.reset();
          liveStep.value = HeadTurnStep.firstSide;
          phase.value = KioskPhase.live;
          _liveTimer = Timer(_liveTimeout, () {
            if (phase.value == KioskPhase.live) _fail('');
          });
        }
      case KioskPhase.live:
        // The turn is read whatever the other hints say: a turned head is
        // "not straight" by design.
        liveStep.value = _liveness.feed(
          _clockStart.elapsed,
          yaw: reading.face?.yaw,
        );
        if (_liveness.passed && reading.ok) await _recognize(reading);
      case KioskPhase.loading:
      case KioskPhase.sending:
      case KioskPhase.done:
      case KioskPhase.failed:
        break;
    }
  }

  Future<void> _recognize(FaceReading reading) async {
    _scanning = false;
    _liveTimer?.cancel();
    phase.value = KioskPhase.sending;
    try {
      final template = await _analyzer.templateOf(reading);
      final match = await _service.identify(template);
      if (match == null) return _fail('');

      final saved = await _service.clockIn(match);
      result.value = saved;
      phase.value = KioskPhase.done;
      _waitForLeave = true;
      _leftAt = DateTime.now();
      _restartTimer = Timer(_resultTime, startScan);
    } on ApiException catch (e) {
      // There is no manual pointage on a kiosk: do not send people to it.
      _fail(e.message.toLowerCase().contains('pointage manuel') ? '' : e.message);
    } on Object catch (e) {
      debugPrint('[KIOSK] $e');
      _fail('');
    }
  }

  void _fail(String message) {
    _scanning = false;
    _liveTimer?.cancel();
    failureMessage.value = message;
    phase.value = KioskPhase.failed;
    _restartTimer = Timer(_failureTime, startScan);
  }

  void flipCamera() => lens.value = lens.value == CameraLensDirection.back
      ? CameraLensDirection.front
      : CameraLensDirection.back;

  Future<void> logout() async {
    _scanning = false;
    await authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    _scanning = false;
    _liveTimer?.cancel();
    _restartTimer?.cancel();
    super.onClose();
  }
}
