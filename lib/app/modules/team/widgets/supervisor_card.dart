import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/core/widgets/status_pill.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/team_controller.dart';

/// The supervisor's own status card, overlapping the header.
class SupervisorCard extends StatelessWidget {
  const SupervisorCard({
    super.key,
    required this.me,
    required this.onClockIn,
    required this.onClockOut,
    required this.onEnrol,
  });

  final TeamMember me;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onEnrol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = me.state;
    final needsEnrol = state.status == DayStatus.notEnrolled;
    final waiting = needsEnrol ||
        state.status == DayStatus.notClocked ||
        state.status == DayStatus.overdue;

    final shadow = [
      BoxShadow(
        color: const Color(0x1A0A0F14),
        blurRadius: 26.r,
        offset: Offset(0, 10.h),
      ),
    ];

    if (waiting) {
      return Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.acc, width: 2),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: shadow,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: needsEnrol ? onEnrol : onClockIn,
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  PersonAvatar(
                    initials: me.person.initials,
                    isSupervisor: true,
                    enrolled: state.enrolled,
                    size: 46.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.teamMeNotClockedIn,
                          style: TextStyle(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.teamMeClockBeforeTeam,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: AppColors.acc,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.scanFace,
                          color: AppColors.ink,
                          size: 20.r,
                          strokeWidth: 2.2,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          l10n.teamClockMe,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final times = [
      if (state.arrival != null)
        l10n.teamMeArrival(AttendanceRules.formatMinute(state.arrival!.minute)),
      if (state.exit != null)
        l10n.teamMeExit(AttendanceRules.formatMinute(state.exit!.minute)),
    ].join(' · ');

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
        boxShadow: shadow,
      ),
      child: Row(
        children: [
          PersonAvatar(
            initials: me.person.initials,
            isSupervisor: true,
            enrolled: state.enrolled,
            size: 46.r,
            ring: true,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.teamMeClockedIn,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (times.isNotEmpty)
                  Text(
                    times,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (state.isInside)
            Material(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: onClockOut,
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.logout,
                        color: Colors.white,
                        size: 18.r,
                        strokeWidth: 2.2,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.teamClockMyExit,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            StatusPill.status(context, state.status),
        ],
      ),
    );
  }
}
