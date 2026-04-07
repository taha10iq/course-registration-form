import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.neonBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.neonBlue,
      secondary: AppColors.neonGreen,
      tertiary: AppColors.neonPurple,
      surface: AppColors.surface,
      error: AppColors.danger,
      onSurface: AppColors.primaryText,
      surfaceTint: Colors.transparent,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppConstants.fontFamily,
      textTheme: textTheme,
      dividerColor: AppColors.glassStroke.withValues(alpha: 0.22),
      splashFactory: InkRipple.splashFactory,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.neonGreen,
        selectionColor: Color(0x445AE8FF),
        selectionHandleColor: AppColors.neonGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.74),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.tertiaryText),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.danger,
          height: 1.25,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        enabledBorder:
            _inputBorder(AppColors.glassStroke.withValues(alpha: 0.36)),
        focusedBorder: _inputBorder(AppColors.neonBlue, width: 1.6),
        errorBorder: _inputBorder(AppColors.danger.withValues(alpha: 0.9)),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.6),
        border: _inputBorder(AppColors.glassStroke.withValues(alpha: 0.36)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _textTheme() {
    return const TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: AppColors.primaryText,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: AppColors.primaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: AppColors.primaryText,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.primaryText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.primaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.65,
        color: AppColors.secondaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: AppColors.secondaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppColors.tertiaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.primaryText,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1.1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
