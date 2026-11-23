import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';

/// Placeholder of the team tab: header, supervisor card, filters and rows.
class TeamSkeleton extends StatelessWidget {
  const TeamSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ColoredBox(
              color: AppColors.brand,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, topInset + 18.h, 20.w, 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 120, height: 12),
                    SizedBox(height: 10.h),
                    const SkeletonBox(width: 200, height: 22),
                    SizedBox(height: 14.h),
                    const SkeletonBox(height: 8, radius: 4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: const SkeletonRow(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    const SkeletonBox(width: 82, height: 36, radius: 18),
                    SizedBox(width: 8.w),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: const SkeletonBox(height: 48, radius: 14),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Column(
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    const SkeletonRow(),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
