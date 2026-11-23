import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../theme/app_colors.dart';

/// Short message at the bottom of the screen.
void showAppToast(String message) {
  Get.rawSnackbar(
    message: message,
    backgroundColor: AppColors.ink,
    margin: const EdgeInsets.all(16),
    borderRadius: 14,
    duration: const Duration(milliseconds: 1800),
  );
}

/// Temporary feedback for actions whose screen is not built yet.
void showComingSoon(BuildContext context) =>
    showAppToast(AppLocalizations.of(context).comingSoon);
