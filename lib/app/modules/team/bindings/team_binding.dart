import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamController>(() => getIt<TeamController>());
  }
}
