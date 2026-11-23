enum PersonDayKind { rest, absent, worked, missing }

/// One person on one day, as the history gives it.
class PersonDay {
  const PersonDay({
    required this.dateKey,
    required this.kind,
    this.matricule = '',
    this.name = '',
    this.circuit,
    this.arrivalMinute,
    this.exitMinute,
    this.isLate = false,
    this.lateMinutes = 0,
    this.manual = false,
  });

  /// `yyyy-MM-dd`.
  final String dateKey;
  final PersonDayKind kind;

  final String matricule;
  final String name;
  final String? circuit;

  /// Minutes since midnight.
  final int? arrivalMinute;
  final int? exitMinute;
  final bool isLate;
  final int lateMinutes;

  /// Clocked in or out by hand rather than by face.
  final bool manual;
}
