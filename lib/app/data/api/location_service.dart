import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as device;
import 'package:injectable/injectable.dart';

import 'api_exception.dart';

class GpsFix {
  const GpsFix(this.latitude, this.longitude, this.accuracyMeters);

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

/// Current position of the phone; every pointage needs it.
@lazySingleton
class LocationService {
  /// A last known position older than this is not used.
  static const _maxAge = Duration(minutes: 5);

  /// Asks, with the phone's own dialogs, for what the pointage needs: the
  /// permission to share the position, then the location switched on. Nothing
  /// is shown when both are already fine. Returns whether a position can be
  /// read now.
  Future<bool> ensureReady() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      if (await Geolocator.isLocationServiceEnabled()) return true;
      // The "turn on location" dialog of the phone.
      return await device.Location().requestService();
    } catch (e) {
      debugPrint('[GPS] ensureReady failed: $e');
      return false;
    }
  }

  Future<GpsFix> current() async {
    const pending = ApiException('Localisation en cours…');

    if (!await Geolocator.isLocationServiceEnabled() &&
        !await ensureReady()) {
      debugPrint('[GPS] location service is off');
      throw const ApiException(
        'Activez la localisation du téléphone, puis réessayez.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const ApiException('Position GPS obligatoire.');
    }

    // Precise fix first, then a coarser one (indoors the GPS may not answer),
    // then a recent position the phone already has.
    for (final (accuracy, seconds) in const [
      (LocationAccuracy.high, 8),
      (LocationAccuracy.medium, 8),
    ]) {
      try {
        final p = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            timeLimit: Duration(seconds: seconds),
          ),
        );
        return GpsFix(p.latitude, p.longitude, p.accuracy);
      } catch (e) {
        debugPrint('[GPS] $accuracy failed: $e');
      }
    }

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && DateTime.now().difference(last.timestamp) < _maxAge) {
        return GpsFix(last.latitude, last.longitude, last.accuracy);
      }
    } catch (e) {
      debugPrint('[GPS] last known position failed: $e');
    }

    throw pending;
  }
}
