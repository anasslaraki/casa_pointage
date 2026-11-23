import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/core/theme/app_colors.dart';

/// Moving highlight over the grey blocks placed inside it. Every opaque block
/// of [child] is painted with the animated gradient.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          final t = _animation.value;
          return LinearGradient(
            begin: Alignment(-1.5 + 3 * t, -0.3),
            end: Alignment(-0.5 + 3 * t, 0.3),
            colors: const [
              AppColors.soft,
              Color(0xFFF6F7F8),
              AppColors.soft,
            ],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }
}

/// A grey rounded block, to be placed inside a [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.soft,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// A card-like row: avatar, two text lines and a pill, like the lists of the app.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 44, height: 44, circle: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: 8.h),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
          SkeletonBox(width: 62, height: 24, radius: 12),
        ],
      ),
    );
  }
}

/// Placeholder of a list screen.
/// A few skeleton rows, for the rows of a list while the page loads.
class SkeletonRows extends StatelessWidget {
  const SkeletonRows({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            const SkeletonRow(),
          ],
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 7, this.padding});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (_, _) => const SkeletonRow(),
      ),
    );
  }
}
