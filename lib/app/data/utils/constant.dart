// Dart imports:

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

class Constant {
  /// TODO
  static String urlPrivacy = 'https://www.google.com/';

  /// TODO
  static String urlTos = 'https://www.google.com/';

  /// TODO
  static String urlAboutUs = 'https://www.google.com/';

  /// TODO
  static String supportEmail = '';

  static Duration timeout = const Duration(seconds: 8);

  /// TODO
  static var hostUrl = '';

  static String get remoteUrl => kDebugMode ? 'https://a16f939f-203e-40c2-9e61-7d714955770c.mock.pstmn.io' : hostUrl;

  static const Duration soFastAnimationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 500);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 700);
  static const Duration longAnimationDuration = Duration(seconds: 1);
  static const Duration slowAnimationDuration = Duration(seconds: 1, milliseconds: 500);

  // or new Dio with a BaseOptions instance.
  static final BaseOptions options = BaseOptions(
    baseUrl: remoteUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 6),
  );

  // TODO:
  static String googlePlayAppLink = '';

  // TODO:
  static String appStoreAppLink = '';

  static String get shareAppLink {
    if (Platform.isAndroid) {
      return googlePlayAppLink;
    } else {
      return appStoreAppLink;
    }
  }

  static String? openedNotificationPayload;

  // DURATION FOR ENTRY ANIMATIONS
  static const int durationMilliseconds = 200;
  static const Duration duration1 = Duration(milliseconds: durationMilliseconds);
  static const Duration duration2 = Duration(milliseconds: durationMilliseconds * 2);
  static const Duration duration3 = Duration(milliseconds: durationMilliseconds * 3);
  static const Duration duration4 = Duration(milliseconds: durationMilliseconds * 4);
  static const Duration duration5 = Duration(milliseconds: durationMilliseconds * 5);
  static const Duration duration6 = Duration(milliseconds: durationMilliseconds * 6);
  static const Duration duration7 = Duration(milliseconds: durationMilliseconds * 7);
}
