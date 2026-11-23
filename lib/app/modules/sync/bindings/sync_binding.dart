import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/sync_controller.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SyncController>(() => getIt<SyncController>());
  }
}
