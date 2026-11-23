import 'attendance_record.dart';
import 'declaration.dart';

enum DayStatus {
  present,
  out,
  late,
  absentJustified,
  notClocked,
  overdue,
  notEnrolled,
}

/// What happened to one person on one day.
class DayState {
  const DayState({
    this.arrival,
    this.exit,
    this.absence,
    this.enrolled = true,
    this.isLate = false,
    this.isOverdue = false,
    this.hasPending = false,
  });

  final AttendanceRecord? arrival;
  final AttendanceRecord? exit;
  final Declaration? absence;
  final bool enrolled;

  /// Arrived after the shift start + tolerance (also true once they left).
  final bool isLate;

  /// Not clocked in although the shift started more than the tolerance ago.
  final bool isOverdue;
  final bool hasPending;

  bool get isInside => arrival != null && exit == null;

  DayStatus get status {
    if (arrival != null) {
      if (exit != null) return DayStatus.out;
      return isLate ? DayStatus.late : DayStatus.present;
    }
    if (absence != null) return DayStatus.absentJustified;
    if (!enrolled) return DayStatus.notEnrolled;
    return isOverdue ? DayStatus.overdue : DayStatus.notClocked;
  }

  /// Lower comes first in the team list.
  int get sortRank => switch (status) {
        DayStatus.overdue => 0,
        DayStatus.notClocked => 1,
        DayStatus.notEnrolled => 2,
        DayStatus.late => 3,
        DayStatus.present => 4,
        DayStatus.absentJustified => 5,
        DayStatus.out => 6,
      };
}
