// Flutter imports:

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

T? getEnumValueByString<T>(List<T> enumValues, String? value, {T? defaultValue}) {
  if (value == null) {
    return defaultValue;
  }
  value = value.toUpperCase();
  return enumValues.firstWhereOrNull((e) => getEnumStringValue<T>(e) == value) ?? defaultValue;
}

String getEnumString<T>(T value, {bool lowerCaseKey = false}) => value != null
    ? lowerCaseKey
        ? describeEnum(value).toLowerCase()
        : describeEnum(value)
    : '';

String? getEnumStringTranslated<T>(T? value) {
  if (value != null) {
    try {
      return describeEnum(value).toLowerCase().tr;
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}

String? getEnumStringValue<T>(T? enumValue, {bool lowerCaseKey = false}) {
  if (enumValue == null) return null;
  var stringValue = describeEnum(enumValue);
  return lowerCaseKey == true ? stringValue.toLowerCase() : stringValue.toUpperCase();
}
