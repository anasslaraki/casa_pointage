enum PersonFunction {
  supervisor,
  sweeperMale,
  sweeperFemale,
  driver,
  loader,
  sweeperDriver,
  teamLead,

  /// A function the app has no translation for: [Person.fonction] is shown.
  other,
}

class Person {
  const Person({
    required this.matricule,
    required this.name,
    required this.function,
    this.agentId = 0,
    this.fonction = '',
    this.shiftStartMinute,
    this.shiftEndMinute,
  });

  /// Identifier of the person in the API.
  final int agentId;
  final String matricule;
  final String name;
  final PersonFunction function;

  /// Function as written by the API.
  final String fonction;

  /// Start and end of the circuit today (`heureDebutPoste`, `heureFinPoste`),
  /// in minutes since midnight.
  final int? shiftStartMinute;
  final int? shiftEndMinute;

  bool get isSupervisor => function == PersonFunction.supervisor;

  /// First letters of the first two words of the name.
  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();

  /// Best-effort mapping of the free text sent by the API.
  static PersonFunction functionFrom(String fonction, {bool supervisor = false}) {
    if (supervisor) return PersonFunction.supervisor;
    final f = fonction.toLowerCase();
    if (f.contains('chef')) return PersonFunction.teamLead;
    final sweeps = f.contains('balay');
    final drives = f.contains('chauffeur') || f.contains('conducteur');
    if (sweeps && drives) return PersonFunction.sweeperDriver;
    if (f.contains('balayeuse')) return PersonFunction.sweeperFemale;
    if (sweeps) return PersonFunction.sweeperMale;
    if (drives) return PersonFunction.driver;
    if (f.contains('ramass') || f.contains('rippeur') || f.contains('charg')) {
      return PersonFunction.loader;
    }
    return PersonFunction.other;
  }
}
