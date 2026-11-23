import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Keeps the phone layout on any screen: the app is designed at 390dp wide,
/// and on larger screens (tablets, desktop, landscape) it stays centered in a
/// column of at most [maxWidth]. Sizes then scale from that column's width.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});

  final Widget? child;

  static const double maxWidth = 480;
  static const Size designSize = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width, maxWidth);

    return ColoredBox(
      color: AppColors.stage,
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: media.copyWith(size: Size(width, media.size.height)),
            child: Builder(
              builder: (context) {
                ScreenUtil.init(
                  context,
                  designSize: designSize,
                  minTextAdapt: true,
                );
                return child ?? const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
