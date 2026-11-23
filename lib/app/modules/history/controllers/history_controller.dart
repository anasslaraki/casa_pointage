import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/person_day.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/data/models/team_page.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

enum HistoryFilter {
  all,
  late,
  absent,
  manual;

  /// The `filtre` of `GET /historique` (empty for every line).
  String get apiValue => switch (this) {
        HistoryFilter.all => '',
        HistoryFilter.late => 'Retards',
        HistoryFilter.absent => 'Absents',
        HistoryFilter.manual => 'Manuels',
      };
}

/// A person on the selected day: what happened, and who they are.
class HistoryRow {
  const HistoryRow(this.day, this.person);

  final PersonDay day;

  /// `null` when the person is no longer in the team.
  final Person? person;
}

/// The last days of attendance: pick a day, then see everyone's clock-ins, a
/// page at a time (the filter and the pages are done by the server).
@injectable
class HistoryController extends GetxController {
  HistoryController(this.appService);

  static const dayCount = 14;
  static const pageSize = 10;

  final AppService appService;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final sector = Rxn<Sector>();
  final online = true.obs;

  /// The days of the strip, oldest first (today is the last one).
  final days = <DateTime>[].obs;
  final selected = Rx<DateTime>(_today());
  final filter = HistoryFilter.all.obs;
  final page = 1.obs;
  final pageInfo = const PageInfo().obs;

  /// The people of the current page.
  final rows = <HistoryRow>[].obs;

  /// The rows are being reloaded (day, filter or page changed).
  final listLoading = false.obs;

  Map<String, Person> _team = const {};

  StreamSubscription<void>? _changes;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void onInit() {
    super.onInit();
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then(_updateOnline);
    _connectivity = connectivity.onConnectivityChanged.listen(_updateOnline);
    load();
    // Today changes when someone is clocked in.
    _changes = appService.changes.listen((_) => load(silent: true));
  }

  void _updateOnline(List<ConnectivityResult> results) {
    online.value = results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> load({bool silent = false}) =>
      pageState.run(silent: silent, () async {
        final results = await Future.wait<Object>([
          appService.getSector(),
          appService.getTeam(),
        ]);
        sector.value = results[0] as Sector;
        _team = {
          for (final p in results[1] as List<Person>) p.matricule: p,
        };

        final today = _today();
        days.assignAll([
          for (var i = dayCount - 1; i >= 0; i--)
            DateTime(today.year, today.month, today.day - i),
        ]);
        if (!days.contains(selected.value)) selected.value = today;

        await _fetchRows();
      });

  Future<void> _fetchRows() async {
    final result = await appService.getHistoryPage(
      dateKey: AttendanceRules.dateKey(selected.value),
      filter: filter.value.apiValue,
      page: page.value,
      pageSize: pageSize,
    );
    pageInfo.value = result.info;
    rows.assignAll([
      for (final d in result.rows)
        HistoryRow(d, _team[d.matricule])
    ]..sort((a, b) => (a.person?.name ?? a.day.name)
        .compareTo(b.person?.name ?? b.day.name)));
  }

  /// Reloads the rows only, after a day, a filter or a page change.
  Future<void> _reloadRows() async {
    listLoading.value = true;
    try {
      await _fetchRows();
    } on ApiException catch (e) {
      showAppToast(e.message);
    } finally {
      listLoading.value = false;
    }
  }

  bool isToday(DateTime date) => date == _today();

  void selectDay(DateTime date) {
    if (date == selected.value) return;
    selected.value = date;
    page.value = 1;
    _reloadRows();
  }

  void selectFilter(HistoryFilter f) {
    if (f == filter.value) return;
    filter.value = f;
    page.value = 1;
    _reloadRows();
  }

  void goToPage(int number) {
    if (number == page.value) return;
    page.value = number;
    _reloadRows();
  }

  /// The last 14 days of one person, for their history sheet.
  Future<List<PersonDay>> loadPersonHistory(Person person) =>
      appService.getPersonHistory(person, dayCount);

  @override
  void onClose() {
    _changes?.cancel();
    _connectivity?.cancel();
    super.onClose();
  }
}
