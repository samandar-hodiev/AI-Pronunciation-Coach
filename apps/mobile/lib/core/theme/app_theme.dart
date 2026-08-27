import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ilovaning markazlashtirilgan mavzusi.
///
/// Ranglar widgetlar ichida qattiq yozilmaydi — hammasi shu yerdan keladi.
/// Light va dark rejim uchun bir xil tuzilma saqlanadi.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.background,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color primary,
    required Color onPrimary,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          surface: background,
          onSurface: textPrimary,
        );

    final TextTheme text = Typography.material2021(platform: TargetPlatform.iOS)
        .black
        .apply(bodyColor: textPrimary, displayColor: textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: text.copyWith(
        // Brend nomi va ekran sarlavhalari uchun.
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.2,
          color: textPrimary,
        ),
        // Bo'lim sarlavhalari (masalan, value proposition nomi).
        titleMedium: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        // Ekran ostidagi asosiy izoh matni.
        bodyLarge: text.bodyLarge?.copyWith(color: textSecondary, height: 1.45),
        // Tagline va ikkilamchi matnlar uchun.
        bodyMedium: text.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.4,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
