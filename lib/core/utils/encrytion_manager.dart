// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:injectable/injectable.dart';

abstract class EncryptionManager {
  Future<List<int>> getKey();

  Future<bool> keyExists();

  Future<void> deleteKey();
}

@LazySingleton(as: EncryptionManager)
class EncryptionManagerImpl implements EncryptionManager {
  Uint8List? _key;

  static const String kEncryptionKey = 'com.drawcutie.app.encryption.key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  EncryptionManagerImpl();

  @override
  Future<void> deleteKey() async {
    await _storage.delete(key: kEncryptionKey);
  }

  @override
  Future<Uint8List> getKey() async {
    if (_key != null) {
      return _key!;
    }
    var storageKey = await _storage.read(key: kEncryptionKey);
    if (storageKey == null) {
      final newKey = Hive.generateSecureKey();
      await _storage.write(key: kEncryptionKey, value: base64Encode(newKey));
      storageKey = await _storage.read(key: kEncryptionKey);
    }
    _key = base64Decode(storageKey!);
    return _key!;
  }

  @override
  Future<bool> keyExists() async {
    return (await _storage.read(key: kEncryptionKey) != null);
  }
}
