import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

/// One record or declaration still stored only on the phone.
class SyncItem {
  const SyncItem({required this.person, this.record, this.declaration});

  final Person person;
  final AttendanceRecord? record;
  final Declaration? declaration;
}

/// What is waiting to be sent to the HR module, and the button to send it.
@injectable
class SyncController extends GetxController {
  SyncController(this.appService);

  final AppService appService;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final sending = false.obs;
  final online = true.obs;
  final items = <SyncItem>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  StreamSubscription<void>? _changes;

  bool get canSend => online.value && items.isNotEmpty && !sending.value;

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

    Person? find(String matricule) =>
        team.where((p) => p.matricule == matricule).firstOrNull;

    items.assignAll([
      for (final r in records)
        if (r.sync == SyncState.pending && find(r.matricule) != null)
          SyncItem(person: find(r.matricule)!, record: r),
      for (final d in declarations)
        if (d.sync == SyncState.pending && find(d.matricule) != null)
          SyncItem(person: find(d.matricule)!, declaration: d),
    ]);
  });

  Future<void> sendNow(String doneMessage) async {
    if (!canSend) return;
    sending.value = true;
    try {
      await appService.syncPending();
      showAppToast(doneMessage);
    } finally {
      sending.value = false;
    }
  }

  @override
  void onClose() {
    _connectivity?.cancel();
    _changes?.cancel();
    super.onClose();
  }
}
