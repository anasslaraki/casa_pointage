import 'package:get/get.dart';

import 'package:casa_pointage/app/modules/enrolment/bindings/enrolment_binding.dart';
import 'package:casa_pointage/app/modules/history/bindings/history_binding.dart';
import 'package:casa_pointage/app/modules/profile/bindings/profile_binding.dart';
import 'package:casa_pointage/app/modules/team/bindings/team_binding.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // Controllers of the tabs shown inside the home shell.
    TeamBinding().dependencies();
    EnrolmentBinding().dependencies();
    HistoryBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
