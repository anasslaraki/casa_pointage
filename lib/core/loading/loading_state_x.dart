import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';

import 'loading_state.dart';

extension LoadingStateRx on Rx<LoadingState?> {
  /// Runs a load: the state is loading, then loaded, or error with the message
  /// of the failure. A [silent] reload keeps the current screen on error.
  Future<void> run(
    Future<void> Function() body, {
    bool silent = false,
  }) async {
    if (!silent) value = const LoadingState.loading();
    try {
      await body();
      value = const LoadingState.loaded();
    } on ApiException catch (e) {
      debugPrint('[LOAD] ${e.message}');
      if (!silent) value = LoadingState.error(message: e.message);
    } catch (e, stack) {
      debugPrint('[LOAD] $e\n$stack');
      if (!silent) value = LoadingState.error(message: '$e');
    }
  }
}
