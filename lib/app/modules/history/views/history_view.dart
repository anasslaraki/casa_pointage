import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/app/data/models/person_day.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/modules/person_detail/views/person_detail_view.dart';
import 'package:casa_pointage/app/modules/team/widgets/sync_chip.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/theme/app_theme.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_chip.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/pagination_bar.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/core/widgets/status_pill.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/history_controller.dart';

/// Space kept free at the bottom for the tab bar.
const double _tabBarClearance = 96;

/// History tab: a strip of the last 14 days, filters, and everyone's clock-ins
/// on the selected day.
class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Obx(() {
      final placeholder = LoadingStateWrapper.placeholder(
        context,
        controller.pageState.value,
        onReload: controller.load,
      );
      if (placeholder != null) {
        return SafeArea(bottom: false, child: placeholder);
      }
      final rows = controller.rows;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(controller: controller)),
          SliverToBoxAdapter(child: _DayStrip(controller: controller)),
          SliverToBoxAdapter(child: _Filters(controller: controller)),
          if (controller.listLoading.value)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: SkeletonRows(count: HistoryController.pageSize.clamp(1, 6)),
              ),
            )
          else if (rows.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 34.h),
                child: Column(
                  children: [
                    AppIcon(AppIcons.users, color: AppColors.muted, size: 30.r),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.teamEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              sliver: SliverList.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, i) => _PersonRow(
                  row: rows[i],
                  isToday: controller.isToday(controller.selected.value),
                  onTap: rows[i].person == null
                      ? null
                      : () => showPersonHistorySheet(
                            context,
                            rows[i].person!,
                            controller.loadPersonHistory(rows[i].person!),
                          ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                0,
                20.w,
                _tabBarClearance + bottomInset,
              ),
              child: PaginationBar(
                info: controller.pageInfo.value,
                onPage: controller.goToPage,
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// "Aujourd'hui", "Hier" or the long date.
String historyDayLabel(BuildContext context, DateTime date, bool isToday) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).languageCode;
  if (isToday) return l10n.historyToday;

  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return l10n.historyYesterday;
  }
  return DateFormat('EEEE d MMMM', locale).format(date);
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final selected = controller.selected.value;
    final day = historyDayLabel(context, selected, controller.isToday(selected));
    final sector = controller.sector.value?.name ?? '';

    return ColoredBox(
      color: AppColors.brand,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topInset + 18.h, 20.w, 16.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.historyTitle,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sector.isEmpty ? day : '$day · $sector',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SyncChip(
              online: controller.online.value,
              pending: 0,
              onTap: () => Get.toNamed(Routes.SYNC),
            ),
          ],
        ),
      ),
    );
  }
}

/// The last 14 days, today on the right.
class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.controller});

  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final selected = controller.selected.value;
    // Oldest first; the reversed scroll view starts on the right, so today
    // is the day on screen when the tab opens.
    final days = controller.days.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      child: Row(
        children: [
          for (final date in days) ...[
            Semantics(
              button: true,
              selected: date == selected,
              child: Material(
                color: date == selected ? AppColors.brand : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side: date == selected
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.line, width: 2),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  onTap: () => controller.selectDay(date),
                  child: SizedBox(
                    width: 52.w,
                    height: 62.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.isToday(date)
                              ? l10n.historyTodayShort
                              : DateFormat('E', locale).format(date),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: (date == selected
                                    ? Colors.white
                                    : AppColors.ink)
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: AppTheme.numberStyle(
                            fontSize: 20.sp,
                            color: date == selected
                                ? Colors.white
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});

  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String label(HistoryFilter f) => switch (f) {
          HistoryFilter.all => l10n.filterAll,
          HistoryFilter.late => l10n.filterLate,
          HistoryFilter.absent => l10n.filterAbsent,
          HistoryFilter.manual => l10n.historyFilterManual,
        };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
      child: Row(
        children: [
          for (final f in HistoryFilter.values) ...[
            AppChip(
              label: label(f),
              selected: controller.filter.value == f,
              onTap: () => controller.selectFilter(f),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.row,
    required this.isToday,
    required this.onTap,
  });

  final HistoryRow row;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = row.day;
    final person = row.person;
    final name = person?.name ?? day.name;
    final function = person?.functionLabel(l10n) ?? '';
    final detail = [
      if (function.isNotEmpty) function,
      if (day.circuit != null) day.circuit!,
    ].join(' · ');
    final initials = person?.initials ?? _initials(name);

    final Widget right = switch (day.kind) {
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
      PersonDayKind.missing => StatusPill.status(
          context,
          isToday ? DayStatus.notClocked : DayStatus.overdue,
        ),
      PersonDayKind.worked => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ltr(
                '${AttendanceRules.formatMinute(day.arrivalMinute!)} → '
                '${day.exitMinute == null ? '…' : AttendanceRules.formatMinute(day.exitMinute!)}',
              ),
              style: AppTheme.numberStyle(fontSize: 17.sp),
            ),
            Text(
              '${day.isLate ? '${l10n.historyLateWord}'
                  '${day.lateMinutes > 0 ? ' ${l10n.lateAmountOf(day.lateMinutes)}' : ''} · ' : ''}'
              '${day.manual ? l10n.teamManualTag : l10n.historyFace}',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
    };

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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              PersonAvatar(
                initials: initials,
                isSupervisor: person?.isSupervisor ?? false,
                size: 38.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              right,
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
