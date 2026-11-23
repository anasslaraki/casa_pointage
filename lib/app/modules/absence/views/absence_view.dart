import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/core/di/injection.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/app_sheet.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/absence_controller.dart';

/// Bottom sheet to declare the absence of one person: reason and period.
Future<void> showAbsenceSheet(BuildContext context, String matricule) {
  return showAppSheet<void>(
    context,
    (_) => AbsenceSheet(matricule: matricule),
  );
}

class AbsenceSheet extends StatefulWidget {
  const AbsenceSheet({super.key, required this.matricule});

  final String matricule;

  @override
  State<AbsenceSheet> createState() => _AbsenceSheetState();
}

class _AbsenceSheetState extends State<AbsenceSheet> {
  late final AbsenceController controller = Get.put(
    getIt<AbsenceController>(param1: widget.matricule),
    tag: widget.matricule,
  );

  @override
  void dispose() {
    Get.delete<AbsenceController>(tag: widget.matricule);
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
    final format = DateFormat('d MMM yyyy', locale);
    final today = DateTime.now();
    final earliest = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 30));

    Future<void> pick({
      required DateTime initial,
      required DateTime first,
      required void Function(DateTime) onPicked,
    }) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: today.add(const Duration(days: 365)),
      );
      if (picked != null) {
        onPicked(DateTime(picked.year, picked.month, picked.day));
      }
    }

    final from = controller.from.value;
    final to = controller.to.value;
    final current = controller.reason.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetTitle(title: l10n.absenceTitle, subtitle: subtitle),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - 8.w) / 2;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final reason in controller.reasons)
                  SizedBox(
                    width: width,
                    child: OptionTile(
                      label: reason.label,
                      height: 52,
                      selected: current == reason,
                      onTap: () => controller.selectReason(reason),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: PickerField(
                label: l10n.absenceFrom,
                value: format.format(from),
                icon: AppIcons.calendar,
                onTap: () => pick(
                  initial: from,
                  first: earliest,
                  onPicked: controller.setFrom,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: PickerField(
                label: l10n.absenceTo,
                value: format.format(to),
                icon: AppIcons.calendar,
                onTap: () => pick(
                  initial: to,
                  first: from,
                  onPicked: controller.setTo,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (current == null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              l10n.absenceIncomplete,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
        AppButton(
          variant: AppButtonVariant.accent,
          label: l10n.absenceSubmit,
          loading: controller.saving.value,
          onPressed:
              controller.canSave ? () => controller.save(l10n.absenceSaved) : null,
        ),
      ],
    );
  }
}
