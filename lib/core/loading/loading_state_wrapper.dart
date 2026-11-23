import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import 'loading_state.dart';

/// Shows the right widget for a [LoadingState]: a skeleton while loading, an
/// error with a reload button, or the content once loaded.
class LoadingStateWrapper extends StatelessWidget {
  const LoadingStateWrapper({
    super.key,
    required this.state,
    required this.builder,
    this.onReload,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final LoadingState? state;
  final WidgetBuilder builder;
  final VoidCallback? onReload;

  /// Skeleton shown while loading; a generic list skeleton by default.
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  /// The widget to show while [state] is not loaded, or `null` when the
  /// content itself must be shown. For screens that build their content inline.
  static Widget? placeholder(
    BuildContext context,
    LoadingState? state, {
    VoidCallback? onReload,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? errorBuilder,
    WidgetBuilder? emptyBuilder,
  }) {
    final s = state;
    if (s == null || s is LOADING) {
      return loadingBuilder != null
          ? Builder(builder: loadingBuilder)
          : const SkeletonList();
    }
    if (s is ERROR) {
      return errorBuilder != null
          ? Builder(builder: errorBuilder)
          : LoadErrorView(message: s.message, onReload: onReload);
    }
    if (s is EMPTY && emptyBuilder != null) {
      return Builder(builder: emptyBuilder);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final placeholderWidget = placeholder(
      context,
      state,
      onReload: onReload,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      emptyBuilder: emptyBuilder,
    );
    if (placeholderWidget != null) return placeholderWidget;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Builder(builder: builder),
    );
  }
}

/// Default error state: what failed and a button to try again.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, this.message, this.onReload});

  final String? message;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = message?.trim() ?? '';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44.r, color: AppColors.pending),
            SizedBox(height: 14.h),
            Text(
              l10n.loadErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            if (detail.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                detail,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: AppColors.muted),
              ),
            ],
            if (onReload != null) ...[
              SizedBox(height: 18.h),
              FilledButton(
                onPressed: onReload,
                child: Text(l10n.loadRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
