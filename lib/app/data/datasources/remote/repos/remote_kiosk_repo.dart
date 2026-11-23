import 'package:injectable/injectable.dart';

import '../../../api/api_client.dart';

/// Raw call of the kiosk pointage.
abstract class RemoteKioskRepo {
  /// `POST /pointages` with a kiosk token: `agentId` and `scoreVisage` are
  /// required, the server records its own time.
  Future<ApiResult> postPointage(Map<String, dynamic> body);
}

@LazySingleton(as: RemoteKioskRepo)
class RemoteKioskRepoImpl implements RemoteKioskRepo {
  RemoteKioskRepoImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult> postPointage(Map<String, dynamic> body) =>
      _api.write('POST', '/pointages', body: body);
}
