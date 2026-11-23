import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

/// Sync state shown in the header: synced, items waiting, or offline.
class SyncChip extends StatelessWidget {
  const SyncChip({
    super.key,
    required this.online,
    required this.pending,
    this.onTap,
  });

  final bool online;
  final int pending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final (icon, iconColor, label, background, textColor) = !online
        ? (
            AppIcons.cloudOff,
            AppColors.acc,
            pending > 0 ? l10n.syncOfflinePending(pending) : l10n.syncOffline,
            AppColors.brandDark,
            AppColors.acc,
          )
        : pending > 0
            ? (
                AppIcons.refresh,
                AppColors.acc,
                l10n.syncPending(pending),
                AppColors.brandDark,
                AppColors.acc,
              )
            : (
                AppIcons.check,
                const Color(0xFFB9E08F),
                l10n.syncDone,
                Colors.white.withValues(alpha: 0.12),
                const Color(0xFFDCEBC9),
              );

    return Material(
      color: background,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, color: iconColor, size: 15.r, strokeWidth: 2.5),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
