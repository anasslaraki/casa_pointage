/// A pointage made at the kiosk, as the server answers it.
class KioskResult {
  const KioskResult({
    required this.fullName,
    required this.matricule,
    required this.isArrival,
    required this.message,
    required this.time,
    required this.isLate,
    required this.lateMinutes,
    required this.atDepot,
  });

  final String fullName;
  final String matricule;

  /// `Entree` (arrival) or `Sortie` (departure).
  final bool isArrival;

  /// The server text, e.g. "Arrivée pointée.".
  final String message;
  final DateTime time;
  final bool isLate;
  final int lateMinutes;

  /// `false` when the person was pointed far from their dépôt; `null` when the
  /// dépôt has no known position.
  final bool? atDepot;

  /// From the message and the `data` of the `POST /pointages` answer.
  static KioskResult of(String message, dynamic data) {
    final json = data is Map ? data.cast<String, dynamic>() : const {};
    final pointage = json['pointage'] is Map
        ? (json['pointage'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    return KioskResult(
      fullName: '${json['fullName'] ?? ''}',
      matricule: '${json['matricule'] ?? ''}',
      isArrival: '${json['type'] ?? pointage['type']}' != 'Sortie',
      message: message,
      time: DateTime.tryParse('${pointage['datePointage'] ?? ''}') ??
          DateTime.now(),
      isLate: json['enRetard'] == true,
      lateMinutes: (json['retardMinutes'] as num?)?.toInt() ?? 0,
      atDepot: json['auDepot'] as bool?,
    );
  }
}
