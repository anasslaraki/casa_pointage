import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/person_day.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/di/injection.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/app_sheet.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/core/widgets/status_pill.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import 'package:casa_pointage/app/modules/absence/views/absence_view.dart';
import 'package:casa_pointage/app/modules/anomaly/views/anomaly_view.dart';

import '../controllers/person_detail_controller.dart';

/// Bottom sheet of a team member: status of the day and the actions.
Future<void> showPersonSheet(BuildContext context, String matricule) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
    ),
    builder: (_) => PersonSheet(matricule: matricule, parentContext: context),
  );
}

class PersonSheet extends StatefulWidget {
  const PersonSheet({
    super.key,
    required this.matricule,
    required this.parentContext,
  });

  final String matricule;

  /// The screen under the sheet, used to open the history once this one is gone.
  final BuildContext parentContext;

  @override
  State<PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends State<PersonSheet> {
  late final PersonDetailController controller = Get.put(
    getIt<PersonDetailController>(param1: widget.matricule),
    tag: widget.matricule,
  );

  @override
  void dispose() {
    Get.delete<PersonDetailController>(tag: widget.matricule);
    super.dispose();
  }

  /// Closes the sheet, then runs [action] on the screen below.
  void _then(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  void _openHistory() {
    final person = controller.person.value;
    if (person == null) return;
    final future = controller.loadHistory();
    final parent = widget.parentContext;
    Navigator.of(context).pop();
    if (parent.mounted) showPersonHistorySheet(parent, person, future);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
        child: Column(
          children: [
            const SheetGrab(),
            Stack(
              children: [
                Obx(() => _content(context)),
                const PositionedDirectional(top: 2, end: 0, child: SheetCloseButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeholder = LoadingStateWrapper.placeholder(
      context,
      controller.pageState.value,
      onReload: controller.load,
      loadingBuilder: (_) => const _SheetSkeleton(),
    );
    if (placeholder != null) {
      return SizedBox(height: 320.h, child: placeholder);
    }

    final person = controller.person.value;
    final state = controller.state.value;
    if (person == null || state == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            l10n.personNotFound,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
      );
    }

    final status = state.status;
    final canClock = state.enrolled &&
        (status == DayStatus.notClocked ||
            status == DayStatus.overdue ||
            state.isInside);
    final canDeclareAbsence =
        status != DayStatus.out && status != DayStatus.absentJustified;
    final assignment = controller.assignment.value;
    final times = state.arrival == null
        ? null
        : ltr(
            '${AttendanceRules.formatMinute(state.arrival!.minute)}'
            '${state.exit == null ? '' : ' → ${AttendanceRules.formatMinute(state.exit!.minute)}'}',
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: 44.w),
          child: Row(
            children: [
              PersonAvatar(
                initials: person.initials,
                enrolled: state.enrolled,
                ring: state.arrival != null,
                size: 56.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: TextStyle(
                        fontSize: 21.sp,
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
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill.status(context, status),
            if (state.hasPending) StatusPill.pendingSync(context),
            if (times != null)
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
        if (state.arrival?.isLate == true &&
            (state.arrival?.lateMinutes ?? 0) > 0) ...[
          SizedBox(height: 8.h),
          Text(
            l10n.personLateBy(l10n.lateAmountOf(state.arrival!.lateMinutes)),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.late,
            ),
          ),
        ],
        if (assignment != null && assignment.circuit != null) ...[
          SizedBox(height: 12.h),
          _InfoCard(
            icon: AppIcons.pin,
            iconColor: AppColors.brand,
            title: assignment.kind.label(l10n),
            detail: assignment.line(l10n),
          ),
        ],
        if (person.shiftStartMinute != null && person.shiftEndMinute != null) ...[
          SizedBox(height: 12.h),
          _ShiftCard(
            start: person.shiftStartMinute!,
            end: person.shiftEndMinute!,
          ),
        ],
        if (state.arrival?.lateReason != null) ...[
          SizedBox(height: 8.h),
          Text(
            '${l10n.personLateReason} : ${state.arrival!.lateReason}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.late,
            ),
          ),
        ],
        SizedBox(height: 12.h),
        _InfoCard(
          icon: AppIcons.face,
          iconColor: state.enrolled ? AppColors.ok : AppColors.accDark,
          title: state.enrolled ? l10n.personFaceEnrolled : l10n.personFaceMissing,
          detail: state.enrolled && controller.enrolDate.value != null
              ? l10n.personFaceDate(
                  DateFormat(
                    'd MMMM',
                    Localizations.localeOf(context).languageCode,
                  ).format(controller.enrolDate.value!),
                )
              : null,
          trailing: TextButton(
            onPressed: () => _then(controller.openEnrolment),
            child: Text(
              state.enrolled ? l10n.personFaceRedo : l10n.personFaceDo,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        if (canClock) ...[
          AppButton(
            variant: AppButtonVariant.accent,
            icon: AppIcons.scanFace,
            label: state.isInside ? l10n.personClockExit : l10n.personClockArrival,
            onPressed: () => _then(controller.openScan),
          ),
          SizedBox(height: 10.h),
        ],
        if (canDeclareAbsence) ...[
          AppButton(
            variant: AppButtonVariant.ghost,
            icon: AppIcons.bed,
            label: l10n.personDeclareAbsence,
            onPressed: () => _then(() => showAbsenceSheet(widget.parentContext, widget.matricule)),
          ),
          SizedBox(height: 10.h),
        ],
        AppButton(
          variant: AppButtonVariant.ghost,
          icon: AppIcons.alert,
          label: l10n.personReportAnomaly,
          onPressed: () => _then(() => showAnomalySheet(widget.parentContext, widget.matricule)),
        ),
        SizedBox(height: 10.h),
        AppButton(
          variant: AppButtonVariant.ghost,
          icon: AppIcons.history,
          label: l10n.personHistory,
          onPressed: _openHistory,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.detail,
    this.trailing,
  });

  final AppIcons icon;
  final Color iconColor;
  final String title;
  final String? detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          AppIcon(icon, color: iconColor, size: 22.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Start and end of the circuit of the day (`heureDebutPoste`, `heureFinPoste`).
class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.start, required this.end});

  final int start;
  final int end;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget cell(String label, int minute) => Expanded(
          child: Row(
            children: [
              AppIcon(AppIcons.clock, color: AppColors.brand, size: 22.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      ltr(AttendanceRules.formatMinute(minute)),
                      style: TextStyle(
                        fontSize: 16.sp,
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
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

class _SheetSkeleton extends StatelessWidget {
  const _SheetSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 56.r, height: 56.r, circle: true),
              SizedBox(width: 12.w),
              const Expanded(child: SkeletonBox(height: 20)),
            ],
          ),
          SizedBox(height: 16.h),
          const SkeletonBox(height: 56, radius: 16),
          SizedBox(height: 12.h),
          const SkeletonBox(height: 56, radius: 16),
          SizedBox(height: 12.h),
          const SkeletonBox(height: 56, radius: 14),
        ],
      ),
    );
  }
}

// ---- history of one person ----

Future<void> showPersonHistorySheet(
  BuildContext context,
  Person person,
  Future<List<PersonDay>> days,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
    ),
    builder: (_) => _PersonHistorySheet(person: person, days: days),
  );
}

class _PersonHistorySheet extends StatelessWidget {
  const _PersonHistorySheet({required this.person, required this.days});

  final Person person;
  final Future<List<PersonDay>> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
        child: Column(
          children: [
            const SheetGrab(),
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 44.w),
                      child: Row(
                        children: [
                          PersonAvatar(initials: person.initials, size: 48.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: TextStyle(
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  l10n.personHistoryTitle,
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
                      ),
                    ),
                    SizedBox(height: 10.h),
                    FutureBuilder<List<PersonDay>>(
                      future: days,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return SizedBox(
                            height: 240.h,
                            child: const SkeletonList(itemCount: 6),
                          );
                        }
                        return Column(
                          children: [
                            for (final day in snapshot.data!) _DayRow(day: day),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const PositionedDirectional(top: 2, end: 0, child: SheetCloseButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final PersonDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(day.dateKey);
    final today = DateTime.now();
    final offset = DateTime(today.year, today.month, today.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    final label = switch (offset) {
      0 => l10n.historyToday,
      1 => l10n.historyYesterday,
      _ => DateFormat('EEE d MMM', locale).format(date),
    };

    final Widget trailing = switch (day.kind) {
      PersonDayKind.rest => Text(
          l10n.personRest,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      PersonDayKind.absent =>
        StatusPill.status(context, DayStatus.absentJustified),
      PersonDayKind.missing => StatusPill.status(context, DayStatus.overdue),
      PersonDayKind.worked => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ltr(
                '${AttendanceRules.formatMinute(day.arrivalMinute!)} → '
                '${day.exitMinute == null ? '…' : AttendanceRules.formatMinute(day.exitMinute!)}',
              ),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
            if (day.isLate) ...[
              SizedBox(width: 8.w),
              StatusPill.status(context, DayStatus.late),
            ],
          ],
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
