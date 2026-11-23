import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';

import '../controllers/sync_controller.dart';

/// Pending sync: network state, what is waiting, and a "send now" button.
class SyncView extends GetView<SyncController> {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.scanClose,
                      excludeSemantics: true,
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: const BorderSide(
                            color: AppColors.line,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: Get.back<void>,
                          child: SizedBox.square(
                            dimension: 44.r,
                            child: Center(
                              child: AppIcon(
                                AppIcons.chevronLeft,
                                color: AppColors.ink,
                                size: 22.r,
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      l10n.syncScreenTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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
                  final items = controller.items;
                  return ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                    children: [
                      _NetworkCard(online: controller.online.value),
                      SizedBox(height: 22.h),
                      if (items.isEmpty)
                        _Empty(text: l10n.syncEmpty)
                      else ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Text(
                            '${l10n.syncListTitle} (${items.length})',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        for (final item in items) ...[
                          _ItemRow(item: item),
                          SizedBox(height: 8.h),
                        ],
                      ],
                    ],
                  );
                }),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Obx(
                  () => AppButton(
                    variant: AppButtonVariant.accent,
                    height: 60.h,
                    fontSize: 18.sp,
                    label: l10n.syncNow,
                    loading: controller.sending.value,
                    onPressed: controller.canSend
                        ? () => controller.sendNow(l10n.syncSent)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = online ? AppColors.ok : AppColors.late;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: online ? AppColors.okSoft : AppColors.lateSoft,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            online ? AppIcons.wifi : AppIcons.cloudOff,
            color: color,
            size: 24.r,
            strokeWidth: 2.2,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? l10n.syncConnected : l10n.syncOfflineTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (!online)
                  Text(
                    l10n.syncOfflineHint,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: const BoxDecoration(
              color: AppColors.ok,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(
              AppIcons.check,
              color: Colors.white,
              size: 34.r,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final SyncItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = item.person;

    final record = item.record;
    final declaration = item.declaration;
    final what = record != null
        ? (record.kind == ClockKind.arrival
            ? l10n.syncItemArrival(
                ltr(AttendanceRules.formatMinute(record.minute)),
              )
            : l10n.syncItemExit(
                ltr(AttendanceRules.formatMinute(record.minute)),
              ))
        : declaration?.kind == DeclarationKind.absence
            ? l10n.syncItemAbsence(declaration?.absenceReason ?? '')
            : l10n.syncItemAnomaly(declaration?.anomalyKind ?? '');

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          PersonAvatar(initials: person.initials, size: 40.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  what,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          AppIcon(AppIcons.cloudOff, color: AppColors.pending, size: 20.r),
        ],
      ),
    );
  }
}
