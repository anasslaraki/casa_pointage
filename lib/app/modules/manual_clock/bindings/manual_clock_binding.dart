import 'package:get/get.dart';

import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/manual_clock_controller.dart';

class ManualClockBinding extends Bindings {
  @override
  void dependencies() {
    // Opened with a [ManualClockArgs]; the team by default.
    final args = Get.arguments;
    final resolved = args is ManualClockArgs
        ? args
        : const ManualClockArgs(mode: ScanMode.team);

    Get.lazyPut<ManualClockController>(
      () => getIt<ManualClockController>(param1: resolved),
    );
  }
}
