import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:casa_pointage/app/modules/person_detail/views/person_detail_view.dart';
import 'package:casa_pointage/app/modules/team/widgets/sync_chip.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/pagination_bar.dart';
import 'package:casa_pointage/core/widgets/person_avatar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/enrolment_controller.dart';

/// Space kept free at the bottom for the tab bar.
const double _tabBarClearance = 96;

/// Enrolment tab: progress, the people whose face is still to enrol, then the
/// people already enrolled.
class EnrolmentView extends GetView<EnrolmentController> {
  const EnrolmentView({super.key});

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
      final todo = controller.todoItems;
      final todoCount = controller.todoInfo.total;
      final done = controller.doneItems;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(controller: controller)),
          SliverToBoxAdapter(
            child: _SectionTitle(
              title: l10n.enrolSectionTodo,
              count: todoCount == 0 ? null : todoCount,
            ),
          ),
          if (todo.isEmpty)
            SliverToBoxAdapter(child: _AllDone(text: l10n.enrolAllDone))
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList.separated(
                itemCount: todo.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (_, i) => _TodoRow(
                  entry: todo[i],
                  onTap: () => controller.enrol(todo[i].person),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: PaginationBar(
                info: controller.todoInfo,
                onPage: controller.goToTodoPage,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _SectionTitle(title: l10n.enrolSectionDone)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList.separated(
              itemCount: done.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, i) => _DoneRow(
                entry: done[i],
                onTap: () =>
                    showPersonSheet(context, done[i].person.matricule),
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
                info: controller.doneInfo,
                onPage: controller.goToDonePage,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final EnrolmentController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final done = controller.enrolledCount;
    final total = controller.total;

    return ColoredBox(
      color: AppColors.brand,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topInset + 18.h, 20.w, 22.h),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.enrolTitle,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.enrolProgress(done, total),
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
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 8.h,
                backgroundColor: const Color(0x26FFFFFF),
                color: AppColors.acc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
          if (count != null)
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _AllDone extends StatelessWidget {
  const _AllDone({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 12.h),
      child: Column(
        children: [
          AppIcon(
            AppIcons.check,
            color: AppColors.ok,
            size: 30.r,
            strokeWidth: 2.4,
          ),
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

/// A person whose face is still to enrol: highlighted, with its own button.
class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.entry, required this.onTap});

  final EnrolmentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = entry.person;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.acc),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              PersonAvatar(
                initials: person.initials,
                isSupervisor: person.isSupervisor,
                size: 44.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.isSupervisor
                          ? '${person.name} ${l10n.enrolYou}'
                          : person.name,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${person.matricule} · ${person.functionLabel(l10n)}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.acc,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      AppIcons.scanFace,
                      color: AppColors.ink,
                      size: 18.r,
                      strokeWidth: 2.2,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      l10n.enrolAction,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A person already enrolled: opens their sheet.
class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.entry, required this.onTap});

  final EnrolmentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = entry.person;

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
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              PersonAvatar(
                initials: person.initials,
                isSupervisor: person.isSupervisor,
                enrolled: true,
                size: 44.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.isSupervisor
                          ? '${person.name} ${l10n.enrolYou}'
                          : person.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      entry.date == null
                          ? '${person.matricule} · ${l10n.enrolRegistered}'
                          : '${person.matricule} · ${l10n.enrolRegisteredOn(DateFormat('d MMMM', Localizations.localeOf(context).languageCode).format(entry.date!))}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIcons.chevronRight,
                color: const Color(0xFF9AA1A9),
                size: 20.r,
                strokeWidth: 2.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
