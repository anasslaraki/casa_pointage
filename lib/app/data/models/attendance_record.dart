import 'assignment.dart';

enum ClockKind { arrival, exit }

enum ClockMethod { face, manual }

enum SyncState { synced, pending }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.matricule,
    required this.dateKey,
    required this.kind,
    required this.minute,
    required this.method,
    required this.inZone,
    required this.assignment,
    this.score,
    this.lateReason,
    this.manualReason,
    this.photoPath,
    this.isLate,
    this.lateMinutes = 0,
    this.sync = SyncState.synced,
  });

  final String id;
  final String matricule;

  /// `yyyy-MM-dd`.
  final String dateKey;
  final ClockKind kind;

  /// Minutes since midnight.
  final int minute;
  final ClockMethod method;
  final bool inZone;
  final Assignment assignment;

  /// Face match score in percent (face method only).
  final int? score;

  /// Reason picked in `motifs.retard`.
  final String? lateReason;

  /// Manual method only: the reason (`motifs.manuel`) and the proof photo
  /// taken by the supervisor.
  final String? manualReason;
  final String? photoPath;

  /// Lateness decided by the server; `null` when it is not known.
  final bool? isLate;
  final int lateMinutes;
  final SyncState sync;

  AttendanceRecord copyWith({
    SyncState? sync,
    String? lateReason,
    String? manualReason,
  }) => AttendanceRecord(
        id: id,
        matricule: matricule,
        dateKey: dateKey,
        kind: kind,
        minute: minute,
        method: method,
        inZone: inZone,
        assignment: assignment,
        score: score,
        lateReason: lateReason ?? this.lateReason,
        manualReason: manualReason ?? this.manualReason,
        photoPath: photoPath,
        isLate: isLate,
        lateMinutes: lateMinutes,
        sync: sync ?? this.sync,
      );
}
