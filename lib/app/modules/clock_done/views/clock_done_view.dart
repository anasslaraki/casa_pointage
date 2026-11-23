import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/theme/app_theme.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/clock_done_controller.dart';

/// Confirmation shown after a clock-in or clock-out.
class ClockDoneView extends GetView<ClockDoneController> {
  const ClockDoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = controller.args;
    final person = args.person;
    final isArrival = args.kind == ClockKind.arrival;
    final assignmentLine = isArrival &&
            args.assignment.circuit != null &&
            args.assignment.kind != AssignmentKind.supervision
        ? '${args.assignment.kind.label(l10n)} · ${args.assignment.line(l10n)}'
        : null;

    final title = isArrival ? l10n.doneArrival : l10n.doneExit;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 56.h, 28.w, 30.h),
                  child: Column(
                    children: [
                      _Badge(
                        initials: person.initials,
                        isSupervisor: person.isSupervisor,
                        pending: args.pending,
                      ),
                      SizedBox(height: 22.h),
                      Text(
                        person.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        args.method == ClockMethod.manual
                            ? '$title ${l10n.doneManualSuffix}'
                            : title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        ltr(AttendanceRules.formatMinute(args.minute)),
                        style: AppTheme.numberStyle(fontSize: 56.sp)
                            .copyWith(height: 1),
                      ),
                      if (assignmentLine != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          assignmentLine,
                          textAlign: TextAlign.center,
                          style: _mutedStyle(14),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      Text(
                        args.pending ? l10n.doneSavedOffline : l10n.doneSaved,
                        textAlign: TextAlign.center,
                        style: _mutedStyle(14.5),
                      ),
                      const Spacer(),
                      SizedBox(height: 24.h),
                      _NextButton(
                        label: l10n.doneNext,
                        onPressed: controller.clockNext,
                      ),
                      SizedBox(height: 12.h),
                      AppButton(
                        variant: AppButtonVariant.ghost,
                        height: 54.h,
                        fontSize: 16.sp,
                        label: l10n.doneBack,
                        onPressed: controller.backToTeam,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _mutedStyle(double size) => TextStyle(
        fontSize: size.sp,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );
}

/// Big avatar with a status badge: green check, or a "waiting for network"
/// cloud when the record is only stored on the phone.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.initials,
    required this.isSupervisor,
    required this.pending,
  });

  final String initials;
  final bool isSupervisor;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PersonAvatar(
          initials: initials,
          isSupervisor: isSupervisor,
          size: 104.r,
          ring: true,
        ),
        PositionedDirectional(
          end: -4,
          bottom: -4,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pending ? AppColors.acc : AppColors.ok,
                border: Border.all(color: Colors.white, width: 4),
              ),
              alignment: Alignment.center,
              child: AppIcon(
                pending ? AppIcons.cloudOff : AppIcons.check,
                color: pending ? AppColors.ink : Colors.white,
                size: 20.r,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.acc,
          foregroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              AppIcons.scanFace,
              color: AppColors.ink,
              size: 24.r,
              strokeWidth: 2.2,
            ),
            SizedBox(width: 10.w),
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
