import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/create_account_screen.dart';
import 'package:ai_pronunciation_coach/features/onboarding/domain/onboarding_content.dart';
import 'package:ai_pronunciation_coach/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ai_pronunciation_coach/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Onboarding'dan boshlanadigan ilovani quradi.
///
/// Splash taymerini kutmaslik uchun router to'g'ridan-to'g'ri `/onboarding`
/// dan boshlanadi. Bu ayni paytda ekranning mustaqil ochilishini ham
/// tekshiradi — u Splash yoki Welcome holatiga bog'liq emas.
Future<void> pumpOnboarding(WidgetTester tester) async {
  await pumpAppAt(tester, AppRoutes.onboarding);
}

/// Asosiy tugmani bosib, animatsiya tugashini kutadi.
Future<void> tapPrimary(WidgetTester tester) async {
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

void main() {
  final first = OnboardingContent.items[0];
  final second = OnboardingContent.items[1];
  final third = OnboardingContent.items[2];

  group('OnboardingScreen', () {
    testWidgets('ekran ochiladi', (WidgetTester tester) async {
      await pumpOnboarding(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('1-sahifa sarlavhasi va izohi ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      expect(find.text(first.title), findsOneWidget);
      expect(find.text(first.description), findsOneWidget);
    });

    testWidgets('sahifa indikatori ko\'rinadi', (WidgetTester tester) async {
      await pumpOnboarding(tester);
      expect(find.byType(OnboardingPageIndicator), findsOneWidget);
    });

    testWidgets('boshida "Next" tugmasi ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      expect(find.text(OnboardingScreen.nextLabel), findsOneWidget);
    });

    testWidgets('birinchi sahifada orqaga tugmasi bosilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      // Tugma joyni egallaydi, lekin ko'rinmaydi va bosilmaydi.
      final Finder back = find.byTooltip('Go back');
      expect(back, findsOneWidget);
      expect(
        tester
            .widget<Visibility>(
              find.ancestor(of: back, matching: find.byType(Visibility)).first,
            )
            .visible,
        isFalse,
      );
    });
  });

  group('Sahifalar orasida harakat', () {
    testWidgets('"Next" 1-sahifadan 2-sahifaga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);

      expect(find.text(second.title), findsOneWidget);
      expect(find.text(first.title), findsNothing);
    });

    testWidgets('"Next" 2-sahifadan 3-sahifaga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);

      expect(find.text(third.title), findsOneWidget);
    });

    testWidgets('oxirgi sahifada CTA matni "Get started" ga o\'zgaradi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);

      expect(find.text(OnboardingScreen.finishLabel), findsOneWidget);
      expect(find.text(OnboardingScreen.nextLabel), findsNothing);
    });

    testWidgets('surish (swipe) bilan ham sahifa almashadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text(second.title), findsOneWidget);
    });

    testWidgets('orqaga tugmasi oldingi sahifaga qaytaradi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      expect(find.text(second.title), findsOneWidget);

      await tester.tap(find.byTooltip('Go back'));
      await tester.pumpAndSettle();

      expect(find.text(first.title), findsOneWidget);
      expect(find.text(OnboardingScreen.nextLabel), findsOneWidget);
    });

    testWidgets('3-sahifadan orqaga 2-sahifaga qaytaradi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);

      await tester.tap(find.byTooltip('Go back'));
      await tester.pumpAndSettle();

      expect(find.text(second.title), findsOneWidget);
    });
  });

  group('Onboarding tugashi', () {
    testWidgets('oxirgi CTA Goal ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);

      expect(find.byType(CreateAccountScreen), findsOneWidget);
      expect(find.text(CreateAccountScreen.title), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('Skip birinchi sahifadan Goal ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      await tester.tap(find.text(OnboardingScreen.skipLabel));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });

    testWidgets('Skip o\'rta sahifadan ham ishlaydi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);

      await tester.tap(find.text(OnboardingScreen.skipLabel));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });

    testWidgets('navigatsiya paytida exception chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);
      await tapPrimary(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility', () {
    testWidgets('indikator joriy sahifani e\'lon qiladi', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpOnboarding(tester);

      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);

      await tapPrimary(tester);
      expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);

      handle.dispose();
    });
  });

  group('Onboarding layout', () {
    const List<Size> sizes = <Size>[
      Size(320, 568),
      Size(375, 667),
      Size(390, 844),
      Size(393, 852),
      Size(430, 932),
      Size(440, 956),
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpOnboarding(tester);

          expect(find.byType(OnboardingScreen), findsOneWidget);
          expect(find.byType(PrimaryButton), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Barcha sahifalarda ham tekshiramiz.
          await tapPrimary(tester);
          await tapPrimary(tester);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
