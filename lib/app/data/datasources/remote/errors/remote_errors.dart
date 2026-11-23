// Package imports:

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/remote/errors/remote_message_error.dart';
import 'package:casa_pointage/generated/locales.g.dart';

// Project imports:

@lazySingleton
class RemoteErrors {
  final List<RemoteMessageError> errors = [
    const RemoteMessageError(
        codeMessage: 'Your email address is not verified.',
        message: LocaleKeys.error_email_required),

    // TODO : waiting for APIs doc
    // RemoteMessageError(code: 1, message: LocaleKeys.error_user_not_found),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_token_required),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_user_token_not_found),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_token_expired),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_code_required),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_user_code_required),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_code_expired),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_refresh_required),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_refresh_not_found),
    // RemoteMessageError(code: 1, message: LocaleKeys.error_refresh_expired),
  ];

  RemoteErrors();
}
