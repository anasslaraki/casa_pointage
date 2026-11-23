import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/data/face/face_config.dart';
import 'package:casa_pointage/app/data/face/face_math.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

enum EnrolPhase { consent, scan1, mid, scan2, saving, done }

/// Enrolment of one face: the person agrees, then two slow head turns collect
/// templates that are averaged and sent to the HR module.
@injectable
class FaceEnrolController extends GetxController {
  FaceEnrolController(
    this.appService,
    this._analyzer,
    @factoryParam this.matricule,
  );

  /// Templates collected in each of the two scans.
  static const _perScan = FaceConfig.enrolTemplates ~/ 2;

  /// Minimum time between two collected templates, so they differ a little.
  static const _spacing = Duration(milliseconds: 350);

  /// The enrolment accepts a more turned head than the pointage.
  static const _maxAngle = 35.0;

  final AppService appService;
  final FaceFrameAnalyzer _analyzer;
  final String matricule;

  final person = Rxn<Person>();

  /// The delegate company, shown on the consent page.
  final delegate = ''.obs;
  final phase = EnrolPhase.consent.obs;
  final consent = false.obs;
  final consentMissing = false.obs;

  /// Share of the current scan done, 0 to 1 (fills the ring).
  final progress = 0.0.obs;
  final hint = FaceHint.none.obs;
  final saving = false.obs;

  late final lens = Rx<CameraLensDirection>(CameraLensDirection.back);

  final _templates = <Float32List>[];
  var _inThisScan = 0;
  var _busy = false;
  var _lastCapture = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _pause;

  bool get isSelf => person.value?.isSupervisor ?? false;

  /// Whether the camera is on and frames are collected.
  bool get capturing =>
      phase.value == EnrolPhase.scan1 || phase.value == EnrolPhase.scan2;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final team = await appService.getTeam();
    final found = team.where((p) => p.matricule == matricule).firstOrNull;
    person.value = found;
    delegate.value = (await appService.getSector()).delegate;
    // Supervisors enrol themselves with the front camera.
    if (found?.isSupervisor ?? false) lens.value = CameraLensDirection.front;
  }

  void toggleConsent() {
    consent.value = !consent.value;
    if (consent.value) consentMissing.value = false;
  }

  void begin() {
    if (!consent.value) {
      consentMissing.value = true;
      return;
    }
    _startScan(EnrolPhase.scan1);
  }

  void _startScan(EnrolPhase scan) {
    _inThisScan = 0;
    progress.value = 0;
    phase.value = scan;
  }

  /// One camera frame; frames are dropped while the previous one is handled.
  void onFrame(CameraImage image, CameraDescription camera) {
    if (!capturing || _busy) return;
    _busy = true;
    _collect(image, camera).whenComplete(() => _busy = false);
  }

  Future<void> _collect(CameraImage image, CameraDescription camera) async {
    final reading = await _analyzer.analyze(image, camera, maxAngle: _maxAngle);
    if (!capturing) return;
    hint.value = reading.hint;
    if (!reading.ok) return;

    final now = DateTime.now();
    if (now.difference(_lastCapture) < _spacing) return;
    _lastCapture = now;

    try {
      _templates.add(await _analyzer.templateOf(reading));
    } on Object catch (e) {
      debugPrint('[FACE] $e');
      return;
    }
    if (!capturing) return;

    _inThisScan++;
    progress.value = _inThisScan / _perScan;
    if (_inThisScan < _perScan) return;

    if (phase.value == EnrolPhase.scan1) {
      phase.value = EnrolPhase.mid;
      _pause = Timer(const Duration(milliseconds: 1600), () {
        _startScan(EnrolPhase.scan2);
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final found = person.value;
    if (found == null) return;
    phase.value = EnrolPhase.saving;

    final quality = FaceMath.quality(_templates);
    debugPrint('[FACE] enrolment quality ${quality.toStringAsFixed(3)} '
        'on ${_templates.length} templates');
    if (quality < FaceConfig.enrolMinQuality) {
      final context = Get.context;
      if (context != null) {
        showAppToast(AppLocalizations.of(context).enrolQualityLow);
      }
      _templates.clear();
      _startScan(EnrolPhase.scan1);
      return;
    }

    try {
      await appService.saveEnrolment(
        found,
        FaceMath.average(_templates),
        quality,
      );
      phase.value = EnrolPhase.done;
    } on ApiException catch (e) {
      showAppToast(e.message);
      _templates.clear();
      phase.value = EnrolPhase.consent;
    } finally {
      _templates.clear();
    }
  }

  void flipCamera() => lens.value = lens.value == CameraLensDirection.back
      ? CameraLensDirection.front
      : CameraLensDirection.back;

  void close() => Get.back<void>();

  @override
  void onClose() {
    _pause?.cancel();
    super.onClose();
  }
}
