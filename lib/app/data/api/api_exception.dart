/// An error the user can read: [message] is shown as is.
class ApiException implements Exception {
  const ApiException(this.message, {this.status});

  final String message;
  final int? status;

  bool get isNotFound => status == 404;

  @override
  String toString() => message;
}

/// Wrong or revoked API key (401 on every call, even the login).
class AppNotAuthorized extends ApiException {
  const AppNotAuthorized()
      : super('Application non autorisée, contactez le support', status: 401);
}

/// Tokens refused and the refresh failed: back to the login screen.
class SessionExpired extends ApiException {
  const SessionExpired() : super('Session expirée', status: 401);
}

/// No network, or the server did not answer in time.
class NetworkUnavailable extends ApiException {
  const NetworkUnavailable() : super('Pas de réseau');
}
