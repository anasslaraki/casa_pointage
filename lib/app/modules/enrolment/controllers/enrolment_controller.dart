import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/team_page.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';

class EnrolmentEntry {
  const EnrolmentEntry(this.person, {required this.enrolled, this.date});

  final Person person;
  final bool enrolled;

  /// When the face was enrolled, when the server says.
  final DateTime? date;
}

/// Who has a face enrolled, and who still needs one.
@injectable
class EnrolmentController extends GetxController {
  EnrolmentController(this.appService);

  final AppService appService;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final entries = <EnrolmentEntry>[].obs;
  final online = true.obs;

  StreamSubscription<void>? _changes;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then(_updateOnline);
    _connectivity = connectivity.onConnectivityChanged.listen(_updateOnline);
    load();
    // Refresh when someone is enrolled from another screen.
    _changes = appService.changes.listen((_) => load());
  }

  void _updateOnline(List<ConnectivityResult> results) {
    online.value = results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> load() => pageState.run(() async {
    final team = await appService.getTeam();
    final enrolled = await appService.getEnrolledMatricules();
    final dates = await appService.getEnrolmentDates();
    entries.assignAll([
      for (final p in team)
        EnrolmentEntry(
          p,
          enrolled: enrolled.contains(p.matricule),
          date: dates[p.matricule],
        ),
    ]);
  });

  int get total => entries.length;
  int get enrolledCount => entries.where((e) => e.enrolled).length;

  List<EnrolmentEntry> _sorted(bool enrolled) =>
      entries.where((e) => e.enrolled == enrolled).toList()
        ..sort((a, b) => a.person.name.compareTo(b.person.name));

  /// People whose face is still to enrol, by name.
  List<EnrolmentEntry> get todo => _sorted(false);

  /// People already enrolled, by name.
  List<EnrolmentEntry> get done => _sorted(true);

  // ---- pages (each section has its own) ----

  static const pageSize = 10;

  final todoPage = 1.obs;
  final donePage = 1.obs;

  PageInfo _info(int total, int page) {
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    return PageInfo(
      page: page.clamp(1, pages),
      pageSize: pageSize,
      total: total,
      totalPages: pages,
    );
  }

  List<EnrolmentEntry> _slice(List<EnrolmentEntry> list, PageInfo info) =>
      list.skip((info.page - 1) * pageSize).take(pageSize).toList();

  PageInfo get todoInfo => _info(todo.length, todoPage.value);
  PageInfo get doneInfo => _info(done.length, donePage.value);

  /// The people of the current page of "À enregistrer".
  List<EnrolmentEntry> get todoItems => _slice(todo, todoInfo);

  /// The people of the current page of "Enregistrés".
  List<EnrolmentEntry> get doneItems => _slice(done, doneInfo);

  void goToTodoPage(int number) => todoPage.value = number;

  void goToDonePage(int number) => donePage.value = number;

  void enrol(Person person) =>
      Get.toNamed(Routes.FACE_ENROL, arguments: person.matricule);

  @override
  void onClose() {
    _changes?.cancel();
    _connectivity?.cancel();
    super.onClose();
  }
}
