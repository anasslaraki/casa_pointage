import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../api/location_service.dart';
import '../datasources/remote/repos/remote_kiosk_repo.dart';
import '../face/face_matcher.dart';
import '../models/kiosk_result.dart';
import 'face_template_repo.dart';

/// A face recognised among the people of the dépôt.
class KioskMatch {
  const KioskMatch({required this.agentId, required this.score});

  final int agentId;

  /// Cosine similarity, 0 to 1.
  final double score;
}

abstract class KioskRepo {
  /// Downloads the templates of the people of the dépôt; returns how many.
  Future<int> prepare();

  /// Who is this face, among the people of the dépôt; `null` when nobody
  /// matches well enough.
  Future<KioskMatch?> identify(Float32List face);

  /// Sends the pointage of a recognised person.
  Future<KioskResult> clockIn(KioskMatch match);

  /// Reads the position early, so the pointage does not wait for it.
  Future<void> warmUpLocation();
}

@LazySingleton(as: KioskRepo)
class KioskRepoImpl implements KioskRepo {
  KioskRepoImpl(this._remote, this._templates, this._location);

  final RemoteKioskRepo _remote;
  final FaceTemplateRepo _templates;
  final LocationService _location;

  @override
  Future<int> prepare() async => (await _templates.sync()).length;

  @override
  Future<KioskMatch?> identify(Float32List face) async {
    final match = FaceMatcher.identify(face, await _templates.stored());
    if (match == null) return null;
    return KioskMatch(agentId: match.template.agentId, score: match.score);
  }

  @override
  Future<KioskResult> clockIn(KioskMatch match) async {
    final gps = await _location.current();
    final result = await _remote.postPointage({
      'agentId': match.agentId,
      'methode': 'Visage',
      'scoreVisage': double.parse(match.score.clamp(0, 1).toStringAsFixed(3)),
      'latitude': gps.latitude,
      'longitude': gps.longitude,
      'precisionMetres': gps.accuracyMeters.round(),
    });
    return KioskResult.of(result.message, result.data);
  }

  @override
  Future<void> warmUpLocation() async {
    try {
      await _location.current();
    } catch (_) {
      // The pointage asks again and shows the reason.
    }
  }
}
