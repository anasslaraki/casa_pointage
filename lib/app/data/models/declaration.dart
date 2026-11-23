import 'attendance_record.dart';

enum DeclarationKind { absence, anomaly }

class Declaration {
  const Declaration({
    required this.id,
    required this.matricule,
    required this.kind,
    required this.fromDateKey,
    required this.toDateKey,
    this.absenceReason,
    this.absenceTypeId,
    this.anomalyKind,
    this.comment,
    this.correctTime,
    this.sync = SyncState.synced,
  });

  final String id;
  final String matricule;
  final DeclarationKind kind;

  /// `yyyy-MM-dd`, inclusive.
  final String fromDateKey;
  final String toDateKey;

  /// Reason picked in `GET /types-absence`.
  final String? absenceReason;

  /// Absence declarations only: the id of that reason, sent to the server.
  final int? absenceTypeId;

  /// Anomaly declarations only: the reason picked in `motifs.anomalie`.
  final String? anomalyKind;
  final String? comment;

  /// Anomaly declarations only: the right time, `HH:mm`.
  final String? correctTime;
  final SyncState sync;

  Declaration copyWith({SyncState? sync}) => Declaration(
        id: id,
        matricule: matricule,
        kind: kind,
        fromDateKey: fromDateKey,
        toDateKey: toDateKey,
        absenceReason: absenceReason,
        absenceTypeId: absenceTypeId,
        anomalyKind: anomalyKind,
        comment: comment,
        correctTime: correctTime,
        sync: sync ?? this.sync,
      );

  bool coversDay(String dateKey) =>
      kind == DeclarationKind.absence &&
      fromDateKey.compareTo(dateKey) <= 0 &&
      toDateKey.compareTo(dateKey) >= 0;
}
