enum AssignmentKind {
  manualSweeping,
  mechanicalSweeping,
  collection,
  supervision,
}

/// Today's assignment, from the planning module.
class Assignment {
  const Assignment({required this.kind, this.circuit, this.vehicle});

  final AssignmentKind kind;
  final String? circuit;

  /// Cart or vehicle code.
  final String? vehicle;

  Assignment copyWith({String? circuit, String? vehicle}) => Assignment(
        kind: kind,
        circuit: circuit ?? this.circuit,
        vehicle: vehicle ?? this.vehicle,
      );
}

/// Circuits and carts/vehicles the supervisor can pick when changing an
/// assignment.
class AssignmentOptions {
  const AssignmentOptions({this.circuits = const [], this.vehicles = const []});

  final List<String> circuits;
  final List<String> vehicles;
}
