class Supervisor {
  const Supervisor({
    required this.matricule,
    required this.name,
    required this.function,
    required this.login,
    this.agentId,
    this.delegate = '',
    this.sector = '',
    this.depots = const [],
    this.role = '',
  });

  /// Roles that get the full supervisor interface. Any other role is a kiosk:
  /// the face screen only.
  static const supervisorRoles = {'SuperviseurDepot', 'ResponsableDepot'};

  final String matricule;
  final String name;
  final String function;
  final String login;

  /// The supervisor's own staff record; `null` when they cannot clock themself.
  final int? agentId;
  final String delegate;
  final String sector;

  /// Names of the places where the supervisor clocks people ("Lieu de pointage").
  final List<String> depots;

  /// `role` of the login answer (`SuperviseurDepot`, `Pointeur`...).
  final String role;

  /// A kiosk account (role `Pointeur`): only the face recognition screen.
  bool get isKiosk => role.isNotEmpty && !supervisorRoles.contains(role);
}
