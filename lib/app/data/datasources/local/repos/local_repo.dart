// Dart imports:
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/local/repos/local_model_version.dart';
import 'package:casa_pointage/core/utils/encrytion_manager.dart';

// Project imports:

abstract class LocalRepo {
  Future<Box> initBox<T>({
    required String boxName,
    String? version,
    bool inMemory = false,
    bool useEncryption = false,
    Future Function(Box box) warmupCallback,
  });

  String keyShortify(String key);
}

@Injectable(as: LocalRepo)
class LocalRepoImpl implements LocalRepo {
  final LocalModelVersions localModelVersions;
  final EncryptionManager encryptionManager;

  LocalRepoImpl(this.localModelVersions, this.encryptionManager);

  @override
  Future<Box> initBox<T>(
      {required String boxName,
      String? version,
      bool inMemory = false,
      bool useEncryption = false,
      Future Function(Box box)? warmupCallback}) async {
    Box? box;
    try {
      box = await _init<T>(
        boxName: boxName,
        version: version,
        inMemory: inMemory,
        useEncryption: useEncryption,
        warmupCallback: warmupCallback,
      );
    } catch (e, stacktrace) {
      log('BOX init failed $e , $stacktrace');
      box?.close();
      box?.deleteFromDisk();
      box = await _init<T>(
        boxName: boxName,
        version: version,
        inMemory: inMemory,
        useEncryption: useEncryption,
        warmupCallback: warmupCallback,
      );
    }

    return box;
  }

  Future<Box> _init<T>({
    required String boxName,
    String? version,
    bool inMemory = false,
    bool useEncryption = false,
    Future Function(Box box)? warmupCallback,
  }) async {
    late Box box;
    if (await Hive.boxExists(boxName)) {
      // print("Box '$boxName' already exists.");
      if (await localModelVersions.shouldCleanup(boxName, version: version)) {
        // print("Model version for '$boxName' mismatch. Deleting.");
        await Hive.deleteBoxFromDisk(boxName);
      }
    }

    HiveCipher? cipher;
    if (useEncryption) {
      final key = await encryptionManager.getKey();
      cipher = HiveAesCipher(key);
    }
    box = await Hive.openBox<T>(
      boxName,
      bytes: inMemory ? Uint8List(0) : null,
      encryptionCipher: cipher,
    );
    // print('$boxName: ${box.keys.length} stored keys');
    localModelVersions.setVersion(boxName, version: version);
    if (warmupCallback != null) {
      await warmupCallback(box);
    }

    return box;
  }

  @override
  String keyShortify(String key) {
    if (key.length < 255) {
      return key;
    }
    return "${key.substring(0, 220)}-${md5.convert(utf8.encode(key))}";
  }
}
