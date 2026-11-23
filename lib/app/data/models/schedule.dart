enum ShiftKind { morning, afternoon, night }

/// A work shift. Times are minutes since midnight; [endMinute] may exceed
/// 1440 for shifts that finish after midnight.
class Shift {
  const Shift({
    required this.kind,
    required this.startMinute,
    required this.endMinute,
  });

  final ShiftKind kind;
  final int startMinute;
  final int endMinute;
}

/// Shifts and lateness tolerance. They come from the HR module, never
/// hardcoded in the UI.
class ScheduleConfig {
  const ScheduleConfig({required this.shifts, required this.toleranceMinutes});

  final List<Shift> shifts;
  final int toleranceMinutes;

  /// The shift in progress, or the next one (clock-in opens one hour before).
  Shift shiftAt(int minuteOfDay) {
    for (final s in shifts) {
      if (minuteOfDay >= s.startMinute - 60 && minuteOfDay < s.endMinute) {
        return s;
      }
    }
    for (final s in shifts) {
      if (minuteOfDay < s.startMinute - 60) return s;
    }
    return shifts.first;
  }
}
