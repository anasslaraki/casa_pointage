import 'attendance_record.dart';
import 'declaration.dart';
import 'person.dart';
import 'person_day.dart';

/// Position in a paginated list (`page`, `pageSize`, `total`, `totalPages`).
class PageInfo {
  const PageInfo({
    this.page = 1,
    this.pageSize = 50,
    this.total = 0,
    this.totalPages = 1,
  });

  factory PageInfo.of(Map<String, dynamic> json, {int fallbackTotal = 0}) {
    int number(String key, int fallback) =>
        (json[key] as num?)?.toInt() ?? fallback;
    final total = number('total', fallbackTotal);
    return PageInfo(
      page: number('page', 1),
      pageSize: number('pageSize', 50),
      total: total,
      totalPages: number('totalPages', 1).clamp(1, 1 << 30),
    );
  }

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  /// Number of the first and last item of this page, from 1 (0 when empty).
  int get firstItem => total == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastItem => total == 0 ? 0 : (page * pageSize).clamp(0, total);
}

/// Counters of the whole team (`compteurs`), whatever the filter or the page.
class TeamCounters {
  const TeamCounters({
    this.all = 0,
    this.clockedIn = 0,
    this.notClocked = 0,
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.out = 0,
    this.notEnrolled = 0,
  });

  factory TeamCounters.of(Map<String, dynamic>? json) {
    int n(String key) => (json?[key] as num?)?.toInt() ?? 0;
    return TeamCounters(
      all: n('tous'),
      clockedIn: n('pointes'),
      notClocked: n('nonPointes'),
      present: n('presents'),
      late: n('retards'),
      absent: n('absents'),
      out: n('sortis'),
      notEnrolled: n('nonEnroles'),
    );
  }

  final int all;
  final int clockedIn;
  final int notClocked;
  final int present;
  final int late;
  final int absent;
  final int out;
  final int notEnrolled;
}

/// One page of the team for a filter and a search, with what is needed to show
/// each person (their clock-ins, declarations and enrolment of the day).
class TeamPage {
  const TeamPage({
    required this.people,
    required this.records,
    required this.declarations,
    required this.enrolled,
    required this.counters,
    required this.info,
    this.me,
  });

  /// The people of the page, the supervisor excluded.
  final List<Person> people;

  /// The supervisor's own card, on every page.
  final Person? me;

  /// Records and declarations of [people] and of [me].
  final List<AttendanceRecord> records;
  final List<Declaration> declarations;
  final Set<String> enrolled;

  final TeamCounters counters;
  final PageInfo info;
}

/// One page of the history of a day.
class HistoryPage {
  const HistoryPage({required this.rows, required this.info});

  final List<PersonDay> rows;
  final PageInfo info;
}
