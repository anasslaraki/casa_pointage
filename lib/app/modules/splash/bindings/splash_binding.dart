import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Not lazy: the view never reads the controller, so a lazy one would never
    // be created and the check would never run.
    Get.put<SplashController>(getIt<SplashController>());
  }
}
