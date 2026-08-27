import 'package:ai_pronunciation_coach/features/splash/presentation/splash_screen.dart';
import 'package:ai_pronunciation_coach/features/welcome/presentation/welcome_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/app_wordmark.dart';
import 'package:ai_pronunciation_coach/shared/widgets/brand_mark.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('ilova ishga tushadi va splash ochiladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('ilova nomi va tagline ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump();

      expect(find.text(AppWordmark.appName), findsOneWidget);
      expect(find.text('Speak better. Pronounce better.'), findsOneWidget);
    });

    testWidgets('brend belgisi ko\'rinadi', (WidgetTester tester) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump();

      expect(find.byType(BrandMark), findsOneWidget);
    });

    testWidgets('splash Welcome placeholder\'ga o\'tadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump();

      expect(find.byType(WelcomeScreen), findsNothing);

      // Timer ishga tushishi uchun kutamiz, keyin o'tish animatsiyasini
      // yakunlaymiz.
      await tester.pump(SplashScreen.displayDuration);
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text(WelcomeScreen.headline), findsOneWidget);
    });

    testWidgets('navigatsiya paytida xatolik chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump(SplashScreen.displayDuration);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('widget vaqtidan oldin yo\'q qilinsa timer xato bermaydi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.splash, settle: false);
      await tester.pump();

      // Splash hali ko'rinib turganda daraxtni almashtiramiz.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(SplashScreen.displayDuration);

      expect(tester.takeException(), isNull);
    });
  });

  group('Splash layout', () {
    // Eng tor va eng keng iPhone viewportlari.
    const List<Size> sizes = <Size>[
      Size(320, 568), // iPhone SE (1-avlod) — eng tor holat
      Size(390, 844), // iPhone 14/15/16
      Size(402, 874), // iPhone 17
      Size(440, 956), // iPhone Pro Max
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpAppAt(tester, AppRoutes.splash, settle: false);
          await tester.pump();

          expect(find.byType(SplashScreen), findsOneWidget);
          // Overflow bo'lsa Flutter exception qo'yadi.
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
