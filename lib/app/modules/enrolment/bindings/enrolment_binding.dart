import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/enrolment_controller.dart';

class EnrolmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnrolmentController>(() => getIt<EnrolmentController>());
  }
}
