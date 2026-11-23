import 'package:get/get.dart';

import '../controllers/clock_done_controller.dart';

class ClockDoneBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.lazyPut<ClockDoneController>(
      () => ClockDoneController(args as ClockDoneArgs),
    );
  }
}
