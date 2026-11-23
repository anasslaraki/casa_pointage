import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/app/data/models/team_page.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_icon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

/// Numbered pages under a list: previous, 1 … 4 5 6 … 20, next, and the range
/// shown ("11–20 sur 132"). Hidden when there is only one page.
class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key, required this.info, required this.onPage});

  final PageInfo info;
  final ValueChanged<int> onPage;

  /// Page numbers to show, with `null` for a gap ("…").
  static List<int?> _window(int page, int pages) {
    if (pages <= 7) return [for (var i = 1; i <= pages; i++) i];
    final shown = <int>{1, pages, page - 1, page, page + 1};
    if (page <= 3) shown.addAll([2, 3, 4]);
    if (page >= pages - 2) shown.addAll([pages - 3, pages - 2, pages - 1]);
    final sorted = shown.where((p) => p >= 1 && p <= pages).toList()..sort();

    final out = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(null);
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (info.totalPages <= 1) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _ArrowButton(
                icon: AppIcons.chevronLeft,
                label: l10n.paginationPrevious,
                onTap: info.page > 1 ? () => onPage(info.page - 1) : null,
              ),
              for (final p in _window(info.page, info.totalPages))
                if (p == null)
                  SizedBox(
                    width: 22.w,
                    child: Text(
                      '…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  )
                else
                  _PageButton(
                    number: p,
                    selected: p == info.page,
                    label: l10n.paginationPage(p),
                    onTap: () => onPage(p),
                  ),
              _ArrowButton(
                icon: AppIcons.chevronRight,
                label: l10n.paginationNext,
                onTap:
                    info.page < info.totalPages ? () => onPage(info.page + 1) : null,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.paginationRange(info.firstItem, info.lastItem, info.total),
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.ink : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: selected ? AppColors.ink : AppColors.line,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: selected ? null : onTap,
          child: SizedBox(
            width: 42.w,
            height: 44.h,
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppIcons icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: const BorderSide(color: AppColors.line, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: onTap,
            child: SizedBox(
              width: 42.w,
              height: 44.h,
              child: Center(
                child: AppIcon(
                  icon,
                  color: AppColors.ink,
                  size: 20.r,
                  strokeWidth: 2.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
