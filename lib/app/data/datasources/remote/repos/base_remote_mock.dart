// Project imports:
import 'package:casa_pointage/core/errors/app_exception.dart';

class BaseMockRemoteRepo {
  final Duration delay;

  BaseMockRemoteRepo({this.delay = const Duration(seconds: 1)});

  Future<T> returnWithDelay<T>(T value) {
    return Future.delayed(delay).then((_) => value);
  }

  Future<T> throwWithDelay<T>(error) {
    return Future<T>.delayed(delay).then((value) => throw error);
  }

  Future<T> throwAppFatal<T>() {
    return throwWithDelay(AppException());
  }
}
