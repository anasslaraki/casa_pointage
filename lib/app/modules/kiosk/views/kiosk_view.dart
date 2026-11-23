import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/app/data/face/face_analyzer.dart';
import 'package:casa_pointage/app/data/face/head_turn_liveness.dart';
import 'package:casa_pointage/app/data/models/kiosk_result.dart';
import 'package:casa_pointage/app/modules/scan/widgets/oval_camera_preview.dart';
import 'package:casa_pointage/app/modules/scan/widgets/scan_ring.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/kiosk_controller.dart';

const _screenBackground = Color(0xFF0E1310);
const _softGreen = Color(0xFFC9D4B8);

/// The only screen of a kiosk account: camera, instructions and the result of
/// the pointage.
class KioskView extends GetView<KioskController> {
  const KioskView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _screenBackground,
        body: SafeArea(
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Column(
              children: [
                _Header(controller: controller),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: _Viewfinder(
                            controller: controller,
                            availableHeight: constraints.maxHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final KioskController controller;

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileLogoutTitle),
        content: Text(l10n.profileLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileLogoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 8.h),
      child: Row(
        children: [
          _RoundIconButton(
            icon: AppIcons.logout,
            label: l10n.profileLogoutConfirm,
            onTap: () => _confirmLogout(context),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.kioskTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (controller.depots.isNotEmpty)
                  Text(
                    controller.depots,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: const Color(0xFFAFC09A),
                    ),
                  ),
              ],
            ),
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

/// Oval camera and, under it, what to do or what happened.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.controller, required this.availableHeight});

  final KioskController controller;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Same size as the pointage scan, smaller on short screens.
    final scale = ((availableHeight - 200) / 380).clamp(0.6, 1.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ovalWidth = math.min(310 * scale, screenWidth - 48);
    final ovalHeight = 380 * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Obx(() {
        final phase = controller.phase.value;
        final result = controller.result.value;

        final frameHint = switch (controller.hint.value) {
          FaceHint.multipleFaces => l10n.faceHintMultiple,
          FaceHint.tooFar => l10n.faceHintTooFar,
          FaceHint.tooClose => l10n.faceHintTooClose,
          FaceHint.notCentered => l10n.faceHintCenter,
          FaceHint.headTurned => l10n.faceHintStraight,
          FaceHint.lowLight => l10n.faceHintLight,
          _ => null,
        };
        final turnHint = switch (controller.liveStep.value) {
          HeadTurnStep.firstSide => l10n.scanTurnFirst,
          HeadTurnStep.otherSide => l10n.scanTurnSecond,
          _ => l10n.faceHintStraight,
        };

        final noFaces = controller.knownFaces.value == 0;
        final loadError = controller.loadError.value;

        final (title, hint) = switch (phase) {
          KioskPhase.loading => (l10n.kioskLoading, ''),
          KioskPhase.detect => (
              l10n.scanDetectTitle,
              loadError.isNotEmpty
                  ? loadError
                  : noFaces
                      ? l10n.kioskNoFaces
                      : frameHint ?? l10n.scanDetectHint,
            ),
          KioskPhase.analyse => (l10n.scanAnalyseTitle, l10n.scanAnalyseHint),
          KioskPhase.live => (l10n.scanLiveTitle, turnHint),
          KioskPhase.sending => (l10n.kioskSending, ''),
          KioskPhase.done => ('', ''),
          KioskPhase.failed => (
              controller.failureMessage.value.isEmpty
                  ? l10n.kioskNotRecognised
                  : controller.failureMessage.value,
              '',
            ),
        };
        final ringColor = switch (phase) {
          KioskPhase.done => AppColors.ok,
          KioskPhase.failed => AppColors.absent,
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
                      dashed: phase == KioskPhase.detect ||
                          phase == KioskPhase.analyse ||
                          phase == KioskPhase.loading,
                      animate: phase == KioskPhase.analyse ||
                          phase == KioskPhase.sending,
                    ),
                  ),
                  if (phase == KioskPhase.done)
                    Center(child: _DoneMark(size: 84 * scale)),
                  if (phase == KioskPhase.live)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Center(child: _TurnHint(text: turnHint)),
                    ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            if (phase == KioskPhase.done && result != null)
              _ResultCard(result: result)
            else ...[
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
          ],
        );
      }),
    );
  }
}

class _DoneMark extends StatelessWidget {
  const _DoneMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.ok,
        shape: BoxShape.circle,
      ),
      child: Center(
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
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Who was pointed, arrival or departure, and when.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final KioskResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = DateFormat('HH:mm').format(result.time);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          result.fullName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '${result.isArrival ? l10n.kioskArrival : l10n.kioskExit} · $time',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7BE0A0),
          ),
        ),
        if (result.isLate && result.lateMinutes > 0) ...[
          SizedBox(height: 6.h),
          Text(
            l10n.personLateBy(l10n.lateAmountOf(result.lateMinutes)),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFB27A),
            ),
          ),
        ],
        if (result.atDepot == false) ...[
          SizedBox(height: 6.h),
          Text(
            l10n.kioskFarFromDepot,
            style: TextStyle(fontSize: 13.sp, color: _softGreen),
          ),
        ],
      ],
    );
  }
}
