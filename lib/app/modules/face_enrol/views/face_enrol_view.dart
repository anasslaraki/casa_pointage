import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/modules/scan/widgets/oval_camera_preview.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/face_enrol_controller.dart';

const _screenBackground = Color(0xFF0E1310);
const _softGreen = Color(0xFFC9D4B8);

/// Face enrolment: the person agrees, then two slow head turns.
class FaceEnrolView extends GetView<FaceEnrolController> {
  const FaceEnrolView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.phase.value == EnrolPhase.consent) {
        return _ConsentPage(controller: controller);
      }
      return _CapturePage(controller: controller);
    });
  }
}

// ---------------------------------------------------------------- consent

/// The consent page, laid out like the prototype: green header, the person,
/// what the enrolment means, the checkbox and a big "Commencer".
class _ConsentPage extends StatelessWidget {
  const _ConsentPage({required this.controller});

  final FaceEnrolController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            ColoredBox(
              color: AppColors.brand,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, topInset + 16.h, 20.w, 12.h),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.scanClose,
                      excludeSemantics: true,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: controller.close,
                          child: SizedBox.square(
                            dimension: 44.r,
                            child: Center(
                              child: AppIcon(
                                AppIcons.chevronLeft,
                                color: Colors.white,
                                size: 22.r,
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() {
                        final person = controller.person.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.enrolConsentTitle,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (person != null)
                              Text(
                                '${person.name} · ${person.matricule}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandText,
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                children: [
                  Obx(() {
                    final person = controller.person.value;
                    if (person == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        PersonAvatar(
                          initials: person.initials,
                          isSupervisor: person.isSupervisor,
                          size: 64.r,
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person.name,
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${person.matricule} · '
                                '${person.functionLabel(l10n)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                              if (controller.delegate.value.isNotEmpty)
                                Text(
                                  controller.delegate.value,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        _Bullet(AppIcons.face, l10n.enrolConsentFace),
                        SizedBox(height: 12.h),
                        _Bullet(AppIcons.shield, l10n.enrolConsentShield),
                        SizedBox(height: 12.h),
                        _Bullet(AppIcons.lock, l10n.enrolConsentLock),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _ConsentCheck(controller: controller),
                  Obx(() {
                    if (!controller.consentMissing.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        l10n.enrolConsentRequired,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.absent,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  AppButton(
                    variant: AppButtonVariant.accent,
                    height: 72.h,
                    fontSize: 20.sp,
                    radius: 18,
                    icon: AppIcons.scanFace,
                    label: l10n.enrolBegin,
                    onPressed: controller.begin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.icon, this.text);

  final AppIcons icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon, color: AppColors.brand, size: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5.sp,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// The agreement checkbox: ticking it is required to start.
class _ConsentCheck extends StatelessWidget {
  const _ConsentCheck({required this.controller});

  final FaceEnrolController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      final checked = controller.consent.value;
      final text = controller.person.value?.isSupervisor ?? false
          ? l10n.enrolConsentSelf
          : l10n.enrolConsentTeam;

      return Semantics(
        checked: checked,
        child: InkWell(
          onTap: controller.toggleConsent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.ink : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: checked ? AppColors.ink : const Color(0xFFA0A7AF),
                      width: 2,
                    ),
                  ),
                  child: checked
                      ? Center(
                          child: AppIcon(
                            AppIcons.check,
                            color: Colors.white,
                            size: 16.r,
                            strokeWidth: 3,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------- capture

class _CapturePage extends StatelessWidget {
  const _CapturePage({required this.controller});

  final FaceEnrolController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _screenBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Shrinks the circle on short screens.
              final scale = ((constraints.maxHeight - 260) / 340).clamp(0.6, 1.0);
              final ring = math.min(340 * scale, constraints.maxWidth - 32);

              return DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  children: [
                    _Header(controller: controller),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: _Body(controller: controller, ring: ring),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.phase.value != EnrolPhase.done) {
                        return SizedBox(height: 24.h);
                      }
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                        child: AppButton(
                          variant: AppButtonVariant.accent,
                          height: 64.h,
                          fontSize: 19.sp,
                          label: l10n.enrolFinish,
                          onPressed: controller.close,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final FaceEnrolController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget button(AppIcons icon, String label, VoidCallback onTap) {
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

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 8.h),
      child: Row(
        children: [
          button(AppIcons.close, l10n.scanClose, controller.close),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() {
              final person = controller.person.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.faceEnrolTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (person != null)
                    Text(
                      '${person.name} · ${person.matricule}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: const Color(0xFFAFC09A),
                      ),
                    ),
                ],
              );
            }),
          ),
          Obx(() {
            if (controller.phase.value == EnrolPhase.done) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsetsDirectional.only(start: 12.w),
              child: button(
                AppIcons.flipCamera,
                l10n.scanFlipCamera,
                controller.flipCamera,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.ring});

  final FaceEnrolController controller;
  final double ring;

  @override
  Widget build(BuildContext context) {
    return Obx(() => _content(context));
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = controller.phase.value;
    final done = phase == EnrolPhase.done;
    final full = done || phase == EnrolPhase.mid || phase == EnrolPhase.saving;
    final inner = ring * 256 / 300;

    final (title, subtitle) = switch (phase) {
      EnrolPhase.scan1 => (l10n.enrolScanMove, l10n.enrolScanCircle),
      EnrolPhase.mid => (l10n.enrolScanFirstDone, l10n.enrolScanOneMore),
      EnrolPhase.scan2 => (l10n.enrolScanMove, l10n.enrolScanCircleAgain),
      EnrolPhase.saving => (l10n.enrolSaving, ''),
      EnrolPhase.done => (l10n.enrolSaved, l10n.enrolSentHr),
      EnrolPhase.consent => ('', ''),
    };

    final frameHint = switch (controller.hint.value) {
      FaceHint.noFace => l10n.scanDetectTitle,
      FaceHint.multipleFaces => l10n.faceHintMultiple,
      FaceHint.tooFar => l10n.faceHintTooFar,
      FaceHint.tooClose => l10n.faceHintTooClose,
      FaceHint.notCentered => l10n.faceHintCenter,
      FaceHint.headTurned => l10n.faceHintStraight,
      FaceHint.lowLight => l10n.faceHintLight,
      FaceHint.none => null,
    };
    final capturing = controller.capturing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ring,
            height: ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (done)
                  Container(
                    width: inner,
                    height: inner,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2A17),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 110 * ring / 300,
                      height: 110 * ring / 300,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CD964),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppIcon(
                        AppIcons.check,
                        color: _screenBackground,
                        size: 64 * ring / 300,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                else
                  OvalCameraPreview(
                    lens: controller.lens.value,
                    width: inner,
                    height: inner,
                    onFrame: controller.onFrame,
                  ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TickRing(
                      progress: full ? 1 : controller.progress.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, color: _softGreen),
            ),
          ],
          if (capturing && frameHint != null) ...[
            SizedBox(height: 10.h),
            Text(
              frameHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.acc,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The ring of ticks around the camera, lit as the scan advances.
class _TickRing extends CustomPainter {
  const _TickRing({required this.progress});

  final double progress;

  static const _ticks = 60;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.9;
    final lit = (progress * _ticks).round();

    final on = Paint()
      ..color = AppColors.acc
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final off = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < _ticks; i++) {
      // Starts at the top and goes clockwise.
      final angle = -math.pi / 2 + i * 2 * math.pi / _ticks;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * inner,
        center + dir * outer,
        i < lit ? on : off,
      );
    }
  }

  @override
  bool shouldRepaint(_TickRing old) => old.progress != progress;
}
