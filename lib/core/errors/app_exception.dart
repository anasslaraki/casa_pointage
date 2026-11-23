// Project imports:
import 'package:casa_pointage/generated/locales.g.dart';

class AppException implements Exception {
  @override
  String toString() => LocaleKeys.error_general;
}
