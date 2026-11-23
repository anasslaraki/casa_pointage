import 'package:get/get.dart';

import 'package:casa_pointage/core/di/injection.dart';

import '../controllers/history_controller.dart';

/// Controller of the History tab, shown inside the home shell.
class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(() => getIt<HistoryController>());
  }
}
