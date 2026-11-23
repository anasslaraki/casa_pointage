import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  /// Barlow and Barlow Condensed are bundled in `assets/fonts`, so every
  /// `FontWeight` finds its own file and nothing is downloaded.
  static const _family = 'Barlow';

  /// Barlow Condensed, used for numbers and counters (`.num` in the prototype).
  static TextStyle numberStyle({double? fontSize, Color? color}) =>
      TextStyle(
        fontFamily: 'BarlowCondensed',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static ThemeData get light {
    final base = Typography.material2021().black.apply(
      fontFamily: _family,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.acc,
      onSecondary: AppColors.ink,
      error: AppColors.absent,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _family,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: base,
      dividerColor: AppColors.line,
      focusColor: AppColors.focus,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: base.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.ink),
        errorBorder: border(AppColors.absent),
        focusedErrorBorder: border(AppColors.absent),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: base.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.line, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: base.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        height: 80,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => base.labelMedium?.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.pending,
          ),
        ),
      ),
    );
  }
}
