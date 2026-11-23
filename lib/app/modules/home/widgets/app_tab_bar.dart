import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/home_controller.dart';

/// Bottom bar: 4 tabs around the raised "clock in" button.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onClockIn,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelect;
  final VoidCallback onClockIn;

  /// Height of the bar without the system inset.
  static double get height => 80.h;

  /// How far the clock-in button rises above the bar.
  static const double _raise = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final tabs = <(HomeTab, AppIcons, String)>[
      (HomeTab.team, AppIcons.users, l10n.tabTeam),
      (HomeTab.enrolment, AppIcons.face, l10n.tabEnrolment),
      (HomeTab.history, AppIcons.history, l10n.tabHistory),
      (HomeTab.profile, AppIcons.user, l10n.tabProfile),
    ];

    Widget item((HomeTab, AppIcons, String) t) => Expanded(
          child: _TabItem(
            icon: t.$2,
            label: t.$3,
            selected: selected == t.$1,
            onTap: () => onSelect(t.$1),
          ),
        );

    return SizedBox(
      height: height + bottomInset + _raise,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: height + bottomInset,
            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 16.h + bottomInset),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Semantics(
              container: true,
              label: l10n.tabsLabel,
              child: Row(
                children: [
                  item(tabs[0]),
                  item(tabs[1]),
                  SizedBox(width: 80.w),
                  item(tabs[2]),
                  item(tabs[3]),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: bottomInset + height - 60.h,
            child: _ClockInButton(
              label: l10n.tabClockIn,
              semanticLabel: l10n.tabClockInSemantic,
              onTap: onClockIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppIcons icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.pending;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(height: 9.h),
            Container(
              width: 58.w,
              height: 30.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.acc : Colors.transparent,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: AppIcon(
                icon,
                color: color,
                size: 22.r,
                strokeWidth: selected ? 2.2 : 1.9,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockInButton extends StatelessWidget {
  const _ClockInButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.acc,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x593B4B24),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: AppIcon(
                  AppIcons.scanFace,
                  color: AppColors.ink,
                  size: 32.r,
                  strokeWidth: 2.1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
