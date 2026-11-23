import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

enum AppButtonVariant { primary, accent, ghost, danger }

/// Large, outdoor-readable button (`.btn` in the prototype).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.height,
    this.fontSize,
    this.icon,
    this.radius = 14,
  });

  final AppIcons? icon;
  final double radius;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      AppButtonVariant.primary => (AppColors.ink, Colors.white),
      AppButtonVariant.accent => (AppColors.acc, AppColors.ink),
      AppButtonVariant.ghost => (Colors.white, AppColors.ink),
      AppButtonVariant.danger => (AppColors.absent, Colors.white),
    };

    return SizedBox(
      width: double.infinity,
      height: height ?? 56.h,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.5),
          disabledForegroundColor: foreground.withValues(alpha: 0.7),
          side: variant == AppButtonVariant.ghost
              ? const BorderSide(color: AppColors.line, width: 2)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.r),
          ),
          textStyle: TextStyle(
            fontSize: fontSize ?? 17.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox.square(
                dimension: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foreground,
                ),
              ),
              SizedBox(width: 10.w),
            ],
            if (icon != null && !loading) ...[
              AppIcon(icon!, color: foreground, size: 21.r, strokeWidth: 2.2),
              SizedBox(width: 10.w),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
