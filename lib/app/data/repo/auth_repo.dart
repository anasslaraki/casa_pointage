import 'package:injectable/injectable.dart';

import '../api/api_exception.dart';
import '../api/token_store.dart';
import '../datasources/remote/repos/remote_auth_repo.dart';
import '../models/supervisor.dart';

abstract class AuthRepo {
  /// Returns the supervisor, or `null` when the credentials are wrong.
  /// Throws an [ApiException] for the other refusals (inactive account, not a
  /// supervisor, no depot, wrong API key...), whose message is shown as is.
  Future<Supervisor?> login(String login, String password);

  /// The supervisor of the tokens kept on the phone, or `null` when there is
  /// no usable session (nothing stored, or the tokens can no longer be renewed).
  Future<Supervisor?> restoreSession();

  /// Forgets the tokens.
  Future<void> logout();
}

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this.remoteAuthRepo, this.tokenStore);

  static const _wrongCredentials = 'Utilisateur ou mot de passe incorrect';

  final RemoteAuthRepo remoteAuthRepo;
  final TokenStore tokenStore;

  @override
  Future<Supervisor?> login(String login, String password) async {
    final Map<String, dynamic> json;
    try {
      json = await remoteAuthRepo.login(userName: login, password: password);
    } on ApiException catch (e) {
      if (e.status == 400 && e.message.contains(_wrongCredentials)) return null;
      rethrow;
    }

    await tokenStore.save(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
    final supervisor = _supervisorOf(json, login: login);
    await tokenStore.saveRole(supervisor.role);
    return supervisor;
  }

  @override
  Future<Supervisor?> restoreSession() async {
    await tokenStore.load();
    if (tokenStore.refresh == null) return null;

    try {
      // Also renews the access token when it expired (see ApiClient).
      final json = await remoteAuthRepo.getProfile();
      final supervisor = _supervisorOf(json, login: '${json['userName'] ?? ''}');
      await tokenStore.saveRole(supervisor.role);
      return supervisor;
    } on NetworkUnavailable {
      // No network at start: stay signed in, the data loads when it is back.
      return Supervisor(
        matricule: '',
        name: '',
        function: '',
        login: '',
        role: tokenStore.role ?? '',
      );
    } on SessionExpired {
      return null;
    } on ApiException {
      // The account is no longer allowed (not a supervisor, inactive...).
      await tokenStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => tokenStore.clear();

  /// Both the login answer and `GET /profil` carry these fields.
  Supervisor _supervisorOf(Map<String, dynamic> json, {required String login}) {
    final agent = json['agent'];
    return Supervisor(
      matricule: agent is Map ? '${agent['matricule'] ?? ''}' : '',
      name: '${json['fullName'] ?? ''}',
      function: '${json['fonction'] ?? ''}',
      login: login,
      role: '${json['role'] ?? ''}',
      agentId: agent is Map ? agent['agentId'] as int? : null,
      delegate: '${json['delegataire'] ?? ''}',
      sector: '${json['secteur'] ?? ''}',
      depots: [
        for (final d in (json['depots'] as List? ?? const []))
          if (d is Map) '${d['libelle']}',
      ],
    );
  }
}
