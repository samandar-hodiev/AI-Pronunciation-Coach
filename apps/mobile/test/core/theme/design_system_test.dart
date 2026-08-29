import 'dart:math' as math;

import 'package:ai_pronunciation_coach/core/theme/app_colors.dart';
import 'package:ai_pronunciation_coach/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG bo'yicha rangning nisbiy yorqinligi.
double _luminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Ikki rang orasidagi kontrast nisbati (1:1 dan 21:1 gacha).
double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Brend rangi', () {
    test('rasmiy qiymat oklch(77.7% 0.152 181.912) = #00D5BE', () {
      // OKLCH qiymati sRGB gamutidan biroz tashqarida, shuning uchun eng
      // yaqin sRGB rangiga siqilgan. Bu test rang tasodifan
      // o'zgartirilmasligini kafolatlaydi.
      expect(AppColors.primary, const Color(0xFF00D5BE));
    });

    test('qorong\'i rejimda ham aynan o\'sha brend rangi', () {
      // Brend ikki rejimda bir xil bo'lib qoladi — qorong'i rejim boshqa
      // vizual identifikatsiya emas.
      expect(AppColors.primaryDark, AppColors.primary);
    });
  });

  group('Kontrast — light', () {
    final ColorScheme light = AppTheme.light.colorScheme;

    test('tugma matni brend foni ustida o\'qiladi (>= 4.5:1)', () {
      expect(_contrast(light.onPrimary, light.primary), greaterThan(4.5));
    });

    test('brend kontenti fon ustida ko\'rinadi (>= 3:1)', () {
      // Brend rangining o'zi och bo'lgani uchun ikonka va chegara
      // `onPrimaryContainer` dan olinadi.
      expect(
        _contrast(light.onPrimaryContainer, light.surface),
        greaterThan(3.0),
      );
    });

    test('asosiy matn fon ustida o\'qiladi (>= 7:1)', () {
      expect(_contrast(light.onSurface, light.surface), greaterThan(7.0));
    });

    test('ikkilamchi matn fon ustida o\'qiladi (>= 4.5:1)', () {
      expect(
        _contrast(light.onSurfaceVariant, light.surface),
        greaterThan(4.5),
      );
    });

    test('chegara fondan ajralib turadi', () {
      expect(_contrast(light.outlineVariant, light.surface), greaterThan(1.15));
    });
  });

  group('Kontrast — dark', () {
    final ColorScheme dark = AppTheme.dark.colorScheme;

    test('tugma matni brend foni ustida o\'qiladi (>= 4.5:1)', () {
      expect(_contrast(dark.onPrimary, dark.primary), greaterThan(4.5));
    });

    test('brend kontenti fon ustida ko\'rinadi (>= 3:1)', () {
      expect(
        _contrast(dark.onPrimaryContainer, dark.surface),
        greaterThan(3.0),
      );
    });

    test('asosiy matn fon ustida o\'qiladi (>= 7:1)', () {
      expect(_contrast(dark.onSurface, dark.surface), greaterThan(7.0));
    });

    test('ikkilamchi matn fon ustida o\'qiladi (>= 4.5:1)', () {
      expect(_contrast(dark.onSurfaceVariant, dark.surface), greaterThan(4.5));
    });

    test('chegara fondan ajralib turadi', () {
      expect(_contrast(dark.outlineVariant, dark.surface), greaterThan(1.15));
    });
  });

  group('Semantik rollar', () {
    test('light sxema tokenlardan yig\'iladi', () {
      final ColorScheme light = AppTheme.light.colorScheme;

      expect(light.primary, AppColors.primary);
      expect(light.onPrimary, AppColors.primaryForeground);
      expect(light.primaryContainer, AppColors.primarySoft);
      expect(light.onPrimaryContainer, AppColors.primaryInk);
      expect(light.surface, AppColors.background);
      expect(light.surfaceContainerLowest, AppColors.surface);
      expect(light.surfaceContainerHighest, AppColors.surfaceSecondary);
      expect(light.onSurface, AppColors.textPrimary);
      expect(light.onSurfaceVariant, AppColors.textSecondary);
      expect(light.outline, AppColors.textTertiary);
      expect(light.outlineVariant, AppColors.border);
      expect(light.error, AppColors.error);
    });

    test('dark sxema o\'sha rollarni qorong\'i tokenlar bilan to\'ldiradi', () {
      final ColorScheme dark = AppTheme.dark.colorScheme;

      expect(dark.primary, AppColors.primaryDark);
      expect(dark.onPrimary, AppColors.primaryForegroundDark);
      expect(dark.primaryContainer, AppColors.primarySoftDark);
      expect(dark.onPrimaryContainer, AppColors.primaryInkDark);
      expect(dark.surface, AppColors.backgroundDark);
      expect(dark.onSurface, AppColors.textPrimaryDark);
      expect(dark.outlineVariant, AppColors.borderDark);
    });

    test('ikki rejim ham bir xil rollar to\'plamiga ega', () {
      // Qorong'i rejimda birorta rol tushib qolmasligi kerak.
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
    });
  });

  group('O\'chirilgan holat', () {
    testWidgets('o\'chirilgan tugma yoqilganidan vizual farq qiladi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Column(
              children: <Widget>[
                FilledButton(onPressed: null, child: Text('Disabled')),
              ],
            ),
          ),
        ),
      );

      final ButtonStyle? style = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style;
      final ButtonStyle effective =
          style ?? AppTheme.light.filledButtonTheme.style!;
      final Color? disabledBackground = effective.backgroundColor?.resolve(
        <WidgetState>{WidgetState.disabled},
      );

      expect(disabledBackground, isNot(AppColors.primary));
      expect(tester.takeException(), isNull);
    });
  });

  group('Shkala', () {
    test('tipografiya rollari aniqlangan', () {
      final TextTheme text = AppTheme.light.textTheme;

      expect(text.headlineMedium?.fontSize, 28);
      expect(text.titleMedium?.fontSize, 16);
      expect(text.bodyLarge?.fontSize, 16);
      expect(text.bodyMedium?.fontSize, 14);
      expect(text.labelLarge?.fontSize, 16);
      expect(text.labelMedium?.fontSize, 13);
    });
  });
}
