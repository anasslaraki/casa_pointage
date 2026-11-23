import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/data/face/head_turn_liveness.dart';
import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_chip.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/scan_controller.dart';
import '../widgets/oval_camera_preview.dart';
import '../widgets/scan_ring.dart';

const _screenBackground = Color(0xFF0E1310);
const _softGreen = Color(0xFFC9D4B8);

/// Face scan: camera in an oval, then the recognized person to confirm.
class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _screenBackground,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Header(controller: controller),
                      _Viewfinder(
                        controller: controller,
                        availableHeight: constraints.maxHeight,
                      ),
                      _BottomArea(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ScanController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      child: Row(
        children: [
          _RoundIconButton(
            icon: AppIcons.close,
            label: l10n.scanClose,
            onTap: controller.close,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() {
              final shift = controller.shift.value;
              final sector = controller.sector.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.mode == ScanMode.self
                        ? l10n.teamClockMe
                        : l10n.scanTitleTeam,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (shift != null && sector != null)
                    Text(
                      '${shift.kind.label(l10n)} · ${sector.depotName}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: const Color(0xFFAFC09A),
                      ),
                    ),
                ],
              );
            }),
          ),
          SizedBox(width: 12.w),
          _RoundIconButton(
            icon: AppIcons.flipCamera,
            label: l10n.scanFlipCamera,
            onTap: controller.flipCamera,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppIcons icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 44.r,
            child: Center(
              child: AppIcon(
                icon,
                color: Colors.white,
                size: 22.r,
                strokeWidth: 2.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Oval camera and the instruction texts under it.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.controller, required this.availableHeight});

  final ScanController controller;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Shrinks the oval on short screens so the confirmation card still fits.
    final scale = ((availableHeight - 400) / 380).clamp(0.6, 1.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ovalWidth = math.min(310 * scale, screenWidth - 48);
    final ovalHeight = 380 * scale;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Obx(() {
          final phase = controller.phase.value;
          final frameHint = switch (controller.hint.value) {
            FaceHint.multipleFaces => l10n.faceHintMultiple,
            FaceHint.tooFar => l10n.faceHintTooFar,
            FaceHint.tooClose => l10n.faceHintTooClose,
            FaceHint.notCentered => l10n.faceHintCenter,
            FaceHint.headTurned => l10n.faceHintStraight,
            FaceHint.lowLight => l10n.faceHintLight,
            _ => null,
          };
          final liveHint = switch (controller.liveStep.value) {
            HeadTurnStep.firstSide => l10n.scanTurnFirst,
            HeadTurnStep.otherSide => l10n.scanTurnSecond,
            _ => l10n.faceHintStraight,
          };
          final (title, hint) = switch (phase) {

            ScanPhase.detect => (
                l10n.scanDetectTitle,
                frameHint ?? l10n.scanDetectHint,
              ),
            ScanPhase.analyse => (l10n.scanAnalyseTitle, l10n.scanAnalyseHint),
            ScanPhase.live => (l10n.scanLiveTitle, liveHint),
            ScanPhase.matched => (l10n.faceRecognized, ''),
            ScanPhase.failed => (l10n.scanFailedTitle, l10n.scanFailedHint),
          };
          final ringColor = switch (phase) {
            ScanPhase.matched => AppColors.ok,
            ScanPhase.failed => AppColors.absent,
            _ => AppColors.acc,
          };

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ovalWidth,
                height: ovalHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Obx(
                        () => OvalCameraPreview(
                          lens: controller.lens.value,
                          width: ovalWidth,
                          height: ovalHeight,
                          onFrame: controller.onFrame,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ScanRing(
                        color: ringColor,
                        dashed: phase == ScanPhase.detect ||
                            phase == ScanPhase.analyse,
                        animate: phase == ScanPhase.analyse,
                      ),
                    ),
                    if (phase == ScanPhase.matched)
                      Center(child: _MatchedMark(size: 84 * scale)),
                    if (phase == ScanPhase.live)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Center(child: _TurnHint(text: liveHint)),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (hint.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: _softGreen),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

/// Start and end of the circuit of the day, on the confirmation card.
class _ShiftTimes extends StatelessWidget {
  const _ShiftTimes({required this.start, required this.end});

  final int start;
  final int end;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget cell(String label, int minute) => Expanded(
          child: Row(
            children: [
              AppIcon(AppIcons.clock, color: AppColors.brand, size: 20.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      ltr(AttendanceRules.formatMinute(minute)),
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          cell(l10n.personShiftStart, start),
          SizedBox(width: 10.w),
          cell(l10n.personShiftEnd, end),
        ],
      ),
    );
  }
}

class _MatchedMark extends StatelessWidget {
  const _MatchedMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.ok,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppIcon(
          AppIcons.check,
          color: Colors.white,
          size: size * 0.55,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _TurnHint extends StatelessWidget {
  const _TurnHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIcons.eye, color: AppColors.acc, size: 16.r, strokeWidth: 2.2),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({required this.controller});

  final ScanController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Obx(() {
      switch (controller.phase.value) {
        case ScanPhase.matched:
          final result = controller.result.value;
          if (result == null) return const SizedBox.shrink();
          return _ResultCard(controller: controller, result: result);
        case ScanPhase.failed:
          return Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 26.h + bottomInset),
            child: Column(
              children: [
                AppButton(
                  variant: AppButtonVariant.accent,
                  height: 72.h,
                  fontSize: 20.sp,
                  label: l10n.scanRetry,
                  onPressed: controller.startScan,
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    onPressed: controller.openManual,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      textStyle: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: AppIcon(
                      AppIcons.edit,
                      color: Colors.white,
                      size: 20.r,
                    ),
                    label: Text(l10n.scanManual),
                  ),
                ),
              ],
            ),
          );
        default:
          return Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 26.h + bottomInset),
            child: _LinkButton(
              text: l10n.scanManualLink,
              color: _softGreen,
              onTap: controller.openManual,
            ),
          );
      }
    });
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.text,
    required this.onTap,
    this.color = AppColors.ink,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: color,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}

/// The recognized person with the data to confirm.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.controller, required this.result});

  final ScanController controller;
  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = result.person;
    final isArrival = result.kind == ClockKind.arrival;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final assignmentLine = result.assignment.line(l10n);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.ink),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PersonAvatar(
                  initials: person.initials,
                  isSupervisor: person.isSupervisor,
                  size: 54.r,
                  ring: true,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${person.matricule} · ${person.functionLabel(l10n)}',
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
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.okSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.scanMatchScore(result.score),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ok,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _Where(controller: controller),
            if (isArrival &&
                result.assignment.kind != AssignmentKind.supervision) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    AppIcon(AppIcons.pin, color: AppColors.brand, size: 20.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.scanAssignment,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            result.assignment.kind.label(l10n),
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (assignmentLine != null)
                            Text(
                              assignmentLine,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isArrival &&
                person.shiftStartMinute != null &&
                person.shiftEndMinute != null) ...[
              SizedBox(height: 12.h),
              _ShiftTimes(
                start: person.shiftStartMinute!,
                end: person.shiftEndMinute!,
              ),
            ],
            if (isArrival && result.isLate) ...[
              SizedBox(height: 12.h),
              Text(
                l10n.scanLateBy(l10n.lateAmountOf(result.lateMinutes)),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.late,
                ),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  for (final reason in controller.lateReasons)
                    AppChip(
                      label: reason,
                      height: 36,
                      selected: result.lateReason == reason,
                      onTap: () => controller.selectLateReason(reason),
                    ),
                ],
              ),
            ],
            SizedBox(height: 14.h),
            Obx(() {
              final time = ltr(
                AttendanceRules.formatMinute(
                  AttendanceRules.minuteOfDay(controller.now.value),
                ),
              );
              return SizedBox(
                height: 72.h,
                child: FilledButton(
                  onPressed: controller.saving.value ? null : controller.confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isArrival ? AppColors.acc : AppColors.ink,
                    foregroundColor: isArrival ? AppColors.ink : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: controller.saving.value
                      ? SizedBox.square(
                          dimension: 28.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: isArrival ? AppColors.ink : Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              isArrival ? AppIcons.login : AppIcons.logout,
                              color: isArrival ? AppColors.ink : Colors.white,
                              size: 24.r,
                              strokeWidth: 2.4,
                            ),
                            SizedBox(width: 10.w),
                            Flexible(
                              child: Text(
                                isArrival
                                    ? l10n.scanConfirmArrival(time)
                                    : l10n.scanConfirmExit(time),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
            SizedBox(height: 4.h),
            Center(
              child: _LinkButton(
                text: l10n.scanNotThisPerson,
                onTap: controller.openManual,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Place and time of the clock-in.
class _Where extends StatelessWidget {
  const _Where({required this.controller});

  final ScanController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );

    return Obx(() {
      final depot = controller.sector.value?.depotName ?? '';
      final time = ltr(
        AttendanceRules.formatMinute(
          AttendanceRules.minuteOfDay(controller.now.value),
        ),
      );
      return Row(
        children: [
          AppIcon(AppIcons.pin, color: AppColors.ok, size: 15.r, strokeWidth: 2.2),
          SizedBox(width: 5.w),
          // TODO: switch to scanOutsideDepot once geolocation is wired.
          Text(l10n.scanAtDepot(depot), style: style),
          SizedBox(width: 10.w),
          Text('·', style: style),
          SizedBox(width: 10.w),
          AppIcon(AppIcons.clock, color: AppColors.muted, size: 15.r, strokeWidth: 2.2),
          SizedBox(width: 5.w),
          Text(time, style: style),
        ],
      );
    });
  }
}
