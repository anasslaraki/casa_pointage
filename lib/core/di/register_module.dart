import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../app/data/api/api_config.dart';
import '../../app/data/api/api_logger.dart';

/// Third-party objects the generated container cannot build by itself.
@module
abstract class RegisterModule {
  @singleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @singleton
  Connectivity get connectivity;

  @lazySingleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    if (kDebugMode) dio.interceptors.add(ApiLogInterceptor());
    return dio;
  }
}
