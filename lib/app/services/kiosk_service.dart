import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../data/models/kiosk_result.dart';
import '../data/repo/kiosk_repo.dart';

/// Face pointage of the kiosk role: recognise, then send.
@lazySingleton
class KioskService {
  KioskService(this._repo);

  final KioskRepo _repo;

  Future<int> prepare() => _repo.prepare();

  Future<KioskMatch?> identify(Float32List face) => _repo.identify(face);

  Future<KioskResult> clockIn(KioskMatch match) => _repo.clockIn(match);

  Future<void> warmUpLocation() => _repo.warmUpLocation();
}
