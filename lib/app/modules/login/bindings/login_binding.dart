import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => getIt<LoginController>());
  }
}
