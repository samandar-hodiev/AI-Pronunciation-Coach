import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/goal/domain/goal_option.dart';
import 'package:ai_pronunciation_coach/features/goal/domain/goal_options.dart';
import 'package:ai_pronunciation_coach/features/goal/presentation/goal_screen.dart';
import 'package:ai_pronunciation_coach/features/goal/presentation/widgets/goal_option_card.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/level_screen.dart';
import 'package:ai_pronunciation_coach/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Goal Selection'dan boshlanadigan ilovani quradi.
Future<void> pumpGoal(WidgetTester tester) async {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.goal,
    routes: AppRouter.create().configuration.routes,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(AiPronunciationCoachApp(router: router));
  await tester.pumpAndSettle();
}

/// Berilgan maqsad kartasini bosadi.
///
/// Kichik viewportlarda pastdagi kartalar ekrandan chiqib ketishi mumkin,
/// shuning uchun avval ko'rinadigan joyga aylantiriladi.
Future<void> selectGoal(WidgetTester tester, GoalOption option) async {
  final Finder finder = find.text(option.title);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Continue tugmasi hozir yoqilganmi?
bool continueIsEnabled(WidgetTester tester) {
  final PrimaryButton button = tester.widget<PrimaryButton>(
    find.byType(PrimaryButton),
  );
  return button.onPressed != null;
}

/// Berilgan kartaning tanlangan holatini qaytaradi.
bool cardIsSelected(WidgetTester tester, GoalOption option) {
  final GoalOptionCard card = tester.widget<GoalOptionCard>(
    find.ancestor(
      of: find.text(option.title),
      matching: find.byType(GoalOptionCard),
    ),
  );
  return card.isSelected;
}

void main() {
  final GoalOption first = GoalOptions.all.first;
  final GoalOption second = GoalOptions.all[1];

  group('GoalScreen', () {
    testWidgets('ekran ochiladi', (WidgetTester tester) async {
      await pumpGoal(tester);
      expect(find.byType(GoalScreen), findsOneWidget);
    });

    testWidgets('sarlavha va izoh ko\'rinadi', (WidgetTester tester) async {
      await pumpGoal(tester);

      expect(find.text(GoalScreen.title), findsOneWidget);
      expect(find.text(GoalScreen.description), findsOneWidget);
    });

    testWidgets('beshta maqsad varianti ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);

      expect(find.byType(GoalOptionCard), findsNWidgets(5));
      for (final GoalOption option in GoalOptions.all) {
        expect(find.text(option.title), findsOneWidget);
        expect(find.text(option.description), findsOneWidget);
      }
    });

    testWidgets('bosqich konteksti ko\'rinadi', (WidgetTester tester) async {
      await pumpGoal(tester);
      expect(find.text('Step 1 of 2'), findsOneWidget);
    });

    testWidgets('Continue tugmasi ko\'rinadi', (WidgetTester tester) async {
      await pumpGoal(tester);
      expect(find.text(GoalScreen.ctaLabel), findsOneWidget);
    });
  });

  group('Tanlov xatti-harakati', () {
    testWidgets('boshida hech narsa tanlanmagan', (WidgetTester tester) async {
      await pumpGoal(tester);

      for (final GoalOption option in GoalOptions.all) {
        expect(cardIsSelected(tester, option), isFalse);
      }
    });

    testWidgets('bosilganda variant tanlanadi', (WidgetTester tester) async {
      await pumpGoal(tester);
      await selectGoal(tester, first);

      expect(cardIsSelected(tester, first), isTrue);
    });

    testWidgets('boshqa variant tanlansa oldingisi bekor bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);

      await selectGoal(tester, first);
      expect(cardIsSelected(tester, first), isTrue);

      await selectGoal(tester, second);

      expect(cardIsSelected(tester, second), isTrue);
      expect(cardIsSelected(tester, first), isFalse);
    });

    testWidgets('bir vaqtda faqat bitta variant tanlangan bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);
      await selectGoal(tester, GoalOptions.all[3]);

      final int selectedCount = GoalOptions.all
          .where((GoalOption o) => cardIsSelected(tester, o))
          .length;
      expect(selectedCount, 1);
    });

    testWidgets('tanlangan holat vizual ravishda ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);

      // Tanlanmagan holatda belgi bo'sh doira.
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      await selectGoal(tester, first);

      // Tanlangandan keyin faqat bitta belgi paydo bo'ladi.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('Validation', () {
    testWidgets('Continue boshida o\'chirilgan', (WidgetTester tester) async {
      await pumpGoal(tester);
      expect(continueIsEnabled(tester), isFalse);
    });

    testWidgets('maqsad tanlangach Continue yoqiladi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);
      await selectGoal(tester, first);

      expect(continueIsEnabled(tester), isTrue);
    });

    testWidgets('tanlovsiz Continue bosilsa navigatsiya bo\'lmaydi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(GoalScreen), findsOneWidget);
      expect(find.byType(LevelScreen), findsNothing);
    });
  });

  group('Navigatsiya', () {
    testWidgets('Continue English Level ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);
      await selectGoal(tester, first);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(LevelScreen), findsOneWidget);
      expect(find.text(LevelScreen.placeholderLabel), findsOneWidget);
      expect(find.byType(GoalScreen), findsNothing);
    });

    testWidgets('Back Onboarding\'ga qaytaradi', (WidgetTester tester) async {
      await pumpGoal(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('navigatsiya paytida exception chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpGoal(tester);
      await selectGoal(tester, first);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility', () {
    testWidgets('kartalar tanlangan holatini e\'lon qiladi', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpGoal(tester);

      final Finder cardFinder = find.byType(GoalOptionCard).first;
      expect(
        tester.getSemantics(cardFinder),
        matchesSemantics(
          hasSelectedState: true,
          isSelected: false,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      await selectGoal(tester, first);

      expect(
        tester.getSemantics(cardFinder),
        matchesSemantics(
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      handle.dispose();
    });
  });

  group('Goal layout', () {
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

          await pumpGoal(tester);

          expect(find.byType(GoalScreen), findsOneWidget);
          // Continue har qanday balandlikda ko'rinib turishi kerak.
          expect(find.byType(PrimaryButton), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('kichik ekranda kontent aylanadi', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpGoal(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
