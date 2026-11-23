import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Holds the app language (French / Arabic) and switches it at runtime.
/// Arabic automatically flips the whole UI to right-to-left.
class LocaleController extends GetxService {
  static const fr = Locale('fr');
  static const ar = Locale('ar');

  final locale = fr.obs;

  bool get isArabic => locale.value == ar;

  void setLocale(Locale value) {
    locale.value = value;
    Get.updateLocale(value);
  }

  void toggle() => setLocale(isArabic ? fr : ar);
}
