import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/app_sheet.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/manual_clock_controller.dart';

/// Manual clock-in, laid out like the prototype: green header, a warning, the
/// person, the reason, the photo, and a big "Enregistrer le pointage".
class ManualClockView extends GetView<ManualClockController> {
  const ManualClockView({super.key});

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.manualTitle,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.manualSubtitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final placeholder = LoadingStateWrapper.placeholder(
                  context,
                  controller.pageState.value,
                  onReload: controller.load,
                );
                if (placeholder != null) return placeholder;
                return _Form(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.controller});

  final ManualClockController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // The messages of what is missing are read here, so rebuild on them.
    return Obx(
      () => ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h + bottomInset),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.accSoft,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEAD48A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIcon(
                  AppIcons.alert,
                  color: AppColors.accDark,
                  size: 20.r,
                  strokeWidth: 2.2,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10n.manualWarning,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5E4500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          _Field(
            label: l10n.manualLabelPerson,
            error: controller.personMissing.value
                ? l10n.manualErrorPerson
                : null,
            child: _PersonList(controller: controller),
          ),
          SizedBox(height: 18.h),
          _Field(
            label: l10n.manualLabelReason,
            error: controller.reasonMissing.value
                ? l10n.manualErrorReason
                : null,
            child: _ReasonList(controller: controller),
          ),
          SizedBox(height: 18.h),
          _Field(
            label: l10n.manualLabelPhoto,
            error: controller.photoMissing.value ? l10n.manualErrorPhoto : null,
            child: _PhotoField(controller: controller),
          ),
          SizedBox(height: 18.h),
          _ConfirmButton(controller: controller),
        ],
      ),
    );
  }
}

/// A label, its content and the red message when something is missing.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.error});

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 7.h),
        child,
        if (error != null) ...[
          SizedBox(height: 7.h),
          Text(
            error!,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.absent,
            ),
          ),
        ],
      ],
    );
  }
}

/// The people that can be clocked, one choice among them.
class _PersonList extends StatelessWidget {
  const _PersonList({required this.controller});

  final ManualClockController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      final chosen = controller.selected.value;
      final list = controller.candidates;

      if (list.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Text(
            l10n.manualNoResult,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        );
      }

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 250.h),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: list.length,
          separatorBuilder: (_, _) => SizedBox(height: 8.h),
          itemBuilder: (_, i) {
            final c = list[i];
            final selected = chosen?.person.matricule == c.person.matricule;
            return Semantics(
              inMutuallyExclusiveGroup: true,
              checked: selected,
              button: true,
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side: BorderSide(
                    color: selected ? AppColors.ink : AppColors.line,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  onTap: () => controller.selectPerson(c),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 52.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        PersonAvatar(
                          initials: c.person.initials,
                          isSupervisor: c.person.isSupervisor,
                          enrolled: c.state.enrolled,
                          size: 36.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.person.name,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${c.person.matricule} · '
                                '${c.kind == ClockKind.exit ? l10n.manualKindExit : l10n.manualKindArrival}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        _Radio(selected: selected),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.pending,
          width: selected ? 6.r : 2,
        ),
      ),
    );
  }
}

class _ReasonList extends StatelessWidget {
  const _ReasonList({required this.controller});

  final ManualClockController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.reason.value;
      return Column(
        children: [
          for (final reason in controller.reasons) ...[
            OptionTile(
              label: reason,
              selected: current == reason,
              onTap: () => controller.selectReason(reason),
            ),
            SizedBox(height: 8.h),
          ],
        ],
      );
    });
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.controller});

  final ManualClockController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      final path = controller.photoPath.value;

      if (path == null) {
        return AppButton(
          variant: AppButtonVariant.ghost,
          icon: AppIcons.camera,
          label: l10n.manualPhotoTake,
          onPressed: () => controller.takePhoto(l10n.manualPhotoError),
        );
      }

      return Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox.square(
                dimension: 64.r,
                child: kIsWeb
                    ? Image.network(path, fit: BoxFit.cover)
                    : Image.file(File(path), fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.manualPhotoAdded,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: l10n.manualPhotoRemove,
              excludeSemantics: true,
              child: Material(
                color: AppColors.soft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: AppColors.line),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: controller.removePhoto,
                  child: SizedBox.square(
                    dimension: 44.r,
                    child: Center(
                      child: AppIcon(
                        AppIcons.close,
                        color: AppColors.ink,
                        size: 18.r,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// "Enregistrer le pointage à 07:15", with a spinner while it is sent.
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.controller});

  final ManualClockController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      final time = ltr(
        AttendanceRules.formatMinute(
          AttendanceRules.minuteOfDay(controller.now.value),
        ),
      );
      return AppButton(
        variant: AppButtonVariant.accent,
        height: 72.h,
        fontSize: 20.sp,
        radius: 18,
        loading: controller.saving.value,
        label: l10n.manualConfirm(time),
        onPressed: controller.confirm,
      );
    });
  }
}
