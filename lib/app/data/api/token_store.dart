import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Access and refresh tokens, kept in the secure storage of the phone.
@lazySingleton
class TokenStore {
  TokenStore(this._storage);

  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';
  static const _roleKey = 'role';

  final FlutterSecureStorage _storage;

  String? _access;
  String? _refresh;

  String? get access => _access;
  String? get refresh => _refresh;

  /// Role of the signed-in account, kept to choose the interface at a start
  /// without network.
  String? role;

  Future<void> load() async {
    _access = await _storage.read(key: _accessKey);
    _refresh = await _storage.read(key: _refreshKey);
    role = await _storage.read(key: _roleKey);
  }

  Future<void> saveRole(String value) async {
    role = value;
    await _storage.write(key: _roleKey, value: value);
  }

  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    role = null;
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
