import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/theme/app_theme.dart';
import 'package:casa_pointage/core/utils/bidi.dart';
import 'package:casa_pointage/core/widgets/app_chip.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/pagination_bar.dart';
import 'package:casa_pointage/core/widgets/skeleton.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';

import 'package:casa_pointage/app/modules/person_detail/views/person_detail_view.dart';

import '../controllers/team_controller.dart';
import '../widgets/member_row.dart';
import '../widgets/supervisor_card.dart';
import '../widgets/team_skeleton.dart';
import '../widgets/sync_chip.dart';

/// Space kept free at the bottom for the tab bar.
const double _tabBarClearance = 96;

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final placeholder = LoadingStateWrapper.placeholder(
        context,
        controller.pageState.value,
        onReload: controller.load,
        loadingBuilder: (_) => const TeamSkeleton(),
      );
      if (placeholder != null) return placeholder;
      return _TeamList(controller: controller);
    });
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList({required this.controller});

  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _Header(controller: controller),
              Transform.translate(
                offset: Offset(0, -12.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(() {
                    final me = controller.me.value;
                    if (me == null) return const SizedBox.shrink();
                    return SupervisorCard(
                      me: me,
                      onClockIn: () =>
                          Get.toNamed(Routes.SCAN, arguments: ScanMode.self),
                      onClockOut: () =>
                          Get.toNamed(Routes.SCAN, arguments: ScanMode.self),
                      onEnrol: () => Get.toNamed(
                        Routes.FACE_ENROL,
                        arguments: me.person.matricule,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
        SliverToBoxAdapter(child: _FilterChips(controller: controller)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                constraints: BoxConstraints(minHeight: 48.h),
                hintText: l10n.teamSearchHint,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(14.r),
                  child: AppIcon(
                    AppIcons.search,
                    color: AppColors.pending,
                    size: 20.r,
                  ),
                ),
                suffixIcon: Obx(
                  () => controller.query.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: l10n.teamSearchClear,
                          onPressed: controller.searchController.clear,
                          icon: AppIcon(
                            AppIcons.close,
                            color: AppColors.muted,
                            size: 18.r,
                            strokeWidth: 2.4,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.listLoading.value) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: SkeletonRows(count: TeamController.pageSize.clamp(1, 6)),
              ),
            );
          }
          final list = controller.members;
          if (list.isEmpty) {
            return SliverToBoxAdapter(child: _EmptyState(text: l10n.teamEmpty));
          }
          return SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (_, i) => MemberRow(
                member: list[i],
                onTap: () =>
                    showPersonSheet(context, list[i].person.matricule),
              ),
            ),
          );
        }),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              0,
              20.w,
              _tabBarClearance + bottomInset,
            ),
            child: Obx(
              () => PaginationBar(
                info: controller.pageInfo.value,
                onPage: controller.goToPage,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final locale = Localizations.localeOf(context).languageCode;

    return ColoredBox(
      color: AppColors.brand,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topInset + 18.h, 20.w, 30.h),
        child: Obx(() {
          final shift = controller.shift.value;
          final sector = controller.sector.value;
          final date = controller.now.value;
          final total = controller.total;
          final dateText = '${DateFormat('EEEE', locale).format(date)} '
              '${date.day} ${DateFormat('MMMM', locale).format(date)}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shift != null)
                          Text(
                            '${shift.kind.label(l10n)} · '
                            '${ltr('${AttendanceRules.formatMinute(shift.startMinute)}'
                                ' – ${AttendanceRules.formatMinute(shift.endMinute)}')}',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandText,
                            ),
                          ),
                        SizedBox(height: 2.h),
                        Text(
                          sector?.name ?? '',
                          style: TextStyle(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SyncChip(
                        online: controller.online.value,
                        pending: controller.pendingCount,
                        onTap: () => Get.toNamed(Routes.SYNC),
                      ),
                      SizedBox(height: 8.h),
                      _RefreshButton(controller: controller),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${controller.clockedInCount}',
                    style: AppTheme.numberStyle(
                      fontSize: 52.sp,
                      color: Colors.white,
                    ).copyWith(height: 1),
                  ),
                  Text(
                    ' / $total',
                    style: AppTheme.numberStyle(
                      fontSize: 26.sp,
                      color: const Color(0xFFAFC09A),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        '${l10n.teamPeopleClockedIn}\n$dateText',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Reloads the team from the server, for people who do not know the gesture.
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.controller});

  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      final busy = controller.refreshing.value;
      return Material(
        color: const Color(0x1FFFFFFF),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: busy ? null : controller.refresh,
          child: Container(
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppIcons.refresh,
                  color: const Color(0xFFDCEBC9),
                  size: 15.r,
                  strokeWidth: 2.4,
                ),
                SizedBox(width: 6.w),
                Text(
                  l10n.teamRefresh,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDCEBC9),
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});

  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String label(TeamFilter f) => switch (f) {
          TeamFilter.all => l10n.filterAll,
          TeamFilter.notClocked => l10n.filterNotClocked,
          TeamFilter.present => l10n.filterPresent,
          TeamFilter.late => l10n.filterLate,
          TeamFilter.absent => l10n.filterAbsent,
          TeamFilter.out => l10n.filterOut,
          TeamFilter.notEnrolled => l10n.filterNotEnrolled,
        };

    return Obx(() {
      final selected = controller.filter.value;
      final filters = controller.visibleFilters;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        child: Row(
          children: [
            for (final f in filters) ...[
              AppChip(
                label: label(f),
                count: controller.countFor(f),
                selected: f == selected,
                onTap: () => controller.selectFilter(f),
              ),
              SizedBox(width: 8.w),
            ],
          ],
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 34.h),
      child: Column(
        children: [
          AppIcon(AppIcons.users, color: AppColors.muted, size: 30.r),
          SizedBox(height: 10.h),
          Text(
            text,
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
    );
  }
}
