import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/services/auth_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/localization/locale_controller.dart';

/// The supervisor, their sector and the app settings.
@injectable
class ProfileController extends GetxController {
  ProfileController(this.appService, this.authService);

  /// Shown in the footer until a package-info plugin is added.
  static const appVersion = '1.0.0';

  final AppService appService;
  final AuthService authService;
  final LocaleController localeController = Get.find<LocaleController>();

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final supervisor = Rxn<Person>();
  final sector = Rxn<Sector>();

  /// People of the team, the supervisor excluded.
  final teamCount = 0.obs;
  final online = true.obs;

  /// Records and declarations waiting to be sent to the HR module.
  final pendingCount = 0.obs;

  StreamSubscription<void>? _changes;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then(_updateOnline);
    _connectivity = connectivity.onConnectivityChanged.listen(_updateOnline);
    load();
    _changes = appService.changes.listen((_) => load());
  }

  void _updateOnline(List<ConnectivityResult> results) {
    online.value = results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> load() => pageState.run(() async {
    final dateKey = AttendanceRules.dateKey(DateTime.now());
    final team = await appService.getTeam();
    final records = await appService.getRecords(dateKey);
    final declarations = await appService.getDeclarations(dateKey);

    supervisor.value = team.where((p) => p.isSupervisor).firstOrNull;
    sector.value = await appService.getSector();
    teamCount.value = team.where((p) => !p.isSupervisor).length;
    pendingCount.value =
        records.where((r) => r.sync == SyncState.pending).length +
            declarations.where((d) => d.sync == SyncState.pending).length;
  });

  /// Sends what is waiting to the HR module.
  Future<void> sendNow() => appService.syncPending();

  void setLanguage(bool arabic) => localeController
      .setLocale(arabic ? LocaleController.ar : LocaleController.fr);

  Future<void> logout() async {
    await authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    _changes?.cancel();
    _connectivity?.cancel();
    super.onClose();
  }
}
