// Package imports:
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

abstract class LocalModelVersions {
  Future<bool> shouldCleanup(String boxName, {String? version});

  setVersion(String boxName, {String? version});
}

@LazySingleton(as: LocalModelVersions)
class LocalModelVersionsImpl implements LocalModelVersions {
  Box? box;
  static const boxName = 'model_versions';

  LocalModelVersionsImpl() {
    _init();
  }

  Future _init() async {
    box ??= Hive.isBoxOpen(boxName) ? Hive.box(boxName) : await Hive.openBox(boxName);
  }

  @override
  setVersion(String boxName, {String? version}) async {
    await _init();
    if (version == null) {
      return;
    }
    box!.put(boxName, version);
  }

  @override
  Future<bool> shouldCleanup(String boxName, {String? version}) async {
    await _init();
    if (version == null || !box!.containsKey(boxName)) {
      return false;
    }
    return box!.get(boxName) != version;
  }
}
