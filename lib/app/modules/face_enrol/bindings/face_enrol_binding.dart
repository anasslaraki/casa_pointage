import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/face_enrol_controller.dart';

class FaceEnrolBinding extends Bindings {
  @override
  void dependencies() {
    // Opened with the matricule of the person.
    final args = Get.arguments;
    final matricule = args is String ? args : '';

    Get.lazyPut<FaceEnrolController>(
      () => getIt<FaceEnrolController>(param1: matricule),
    );
  }
}
