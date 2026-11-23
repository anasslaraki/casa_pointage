import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state_wrapper.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/theme/app_theme.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/core/widgets/app_sheet.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/profile_controller.dart';

/// Space kept free at the bottom for the tab bar.
const double _tabBarClearance = 96;

/// Profile tab: supervisor, sector, sync state, language, help and sign-out.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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
      final sector = controller.sector.value;

      return ListView(
        padding: EdgeInsets.only(bottom: _tabBarClearance + bottomInset),
        children: [
          _Header(controller: controller),
          if (sector != null)
            _Card(
              margin: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Column(
                children: [
                  _InfoRow(label: l10n.profileDelegate, value: sector.delegate),
                  _InfoRow(
                    label: l10n.profileSector,
                    value: sector.name,
                    divider: true,
                  ),
                  _InfoRow(
                    label: l10n.profileDepot,
                    value: sector.depotName,
                    divider: true,
                  ),
                  _InfoRow(
                    label: l10n.profileTeam,
                    value: l10n.profileTeamCount(controller.teamCount.value),
                    divider: true,
                  ),
                ],
              ),
            ),
          _SyncCard(controller: controller),
          _Card(
            margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _MenuRow(
                  icon: AppIcons.globe,
                  label: l10n.profileLanguageValue(
                    controller.localeController.isArabic
                        ? l10n.languageArabic
                        : l10n.languageFrench,
                  ),
                  onTap: () => _showLanguageSheet(context),
                ),
                _MenuRow(
                  icon: AppIcons.help,
                  label: l10n.profileHelp,
                  divider: true,
                  onTap: () => showAppSheet<void>(
                    context,
                    (_) => const _HelpSheet(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              children: [
                _LogoutButton(onPressed: () => _confirmLogout(context)),
                SizedBox(height: 12.h),
                const _About(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showLanguageSheet(BuildContext context) {
    return showAppSheet<void>(
      context,
      (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return AppSheet(
          child: Obx(() {
            final arabic = controller.localeController.isArabic;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetTitle(title: l10n.profileLanguage),
                SizedBox(height: 10.h),
                OptionTile(
                  label: l10n.languageFrench,
                  selected: !arabic,
                  onTap: () {
                    controller.setLanguage(false);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                SizedBox(height: 10.h),
                OptionTile(
                  label: l10n.languageArabic,
                  selected: arabic,
                  onTap: () {
                    controller.setLanguage(true);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final pending = controller.pendingCount.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        child: Padding(
          padding: EdgeInsets.all(22.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileLogoutTitle,
                style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8.h),
              Text(
                pending > 0
                    ? l10n.profileLogoutPending(pending)
                    : l10n.profileLogoutBody,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.ghost,
                      height: 54.h,
                      label: l10n.profileCancel,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.danger,
                      height: 54.h,
                      label: l10n.profileLogoutConfirm,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed ?? false) controller.logout();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final supervisor = controller.supervisor.value;

    return ColoredBox(
      color: AppColors.brand,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topInset + 18.h, 20.w, 22.h),
        child: supervisor == null
            ? const SizedBox.shrink()
            : Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.acc,
                    ),
                    child: Text(
                      supervisor.initials,
                      style: AppTheme.numberStyle(
                        fontSize: 22.sp,
                        color: AppColors.ink,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supervisor.name,
                          style: TextStyle(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${supervisor.matricule} · '
                          '${supervisor.functionLabel(l10n)}',
                          style: TextStyle(
                            fontSize: 13.5.sp,
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
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    required this.margin,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.divider = false,
  });

  final String label;
  final String value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: divider
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether what the phone holds reached the HR module.
class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = controller.online.value;
    final pending = controller.pendingCount.value;

    final (icon, color, title, hint) = !online
        ? (
            AppIcons.cloudOff,
            AppColors.accDark,
            l10n.profileOffline,
            l10n.profileOfflineHint,
          )
        : pending > 0
            ? (
                AppIcons.refresh,
                AppColors.accDark,
                l10n.profilePending(pending),
                l10n.profilePendingHint,
              )
            : (
                AppIcons.check,
                AppColors.ok,
                l10n.profileSynced,
                l10n.profileSyncedHint,
              );

    return _Card(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          AppIcon(icon, color: color, size: 22.r, strokeWidth: 2.2),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                ),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (online && pending > 0) ...[
            SizedBox(width: 8.w),
            SizedBox(
              width: 96.w,
              child: AppButton(
                height: 44.h,
                fontSize: 14.sp,
                label: l10n.profileSend,
                onPressed: controller.sendNow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.divider = false,
  });

  final AppIcons icon;
  final String label;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 56.h),
        decoration: BoxDecoration(
          border: divider
              ? const Border(top: BorderSide(color: AppColors.line))
              : null,
        ),
        child: Row(
          children: [
            AppIcon(icon, color: AppColors.ink, size: 21.r, strokeWidth: 1.9),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AppIcon(
              AppIcons.chevronRight,
              color: const Color(0xFF9AA1A9),
              size: 18.r,
              strokeWidth: 2.2,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.absent,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.line, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              AppIcons.logout,
              color: AppColors.absent,
              size: 21.r,
              strokeWidth: 2.2,
            ),
            SizedBox(width: 10.w),
            Text(l10n.profileLogout),
          ],
        ),
      ),
    );
  }
}

/// Logo and version at the bottom of the tab.
class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Center(
            child: Image.asset('assets/images/logo_cb.png', height: 34.h),
          ),
        ),
        Text(
          l10n.profileVersion(ProfileController.appVersion),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget item(String lead, String text) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$lead ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: text),
              ],
            ),
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
        );

    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(title: l10n.profileHelp),
          SizedBox(height: 10.h),
          item(l10n.helpEnrolLead, l10n.helpEnrolText),
          item(l10n.helpClockLead, l10n.helpClockText),
          item(l10n.helpSelfLead, l10n.helpSelfText),
          item(l10n.helpFailedLead, l10n.helpFailedText),
        ],
      ),
    );
  }
}
