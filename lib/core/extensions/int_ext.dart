extension IntExt on int? {
  bool get isSuccessCode {
    if (this == null) return false;
    final int value = this!;
    return value >= 200 && value < 300 ? true : false;
  }
}
