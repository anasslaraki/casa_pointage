import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';
import 'package:casa_pointage/app/data/models/sector.dart';
import 'package:casa_pointage/app/data/models/team_page.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

enum TeamFilter {
  all,
  notClocked,
  present,
  late,
  absent,
  out,
  notEnrolled;

  /// The `filtre` of `GET /equipe` (empty for everyone).
  String get apiValue => switch (this) {
        TeamFilter.all => '',
        TeamFilter.notClocked => 'NonPointes',
        TeamFilter.present => 'Presents',
        TeamFilter.late => 'Retards',
        TeamFilter.absent => 'Absents',
        TeamFilter.out => 'Sortis',
        TeamFilter.notEnrolled => 'NonEnroles',
      };
}

class TeamMember {
  const TeamMember(this.person, this.state);

  final Person person;
  final DayState state;
}

/// The Équipe tab: the filter, the search and the pages are done by the server;
/// [pageSize] people are shown at a time.
@injectable
class TeamController extends GetxController {
  TeamController(this.appService);

  static const pageSize = 10;

  final AppService appService;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final sector = Rxn<Sector>();
  final shift = Rxn<Shift>();
  final me = Rxn<TeamMember>();

  /// The people of the current page, the supervisor excluded.
  final members = <TeamMember>[].obs;

  final filter = TeamFilter.all.obs;
  final query = ''.obs;
  final page = 1.obs;
  final pageInfo = const PageInfo().obs;
  final counters = const TeamCounters().obs;
  final online = true.obs;
  final now = DateTime.now().obs;

  /// The list is being reloaded (filter, search or page changed): the header
  /// and the search field stay, the rows show a skeleton.
  final listLoading = false.obs;

  /// A manual refresh is running (spins the refresh button).
  final refreshing = false.obs;

  final searchController = TextEditingController();

  ScheduleConfig? _schedule;
  TeamPage? _data;

  Timer? _clock;
  Timer? _searchDebounce;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  StreamSubscription<void>? _changes;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _watchConnectivity();
    load();
    // Refresh when a clock-in is saved from another screen.
    _changes = appService.changes.listen((_) {
      // A manual refresh already reloads, with the skeleton.
      if (!refreshing.value) load(silent: true);
    });
    // Lateness and "overdue" depend on the time of day.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _recompute());
  }

  void _onSearchChanged() {
    final text = searchController.text;
    if (text == query.value) return;
    query.value = text;
    // Wait for a pause in the typing before asking the server.
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      page.value = 1;
      _reloadList();
    });
  }

  /// Loads everything; [silent] keeps the list on screen while refreshing.
  Future<void> load({bool silent = false}) =>
      pageState.run(silent: silent, _fetch);

  Future<void> _fetch() async {
    final results = await Future.wait<Object>([
      appService.getSector(),
      appService.getSchedule(),
      appService.getTeamPage(
        filter: filter.value.apiValue,
        search: query.value,
        page: page.value,
        pageSize: pageSize,
      ),
    ]);
    sector.value = results[0] as Sector;
    _schedule = results[1] as ScheduleConfig;
    final data = results[2] as TeamPage;
    _data = data;
    pageInfo.value = data.info;
    counters.value = data.counters;
    _recompute();
  }

  /// Reloads the list only, after a filter, a search or a page change.
  Future<void> _reloadList() async {
    listLoading.value = true;
    try {
      await _fetch();
    } on ApiException catch (e) {
      showAppToast(e.message);
    } finally {
      listLoading.value = false;
    }
  }

  void _recompute() {
    final schedule = _schedule;
    final data = _data;
    if (schedule == null || data == null) return;

    final today = DateTime.now();
    now.value = today;
    final dateKey = AttendanceRules.dateKey(today);
    final nowMinute = AttendanceRules.minuteOfDay(today);
    final currentShift = schedule.shiftAt(nowMinute);
    shift.value = currentShift;

    TeamMember build(Person p) => TeamMember(
          p,
          AttendanceRules.dayState(
            matricule: p.matricule,
            dateKey: dateKey,
            records: data.records,
            declarations: data.declarations,
            enrolled: data.enrolled.contains(p.matricule),
            shift: currentShift,
            toleranceMinutes: schedule.toleranceMinutes,
            nowMinute: nowMinute,
            isToday: true,
          ),
        );

    me.value = data.me == null ? null : build(data.me!);
    members.assignAll(data.people.map(build));
  }

  void _watchConnectivity() {
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then(_updateOnline);
    _connectivity = connectivity.onConnectivityChanged.listen(_updateOnline);
  }

  void _updateOnline(List<ConnectivityResult> results) {
    online.value = results.any((r) => r != ConnectivityResult.none);
  }

  /// Reloads everything from the server (the refresh button).
  Future<void> refresh() async {
    if (refreshing.value) return;
    refreshing.value = true;
    try {
      appService.refresh();
      await load();
    } finally {
      refreshing.value = false;
    }
  }

  // ---- derived data ----

  /// Records waiting to be sent to the HR module.
  int get pendingCount =>
      (_data?.records.where((r) => r.sync == SyncState.pending).length ?? 0) +
      (_data?.declarations.where((d) => d.sync == SyncState.pending).length ??
          0);

  /// The whole team, as `compteurs.tous` says.
  int get total => counters.value.all;

  /// People already clocked in today, as `compteurs.pointes` says.
  int get clockedInCount => counters.value.clockedIn;

  /// People of the whole team in a filter, for the chip.
  int countFor(TeamFilter f) {
    final c = counters.value;
    return switch (f) {
      TeamFilter.all => total,
      TeamFilter.notClocked => c.notClocked,
      TeamFilter.present => c.present,
      TeamFilter.late => c.late,
      TeamFilter.absent => c.absent,
      TeamFilter.out => c.out,
      TeamFilter.notEnrolled => c.notEnrolled,
    };
  }

  /// Filters that have at least one person ("all" and the active one always).
  List<TeamFilter> get visibleFilters => [
        for (final f in TeamFilter.values)
          if (f == TeamFilter.all || f == filter.value || countFor(f) > 0) f,
      ];

  void selectFilter(TeamFilter f) {
    if (f == filter.value) return;
    filter.value = f;
    page.value = 1;
    _reloadList();
  }

  void goToPage(int number) {
    if (number == page.value) return;
    page.value = number;
    _reloadList();
  }

  @override
  void onClose() {
    _clock?.cancel();
    _searchDebounce?.cancel();
    _connectivity?.cancel();
    _changes?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
