// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;
import 'package:injectable/injectable.dart';
import 'package:casa_pointage/app/data/datasources/remote/errors/remote_errors.dart';
import 'package:casa_pointage/app/data/datasources/remote/errors/remote_message_error.dart';
import 'package:casa_pointage/base_imports.dart';
import '../../../../../core/errors/app_exception.dart';

// Project imports:

class ServerException implements AppException {
  @override
  String toString() => LocaleKeys.server_exception;
}

class CacheException implements AppException {
  @override
  String toString() => LocaleKeys.cache_exception;
}

class HttpException implements AppException {
  final String? message;

  HttpException({this.message});

  @override
  String toString() {
    return message ?? LocaleKeys.server_exception;
  }
}

class TokenException implements AppException {
  @override
  String toString() => LocaleKeys.token_exception;
}

class ForbiddenException implements AppException {
  @override
  String toString() => LocaleKeys.account_not_verified;
}

// class UploadException implements AppException {
//   @override
//   String toString() => LocaleKeys.error_upload_image;
// }

class NotFoundException implements AppException {
  @override
  String toString() => LocaleKeys.not_found_exception;
}

class ConnectivityException implements AppException {
  @override
  String toString() => LocaleKeys.no_connection;
}

class AuthException implements AppException {
  String? message;

  AuthException({this.message});

  @override
  String toString() => message ?? LocaleKeys.auth_exception;
}

class BackendAuthException implements AppException {
  String? message;

  BackendAuthException({this.message});

  @override
  String toString() => message ?? LocaleKeys.auth_exception;
}

class SlowConnectivityException implements AppException {
  @override
  String toString() => LocaleKeys.slow_connectivity_exception;
}

class CustomException implements AppException {
  String? message;

  CustomException({this.message});

  @override
  String toString() => message ?? LocaleKeys.error_general;
}

@lazySingleton
class RemoteException {
  final TOKEN_EXPIRED_CODE_MESSAGE = 'Unauthenticated.';
  final RemoteErrors remoteErrors;

  RemoteException(this.remoteErrors);

  List<RemoteMessageError> get errors => remoteErrors.errors;

  handleRemoteResponse(Future<Response> apiCall) async {
    try {
      final response = await apiCall;
      if (response.statusCode.isSuccessCode) {
        return response.data;
      } else {
        throw DioException(
            response: response, requestOptions: response.requestOptions);
      }
    } on DioError catch (e, stack) {
      final apiUrl =
          '${e.requestOptions.method} ${e.requestOptions.baseUrl}${e.requestOptions.path}';
      // await FirebaseCrashlytics.instance.recordError(
      //     {
      //       'method': e.requestOptions.method,
      //       'path': e.requestOptions.path,
      //       'data': e.requestOptions.data,ript
      //       'headers': e.requestOptions.headers,
      //       'extra': e.requestOptions.extra,
      //       'response': {
      //         'status_code': e.response?.statusCode,
      //         'status_message': e.response?.statusMessage,
      //         'data': e.response?.data,
      //       }
      //     },
      //     stack,
      //     reason: {
      //       'response': {
      //         'status_code': e.response?.statusCode,
      //         'status_message': e.response?.statusMessage,
      //         'data': e.response?.data,
      //       },
      //     });
      /*final context = g.Get.context;
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(
            'GOOGLE-SIGN-In url=${apiUrl} status_code=${e.response?.statusCode} status_message: ${e.response?.statusMessage}'),
      ));*/
      throw handleRemoteException(e: e);
    }
  }

  handleRemoteException(
      {required DioError e, bool skipTokenException = false}) {
    if (e.error is SocketException) throw ConnectivityException();
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout) {
      throw SlowConnectivityException();
    }

    final response = e.response;
    if (response?.data == null || response!.statusCode! >= 500)
      throw ServerException();

    final responseData = response.data;
    final message = responseData['message'];
    if (message != null) {
      if (skipTokenException == false &&
          message == TOKEN_EXPIRED_CODE_MESSAGE) {
        throw TokenException();
      } else {
        final messageError = errors
            .firstWhereOrNull((element) => message == element.codeMessage);
        //messageError != null ? throw HttpException(message: messageError.message) : throw ServerException();
        throw HttpException(
            message: messageError != null ? messageError.message : message);
      }
    } else {
      throw ServerException();
    }
  }
}
