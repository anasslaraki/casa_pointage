import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Initials avatar. The supervisor is olive, a green badge marks an enrolled
/// face, and [ring] draws the "clocked in" green ring.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.initials,
    this.isSupervisor = false,
    this.enrolled = false,
    this.size = 44,
    this.ring = false,
  });

  final String initials;
  final bool isSupervisor;
  final bool enrolled;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSupervisor ? AppColors.brand : AppColors.soft,
              boxShadow: ring
                  ? const [
                      BoxShadow(color: Colors.white, spreadRadius: 3),
                      BoxShadow(color: AppColors.ok, spreadRadius: 5),
                    ]
                  : null,
            ),
            child: Text(
              initials,
              style: AppTheme.numberStyle(
                fontSize: size * 0.38,
                color: isSupervisor ? Colors.white : AppColors.ink2,
              ).copyWith(fontWeight: FontWeight.w800, height: 1),
            ),
          ),
          if (enrolled)
            PositionedDirectional(
              end: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.ok,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.face,
                  color: Colors.white,
                  size: 11,
                  strokeWidth: 2.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
