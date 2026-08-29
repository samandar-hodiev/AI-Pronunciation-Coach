import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Ilovaning markazlashtirilgan mavzusi.
///
/// Ranglar widgetlar ichida qattiq yozilmaydi — hammasi shu yerdan keladi.
/// Light va dark rejim uchun bir xil tuzilma saqlanadi, faqat token
/// qiymatlari almashadi. Shu sababli qorong'i rejim boshqa dizayn emas,
/// aynan o'sha dizaynning ikkinchi varianti.
///
/// [AppColors] dagi semantik rollar Material'ning [ColorScheme] rollariga
/// solishtiriladi, shunda widgetlar odatdagi `Theme.of(context).colorScheme`
/// orqali ishlaydi va ikkinchi mavzu tizimi paydo bo'lmaydi:
///
/// | AppColors          | ColorScheme              |
/// |--------------------|--------------------------|
/// | `primary`          | `primary`                |
/// | `primaryForeground`| `onPrimary`              |
/// | `primarySoft`      | `primaryContainer`       |
/// | `primaryInk`       | `onPrimaryContainer`     |
/// | `background`       | `surface`                |
/// | `surface`          | `surfaceContainerLowest` |
/// | `surfaceSecondary` | `surfaceContainerHighest`|
/// | `textPrimary`      | `onSurface`              |
/// | `textSecondary`    | `onSurfaceVariant`       |
/// | `textTertiary`     | `outline`                |
/// | `border`           | `outlineVariant`         |
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceSecondary: AppColors.surfaceSecondary,
    primary: AppColors.primary,
    primaryForeground: AppColors.primaryForeground,
    primaryInk: AppColors.primaryInk,
    primarySoft: AppColors.primarySoft,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    border: AppColors.border,
    error: AppColors.error,
    onError: AppColors.onError,
    disabled: AppColors.disabled,
    onDisabled: AppColors.onDisabled,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceSecondary: AppColors.surfaceSecondaryDark,
    primary: AppColors.primaryDark,
    primaryForeground: AppColors.primaryForegroundDark,
    primaryInk: AppColors.primaryInkDark,
    primarySoft: AppColors.primarySoftDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    border: AppColors.borderDark,
    error: AppColors.errorDark,
    onError: AppColors.onErrorDark,
    disabled: AppColors.disabledDark,
    onDisabled: AppColors.onDisabledDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceSecondary,
    required Color primary,
    required Color primaryForeground,
    required Color primaryInk,
    required Color primarySoft,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color border,
    required Color error,
    required Color onError,
    required Color disabled,
    required Color onDisabled,
  }) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: primaryForeground,
      primaryContainer: primarySoft,
      onPrimaryContainer: primaryInk,
      // Ikkilamchi rol brend rangining o'zi — palitraga uchinchi ottenok
      // qo'shilmaydi. Ilova bitta urg'u rangida qoladi.
      secondary: primaryInk,
      onSecondary: primaryForeground,
      secondaryContainer: primarySoft,
      onSecondaryContainer: primaryInk,
      surface: background,
      onSurface: textPrimary,
      surfaceContainerLowest: surface,
      surfaceContainerHighest: surfaceSecondary,
      onSurfaceVariant: textSecondary,
      outline: textTertiary,
      outlineVariant: border,
      error: error,
      onError: onError,
    );

    final TextTheme text = _buildTextTheme(
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: text,
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      iconTheme: IconThemeData(color: textSecondary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          // O'chirilgan holat rang va kontrast bilan aniq ajralib turadi —
          // shaffoflik orqali "so'nib qolgan" ko'rinish ishlatilmaydi.
          disabledBackgroundColor: disabled,
          disabledForegroundColor: onDisabled,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryInk,
          // Kenglik majburlanmaydi: TextButton matn ichida ham, alohida
          // ham ishlatiladi. `Size.fromHeight` cheksiz kenglik bergani
          // uchun uni Row ichida ishlatib bo'lmasdi.
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: text.labelLarge,
        ),
      ),
    );
  }

  /// Tipografiya shkalasi.
  ///
  /// Ataylab olti rol bilan cheklangan: katta sarlavha, bo'lim sarlavhasi,
  /// asosiy matn, ikkilamchi matn, tugma yorlig'i va izoh. Har bir ekran
  /// shulardan foydalanadi — ekran ichida `fontSize` yozilmaydi.
  static TextTheme _buildTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
  }) {
    final TextTheme base = Typography.material2021(
      platform: TargetPlatform.iOS,
    ).black.apply(bodyColor: textPrimary, displayColor: textPrimary);

    return base.copyWith(
      // Ekran sarlavhasi.
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.2,
        color: textPrimary,
      ),
      // Bo'lim va karta sarlavhasi.
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textPrimary,
      ),
      // Sarlavha ostidagi asosiy izoh.
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        color: textSecondary,
      ),
      // Ikkilamchi matn.
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        color: textSecondary,
      ),
      // Tugma yorlig'i.
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      // Izoh, bosqich ko'rsatkichi.
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textTertiary,
      ),
    );
  }
}
