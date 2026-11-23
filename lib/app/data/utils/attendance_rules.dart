import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';

abstract class AttendanceRules {
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static int minuteOfDay(DateTime d) => d.hour * 60 + d.minute;

  /// `HH:mm` from minutes since midnight (wraps past midnight).
  static String formatMinute(int minute) {
    final m = ((minute % 1440) + 1440) % 1440;
    return '${(m ~/ 60).toString().padLeft(2, '0')}:'
        '${(m % 60).toString().padLeft(2, '0')}';
  }

  static DayState dayState({
    required String matricule,
    required String dateKey,
    required Iterable<AttendanceRecord> records,
    required Iterable<Declaration> declarations,
    required bool enrolled,
    required Shift shift,
    required int toleranceMinutes,
    required int nowMinute,
    required bool isToday,
  }) {
    final mine = records
        .where((r) => r.matricule == matricule && r.dateKey == dateKey)
        .toList();
    AttendanceRecord? find(ClockKind k) {
      for (final r in mine) {
        if (r.kind == k) return r;
      }
      return null;
    }

    final arrival = find(ClockKind.arrival);
    final exit = find(ClockKind.exit);
    final absence = declarations
        .where((d) => d.matricule == matricule && d.coversDay(dateKey))
        .firstOrNull;

    return DayState(
      arrival: arrival,
      exit: exit,
      absence: arrival == null ? absence : null,
      enrolled: enrolled,
      // The server decides the lateness when it says so.
      isLate: arrival != null &&
          (arrival.isLate ??
              arrival.minute > shift.startMinute + toleranceMinutes),
      isOverdue: isToday && nowMinute > shift.startMinute + toleranceMinutes,
      hasPending: mine.any((r) => r.sync == SyncState.pending),
    );
  }
}
