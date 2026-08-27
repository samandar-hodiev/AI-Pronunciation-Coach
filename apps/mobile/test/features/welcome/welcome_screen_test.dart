import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/onboarding/domain/onboarding_content.dart';
import 'package:ai_pronunciation_coach/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ai_pronunciation_coach/features/welcome/presentation/welcome_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/brand_mark.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:ai_pronunciation_coach/shared/widgets/value_proposition_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Welcome ekranidan boshlanadigan ilovani quradi.
///
/// Splash taymerini kutmaslik uchun router to'g'ridan-to'g'ri `/welcome` dan
/// boshlanadi — shunda testlar tez va barqaror bo'ladi.
Future<void> pumpWelcome(WidgetTester tester) async {
  await pumpAppAt(tester, AppRoutes.welcome);
}

void main() {
  group('WelcomeScreen', () {
    testWidgets('ekran ochiladi', (WidgetTester tester) async {
      await pumpWelcome(tester);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('asosiy sarlavha ko\'rinadi', (WidgetTester tester) async {
      await pumpWelcome(tester);
      expect(find.text(WelcomeScreen.headline), findsOneWidget);
    });

    testWidgets('izoh matni ko\'rinadi', (WidgetTester tester) async {
      await pumpWelcome(tester);
      expect(find.text(WelcomeScreen.description), findsOneWidget);
    });

    testWidgets('brend belgisi ko\'rinadi', (WidgetTester tester) async {
      await pumpWelcome(tester);
      expect(find.byType(BrandMark), findsOneWidget);
    });

    testWidgets('uchta value proposition ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpWelcome(tester);

      expect(find.byType(ValuePropositionItem), findsNWidgets(3));
      for (final prop in WelcomeScreen.valuePropositions) {
        expect(find.text(prop.title), findsOneWidget);
        expect(find.text(prop.description), findsOneWidget);
      }
    });

    testWidgets('CTA tugmasi ko\'rinadi', (WidgetTester tester) async {
      await pumpWelcome(tester);

      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text(WelcomeScreen.ctaLabel), findsOneWidget);
    });

    testWidgets('CTA Onboarding\'ga o\'tkazadi', (WidgetTester tester) async {
      await pumpWelcome(tester);

      expect(find.byType(OnboardingScreen), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text(OnboardingContent.items.first.title), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('navigatsiya paytida exception chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpWelcome(tester);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA ekran o\'quvchisi uchun tugma sifatida belgilangan', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpWelcome(tester);

      expect(
        tester.getSemantics(find.byType(PrimaryButton)),
        matchesSemantics(
          label: WelcomeScreen.ctaLabel,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
        ),
      );

      handle.dispose();
    });
  });

  group('Welcome layout', () {
    const List<Size> sizes = <Size>[
      Size(320, 568), // iPhone SE (1-avlod)
      Size(375, 667), // iPhone SE (2/3-avlod)
      Size(390, 844), // iPhone 14/15
      Size(393, 852), // iPhone 16
      Size(430, 932), // iPhone 15/16 Pro Max
      Size(440, 956), // iPhone 17 Pro Max
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpWelcome(tester);

          expect(find.byType(WelcomeScreen), findsOneWidget);
          // CTA har qanday balandlikda ko'rinib turishi kerak.
          expect(find.byType(PrimaryButton), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('kichik ekranda kontent aylanadi', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpWelcome(tester);

      final Finder scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);

      await tester.drag(scrollable, const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
