import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/core/widgets/status_pill.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/team_controller.dart';

/// One person of the team with their status of the day.
class MemberRow extends StatelessWidget {
  const MemberRow({
    super.key,
    required this.member,
    this.onTap,
    this.showChevron = true,
  });

  final TeamMember member;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = member.person;
    final state = member.state;
    final detail = _detail(l10n, state);
    final isManual = state.arrival?.method == ClockMethod.manual;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              PersonAvatar(
                initials: person.initials,
                enrolled: state.enrolled,
                size: 44.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.isSupervisor
                          ? '${person.name} ${l10n.enrolYou}'
                          : person.name,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${person.matricule} · ${person.functionLabel(l10n)}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill.status(context, state.status),
                        if (detail != null) _Muted(detail),
                        if (isManual) _Muted('· ${l10n.teamManualTag}'),
                        if (state.hasPending) StatusPill.pendingSync(context),
                      ],
                    ),
                  ],
                ),
              ),
              if (showChevron)
                AppIcon(
                  AppIcons.chevronRight,
                  color: const Color(0xFF9AA1A9),
                  size: 20.r,
                  strokeWidth: 2.2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _detail(AppLocalizations l10n, DayState state) {
    final arrival = state.arrival;
    if (arrival != null) {
      final from = AttendanceRules.formatMinute(arrival.minute);
      final exit = state.exit;
      return exit != null
          ? ltr('$from → ${AttendanceRules.formatMinute(exit.minute)}')
          : arrival.isLate == true && arrival.lateMinutes > 0
              ? l10n.teamArrivedLate(
                  ltr(from),
                  l10n.lateAmountOf(arrival.lateMinutes),
                )
              : l10n.teamArrivedAt(ltr(from));
    }
    final reason = state.absence?.absenceReason;
    return reason;
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );
  }
}
