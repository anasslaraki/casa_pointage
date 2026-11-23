import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Labeled input matching the prototype's `.field` / `.inp` styles.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.fontWeight = FontWeight.w400,
  });

  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: !obscureText,
          style: TextStyle(fontSize: 17.sp, fontWeight: fontWeight),
          decoration: InputDecoration(
            constraints: BoxConstraints(minHeight: 54.h),
            prefixIcon: Icon(prefixIcon, color: AppColors.pending, size: 22.r),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
