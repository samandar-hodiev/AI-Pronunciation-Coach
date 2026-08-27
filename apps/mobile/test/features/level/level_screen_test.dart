import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/profile/presentation/profile_setup_screen.dart';
import 'package:ai_pronunciation_coach/features/goal/presentation/goal_screen.dart';
import 'package:ai_pronunciation_coach/features/level/domain/english_level.dart';
import 'package:ai_pronunciation_coach/features/level/domain/english_levels.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/level_screen.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/widgets/level_indicator.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:ai_pronunciation_coach/shared/widgets/selectable_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// English Level'dan boshlanadigan ilovani quradi.
Future<void> pumpLevel(WidgetTester tester) async {
  await pumpAppAt(tester, AppRoutes.level);
}

/// Berilgan darajani tanlaydi.
///
/// Kichik viewportlarda pastdagi kartalar ekrandan chiqib ketishi mumkin,
/// shuning uchun avval ko'rinadigan joyga aylantiriladi.
Future<void> selectLevel(WidgetTester tester, EnglishLevel level) async {
  final Finder finder = find.text(level.title);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

bool continueIsEnabled(WidgetTester tester) {
  final PrimaryButton button = tester.widget<PrimaryButton>(
    find.byType(PrimaryButton),
  );
  return button.onPressed != null;
}

bool cardIsSelected(WidgetTester tester, EnglishLevel level) {
  final SelectableOptionCard card = tester.widget<SelectableOptionCard>(
    find.ancestor(
      of: find.text(level.title),
      matching: find.byType(SelectableOptionCard),
    ),
  );
  return card.isSelected;
}

void main() {
  final EnglishLevel beginner = EnglishLevels.all[0];
  final EnglishLevel intermediate = EnglishLevels.all[2];

  group('LevelScreen', () {
    testWidgets('ekran ochiladi', (WidgetTester tester) async {
      await pumpLevel(tester);
      expect(find.byType(LevelScreen), findsOneWidget);
    });

    testWidgets('sarlavha va izoh ko\'rinadi', (WidgetTester tester) async {
      await pumpLevel(tester);

      expect(find.text(LevelScreen.title), findsOneWidget);
      expect(find.text(LevelScreen.description), findsOneWidget);
    });

    testWidgets('beshta daraja ko\'rinadi', (WidgetTester tester) async {
      await pumpLevel(tester);

      expect(find.byType(SelectableOptionCard), findsNWidgets(5));
      for (final EnglishLevel level in EnglishLevels.all) {
        expect(find.text(level.title), findsOneWidget);
        expect(find.text(level.description), findsOneWidget);
      }
    });

    testWidgets('har bir daraja alohida nomlanadi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);

      for (final String title in <String>[
        'Beginner',
        'Elementary',
        'Intermediate',
        'Upper-Intermediate',
        'Advanced',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('daraja ko\'rsatkichi ko\'rinadi', (WidgetTester tester) async {
      await pumpLevel(tester);
      expect(find.byType(LevelIndicator), findsNWidgets(5));
    });

    testWidgets('bosqich konteksti "Step 2 of 2"', (WidgetTester tester) async {
      await pumpLevel(tester);
      expect(find.text('Step 2 of 2'), findsOneWidget);
    });

    testWidgets('Continue tugmasi ko\'rinadi', (WidgetTester tester) async {
      await pumpLevel(tester);
      expect(find.text(LevelScreen.ctaLabel), findsOneWidget);
    });
  });

  group('Tanlov xatti-harakati', () {
    testWidgets('boshida hech narsa tanlanmagan', (WidgetTester tester) async {
      await pumpLevel(tester);

      for (final EnglishLevel level in EnglishLevels.all) {
        expect(cardIsSelected(tester, level), isFalse);
      }
    });

    testWidgets('bosilganda daraja tanlanadi', (WidgetTester tester) async {
      await pumpLevel(tester);
      await selectLevel(tester, beginner);

      expect(cardIsSelected(tester, beginner), isTrue);
    });

    testWidgets('boshqa daraja tanlansa oldingisi bekor bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);

      await selectLevel(tester, beginner);
      expect(cardIsSelected(tester, beginner), isTrue);

      await selectLevel(tester, intermediate);

      expect(cardIsSelected(tester, intermediate), isTrue);
      expect(cardIsSelected(tester, beginner), isFalse);
    });

    testWidgets('bir vaqtda faqat bitta daraja tanlangan bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);
      await selectLevel(tester, EnglishLevels.all[3]);

      final int selectedCount = EnglishLevels.all
          .where((EnglishLevel l) => cardIsSelected(tester, l))
          .length;
      expect(selectedCount, 1);
    });

    testWidgets('tanlangan holat vizual ravishda ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      await selectLevel(tester, beginner);

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('Validation', () {
    testWidgets('Continue boshida o\'chirilgan', (WidgetTester tester) async {
      await pumpLevel(tester);
      expect(continueIsEnabled(tester), isFalse);
    });

    testWidgets('daraja tanlangach Continue yoqiladi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);
      await selectLevel(tester, beginner);

      expect(continueIsEnabled(tester), isTrue);
    });

    testWidgets('tanlovsiz Continue bosilsa navigatsiya bo\'lmaydi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(LevelScreen), findsOneWidget);
      expect(find.byType(ProfileSetupScreen), findsNothing);
    });
  });

  group('Navigatsiya', () {
    testWidgets('Continue Assessment Introduction\'ga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);
      await selectLevel(tester, intermediate);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      expect(find.text(ProfileSetupScreen.title), findsOneWidget);
      expect(find.byType(LevelScreen), findsNothing);
    });

    testWidgets('Back Goal Selection\'ga qaytaradi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(GoalScreen), findsOneWidget);
    });

    testWidgets('navigatsiya paytida exception chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpLevel(tester);
      await selectLevel(tester, beginner);

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
      await pumpLevel(tester);

      final Finder cardFinder = find.byType(SelectableOptionCard).first;
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

      await selectLevel(tester, beginner);

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

  group('Level layout', () {
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

          await pumpLevel(tester);

          expect(find.byType(LevelScreen), findsOneWidget);
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

      await pumpLevel(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
