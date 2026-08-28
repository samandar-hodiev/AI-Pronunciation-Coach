import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/home_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/sign_in_screen.dart';
import 'package:ai_pronunciation_coach/features/goal/domain/goal_options.dart';
import 'package:ai_pronunciation_coach/features/level/domain/english_levels.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/daily_goal_options.dart';
import 'package:ai_pronunciation_coach/features/profile/presentation/profile_setup_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:ai_pronunciation_coach/shared/widgets/selectable_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Goal va Level bosqichlaridan o'tib, sozlash ekraniga keladi.
///
/// Draft to'ldirilishi uchun haqiqiy oqim bosib o'tiladi — bu ayni paytda
/// bosqichlar orasidagi ma'lumot uzatilishini ham tekshiradi.
Future<FakeProfileRepository> pumpThroughSetup(
  WidgetTester tester, {
  FakeProfileRepository? profileRepository,
}) async {
  final FakeProfileRepository repo =
      profileRepository ??
      FakeProfileRepository(profile: testProfile(setupCompleted: false));

  await pumpAppAt(
    tester,
    AppRoutes.goal,
    repository: FakeAuthRepository(existingUser: testUser),
    profileRepository: repo,
  );

  // Maqsad tanlaymiz.
  final Finder goal = find.text(GoalOptions.all[2].title);
  await tester.ensureVisible(goal);
  await tester.pumpAndSettle();
  await tester.tap(goal);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();

  // Daraja tanlaymiz.
  final Finder level = find.text(EnglishLevels.all[2].title);
  await tester.ensureVisible(level);
  await tester.pumpAndSettle();
  await tester.tap(level);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();

  return repo;
}

Future<void> selectDailyGoal(WidgetTester tester, int minutes) async {
  final DailyGoalOption option = DailyGoalOptions.all.firstWhere(
    (DailyGoalOption o) => o.minutes == minutes,
  );
  final Finder finder = find.text(option.title);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

bool ctaEnabled(WidgetTester tester) {
  final PrimaryButton button = tester.widget<PrimaryButton>(
    find.byType(PrimaryButton),
  );
  return button.onPressed != null;
}

void main() {
  group('ProfileSetupScreen', () {
    testWidgets('Goal va Level bosqichlaridan keyin ochiladi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      expect(find.text(ProfileSetupScreen.title), findsOneWidget);
      expect(find.text(ProfileSetupScreen.description), findsOneWidget);
    });

    testWidgets('ism maydoni profildagi qiymat bilan to\'ldiriladi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      final TextFormField field = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Name'),
      );
      expect(field.controller?.text, testProfile(setupCompleted: false).name);
    });

    testWidgets('to\'rtta kunlik maqsad varianti ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      expect(find.byType(SelectableOptionCard), findsNWidgets(4));
      for (final DailyGoalOption option in DailyGoalOptions.all) {
        expect(find.text(option.title), findsOneWidget);
      }
    });

    testWidgets('kunlik maqsad tanlanmaguncha CTA o\'chirilgan', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      expect(ctaEnabled(tester), isFalse);

      await selectDailyGoal(tester, 10);
      expect(ctaEnabled(tester), isTrue);
    });

    testWidgets('bo\'sh ism validatsiya xatosi beradi', (
      WidgetTester tester,
    ) async {
      final FakeProfileRepository repo = await pumpThroughSetup(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), '   ');
      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Name is required.'), findsOneWidget);
      expect(repo.updateCalls, 0);
    });
  });

  group('Sozlashni saqlash', () {
    testWidgets('barcha bosqich tanlovlari birga yuboriladi', (
      WidgetTester tester,
    ) async {
      final FakeProfileRepository repo = await pumpThroughSetup(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Yangi Ism',
      );
      await selectDailyGoal(tester, 15);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(repo.updateCalls, 1);
      expect(repo.savedName, 'Yangi Ism');
      // Goal va Level oldingi ekranlarda tanlangan edi.
      expect(repo.savedGoal, GoalOptions.all[2].id);
      expect(repo.savedLevel, EnglishLevels.all[2].id);
      expect(repo.savedMinutes, 15);
    });

    testWidgets('muvaffaqiyatli saqlash bosh ekranga olib boradi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      await selectDailyGoal(tester, 5);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('saqlash paytida tugma loading holatida bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(
        tester,
        profileRepository: FakeProfileRepository(
          profile: testProfile(setupCompleted: false),
          delay: const Duration(milliseconds: 300),
        ),
      );

      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final PrimaryButton button = tester.widget<PrimaryButton>(
        find.byType(PrimaryButton),
      );
      expect(button.isLoading, isTrue);

      await tester.pumpAndSettle();
    });

    testWidgets('takroriy bosish ikkinchi so\'rov yubormaydi', (
      WidgetTester tester,
    ) async {
      final FakeProfileRepository repo = await pumpThroughSetup(
        tester,
        profileRepository: FakeProfileRepository(
          profile: testProfile(setupCompleted: false),
          delay: const Duration(milliseconds: 300),
        ),
      );

      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.updateCalls, 1);
    });

    testWidgets('server xatosi foydalanuvchiga ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(
        tester,
        profileRepository: FakeProfileRepository(
          profile: testProfile(setupCompleted: false),
          updateResult: const ApiException(
            message: 'Please choose a daily practice goal.',
            code: 'VALIDATION_ERROR',
            statusCode: 422,
          ),
        ),
      );

      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Please choose a daily practice goal.'), findsOneWidget);
      expect(find.byType(ProfileSetupScreen), findsOneWidget);
    });

    testWidgets('kutilmagan xatoda stack trace ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(
        tester,
        profileRepository: FakeProfileRepository(
          profile: testProfile(setupCompleted: false),
          updateResult: StateError('internal failure'),
        ),
      );

      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('StateError'), findsNothing);
    });

    testWidgets('401 xatosi foydalanuvchini qayta kirishga yuboradi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(
        tester,
        profileRepository: FakeProfileRepository(
          profile: testProfile(setupCompleted: false),
          updateResult: const ApiException(
            message: 'Your session has expired.',
            code: 'UNAUTHORIZED',
            statusCode: 401,
          ),
        ),
      );

      await selectDailyGoal(tester, 10);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });

  group('Bosqichlar orasida qaytish', () {
    testWidgets('orqaga qaytilganda tanlov saqlanib qoladi', (
      WidgetTester tester,
    ) async {
      await pumpThroughSetup(tester);

      // Sozlash ekranidan Level'ga qaytamiz.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Oldin tanlangan daraja hali ham belgilangan bo'lishi kerak.
      final SelectableOptionCard card = tester.widget<SelectableOptionCard>(
        find.ancestor(
          of: find.text(EnglishLevels.all[2].title),
          matching: find.byType(SelectableOptionCard),
        ),
      );
      expect(card.isSelected, isTrue);
    });
  });

  group('Layout', () {
    const List<Size> sizes = <Size>[
      Size(320, 568),
      Size(390, 844),
      Size(430, 932),
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpThroughSetup(tester);

          expect(find.byType(ProfileSetupScreen), findsOneWidget);
          expect(find.byType(PrimaryButton), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
