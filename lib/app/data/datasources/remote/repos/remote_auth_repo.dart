import 'package:injectable/injectable.dart';

import '../../../api/api_client.dart';

/// Raw calls of the authentication endpoints.
abstract class RemoteAuthRepo {
  /// `POST /Authentication`: the JSON answer of the login.
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
  });

  /// `GET /profil`.
  Future<Map<String, dynamic>> getProfile();
}

@LazySingleton(as: RemoteAuthRepo)
class RemoteAuthRepoImpl implements RemoteAuthRepo {
  RemoteAuthRepoImpl(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
  }) async {
    final json = await _api.request(
      'POST',
      '/Authentication',
      body: {'userName': userName, 'password': password},
    );
    return (json as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> getProfile() async =>
      ((await _api.get('/profil')) as Map).cast<String, dynamic>();
}
