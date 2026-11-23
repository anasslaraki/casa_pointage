import 'package:get/get.dart';

import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    // Opened with a [ScanMode] or [ScanArgs]; the team (back camera) by default.
    final args = Get.arguments;
    final mode = switch (args) {
      ScanArgs() => args.mode,
      ScanMode() => args,
      _ => ScanMode.team,
    };
    final matricule = args is ScanArgs ? args.matricule : null;

    Get.lazyPut<ScanController>(
      () => getIt<ScanController>(param1: mode, param2: matricule),
    );
  }
}
