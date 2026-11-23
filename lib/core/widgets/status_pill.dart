import 'package:flutter/material.dart';

import 'package:casa_pointage/app/data/models/day_state.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Small rounded status label (`.pill` in the prototype).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.foreground,
    required this.background,
    required this.icon,
    required this.label,
  });

  /// Pill for a person's status of the day.
  factory StatusPill.status(BuildContext context, DayStatus status) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      DayStatus.present => StatusPill(
          foreground: AppColors.ok,
          background: AppColors.okSoft,
          icon: AppIcons.check,
          label: l10n.statusPresent,
        ),
      DayStatus.out => StatusPill(
          foreground: AppColors.ink2,
          background: AppColors.soft,
          icon: AppIcons.logout,
          label: l10n.statusOut,
        ),
      DayStatus.late => StatusPill(
          foreground: AppColors.late,
          background: AppColors.lateSoft,
          icon: AppIcons.clock,
          label: l10n.statusLate,
        ),
      DayStatus.absentJustified => StatusPill(
          foreground: AppColors.justified,
          background: AppColors.justifiedSoft,
          icon: AppIcons.bed,
          label: l10n.statusAbsentJustified,
        ),
      DayStatus.notClocked => StatusPill(
          foreground: AppColors.pending,
          background: AppColors.pendingSoft,
          icon: AppIcons.clock,
          label: l10n.statusNotClocked,
        ),
      DayStatus.overdue => StatusPill(
          foreground: AppColors.absent,
          background: AppColors.absentSoft,
          icon: AppIcons.alert,
          label: l10n.statusNotClocked,
        ),
      DayStatus.notEnrolled => StatusPill(
          foreground: AppColors.accDark,
          background: AppColors.accSoft,
          icon: AppIcons.face,
          label: l10n.statusNotEnrolled,
        ),
    };
  }

  /// Pill for a record that has not been sent to the HR module yet.
  factory StatusPill.pendingSync(BuildContext context) => StatusPill(
        foreground: AppColors.pending,
        background: AppColors.pendingSoft,
        icon: AppIcons.cloudOff,
        label: AppLocalizations.of(context).statusPendingSync,
      );

  final Color foreground;
  final Color background;
  final AppIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, color: foreground, size: 13, strokeWidth: 2.6),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
