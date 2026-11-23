import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rounded selectable chip, with an optional counter (`.chip` in the prototype).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.height = 40,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final double height;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.ink;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.ink : AppColors.line,
            width: 2,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: height.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(width: 6.w),
                  Opacity(
                    opacity: 0.75,
                    child: Text(
                      '$count',
                      style: AppTheme.numberStyle(
                        fontSize: 15.sp,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
