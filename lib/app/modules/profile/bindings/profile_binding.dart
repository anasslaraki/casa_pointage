import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/profile_controller.dart';

/// Controller of the Profile tab, shown inside the home shell.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => getIt<ProfileController>());
  }
}
