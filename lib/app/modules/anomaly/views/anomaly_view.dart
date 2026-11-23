import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/core/di/injection.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/app_sheet.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/anomaly_controller.dart';

/// Bottom sheet to report an anomaly about one person: type, day, correct time
/// and a comment.
Future<void> showAnomalySheet(BuildContext context, String matricule) {
  return showAppSheet<void>(
    context,
    (_) => AnomalySheet(matricule: matricule),
  );
}

class AnomalySheet extends StatefulWidget {
  const AnomalySheet({super.key, required this.matricule});

  final String matricule;

  @override
  State<AnomalySheet> createState() => _AnomalySheetState();
}

class _AnomalySheetState extends State<AnomalySheet> {
  late final AnomalyController controller = Get.put(
    getIt<AnomalyController>(param1: widget.matricule),
    tag: widget.matricule,
  );

  @override
  void dispose() {
    Get.delete<AnomalyController>(tag: widget.matricule);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(child: Obx(() => _content(context)));
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeholder = LoadingStateWrapper.placeholder(
      context,
      controller.pageState.value,
      onReload: controller.load,
      loadingBuilder: (_) => SizedBox(
        height: 260.h,
        child: const SkeletonList(itemCount: 4),
      ),
    );
    if (placeholder != null) {
      return SizedBox(height: 260.h, child: placeholder);
    }

    final person = controller.person.value;
    final subtitle = person == null
        ? null
        : '${person.name} · ${person.matricule}';
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateTime.now();
    final day = controller.day.value;
    final time = controller.time.value;
    final current = controller.kind.value;

    final missing = current == null
        ? l10n.anomalyIncomplete
        : controller.needsComment
            ? l10n.anomalyIncompleteComment
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetTitle(title: l10n.anomalyTitle, subtitle: subtitle),
        SizedBox(height: 12.h),
        for (final kind in controller.reasons) ...[
          OptionTile(
            label: kind,
            selected: current == kind,
            onTap: () => controller.selectKind(kind),
          ),
          SizedBox(height: 8.h),
        ],
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: PickerField(
                label: l10n.anomalyDay,
                value: DateFormat('d MMM yyyy', locale).format(day),
                icon: AppIcons.calendar,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day,
                    firstDate: DateTime(today.year, today.month, today.day)
                        .subtract(const Duration(days: 31)),
                    lastDate: today,
                  );
                  if (picked != null) {
                    controller.setDay(
                      DateTime(picked.year, picked.month, picked.day),
                    );
                  }
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: PickerField(
                label: l10n.anomalyTime,
                value: time == null
                    ? '--:--'
                    : ltr(
                        '${time.hour.toString().padLeft(2, '0')}:'
                        '${time.minute.toString().padLeft(2, '0')}',
                      ),
                icon: AppIcons.clock,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (picked != null) controller.setTime(picked);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.anomalyStepComment,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller.commentController,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(hintText: l10n.anomalyCommentHint),
        ),
        SizedBox(height: 16.h),
        if (missing != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              missing,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
        AppButton(
          variant: AppButtonVariant.accent,
          label: l10n.anomalySubmit,
          loading: controller.saving.value,
          onPressed: controller.canSave
              ? () => controller.save(l10n.anomalySaved)
              : null,
        ),
      ],
    );
  }
}
