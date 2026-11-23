import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/core/localization/l10n_labels.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_chip.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

/// Lets the supervisor change today's circuit or cart/vehicle. Returns the new
/// assignment, or `null` when dismissed.
Future<Assignment?> showAssignmentSheet(
  BuildContext context, {
  required Assignment current,
  required AssignmentOptions options,
}) {
  return showModalBottomSheet<Assignment>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
    ),
    builder: (context) =>
        _AssignmentSheet(current: current, options: options),
  );
}

class _AssignmentSheet extends StatefulWidget {
  const _AssignmentSheet({required this.current, required this.options});

  final Assignment current;
  final AssignmentOptions options;

  @override
  State<_AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends State<_AssignmentSheet> {
  late String? _circuit = widget.current.circuit;
  late String? _vehicle = widget.current.vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    TextStyle heading() =>
        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              l10n.scanAssignment,
              style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.current.kind.label(l10n),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 12.h),
            Text(l10n.assignmentCircuit, style: heading()),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final c in widget.options.circuits)
                  AppChip(
                    label: c,
                    selected: _circuit == c,
                    onTap: () => setState(() => _circuit = c),
                  ),
              ],
            ),
            if (widget.options.vehicles.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(l10n.assignmentVehicle, style: heading()),
              SizedBox(height: 8.h),
              AppButton(
                variant: AppButtonVariant.ghost,
                height: 48.h,
                fontSize: 14.5.sp,
                label: l10n.assignmentReadRfid,
                // The RFID reader SDK is not chosen yet.
                onPressed: () => showAppToast(l10n.assignmentRfidHint),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final v in widget.options.vehicles)
                    AppChip(
                      label: v,
                      selected: _vehicle == v,
                      onTap: () => setState(() => _vehicle = v),
                    ),
                ],
              ),
            ],
            SizedBox(height: 18.h),
            AppButton(
              variant: AppButtonVariant.accent,
              label: l10n.assignmentSave,
              onPressed: () => Navigator.of(context).pop(
                widget.current.copyWith(circuit: _circuit, vehicle: _vehicle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
