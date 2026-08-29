import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/assessment/presentation/assessment_intro_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/create_account_screen.dart';
import 'package:ai_pronunciation_coach/features/goal/domain/goal_options.dart';
import 'package:ai_pronunciation_coach/features/goal/presentation/goal_screen.dart';
import 'package:ai_pronunciation_coach/features/level/domain/english_levels.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/level_screen.dart';
import 'package:ai_pronunciation_coach/features/microphone/presentation/microphone_screen.dart';
import 'package:ai_pronunciation_coach/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ai_pronunciation_coach/features/welcome/presentation/welcome_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:ai_pronunciation_coach/shared/widgets/secondary_button.dart';
import 'package:ai_pronunciation_coach/shared/widgets/selectable_option_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Personalizatsiya oqimining uchdan-uchgacha testi.
///
/// Har bir ekran o'z faylida alohida testlangan. Bu yerda tekshiriladigan
/// narsa — **ekranlar orasidagi bog'lanish**: to'g'ri tartib, orqaga
/// qaytish va tanlovlarning yo'qolib qolmasligi.
void main() {
  Future<void> tapPrimary(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
  }

  Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
  }

  Future<void> selectFirstOption(WidgetTester tester) async {
    await tester.tap(find.byType(SelectableOptionCard).first);
    await tester.pumpAndSettle();
  }

  group('Oldinga oqim', () {
    testWidgets('Welcome → Onboarding → Goal → Level → Assessment Intro', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.welcome);
      expect(find.byType(WelcomeScreen), findsOneWidget);

      await tapPrimary(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Onboarding'ni Skip bilan tugatamiz — natija oxirgi CTA bilan bir xil.
      await tester.tap(find.text(OnboardingScreen.skipLabel));
      await tester.pumpAndSettle();
      expect(find.byType(GoalScreen), findsOneWidget);

      await selectFirstOption(tester);
      await tapPrimary(tester);
      expect(find.byType(LevelScreen), findsOneWidget);

      await selectFirstOption(tester);
      await tapPrimary(tester);
      expect(find.byType(AssessmentIntroScreen), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('oqim autentifikatsiya so\'ramasdan o\'tadi', (
      WidgetTester tester,
    ) async {
      // Goal va Level endi himoyalangan yo'llar emas: tanlovlar lokal
      // draft'da turadi va backend'ga faqat keyinroq yuboriladi.
      expect(AppRoutes.isProtected(AppRoutes.goal), isFalse);
      expect(AppRoutes.isProtected(AppRoutes.level), isFalse);
      expect(AppRoutes.isProtected(AppRoutes.assessmentIntro), isFalse);

      await pumpAppAt(tester, AppRoutes.goal);

      expect(find.byType(GoalScreen), findsOneWidget);
      expect(find.byType(CreateAccountScreen), findsNothing);
    });
  });

  group('Orqaga qaytish', () {
    testWidgets('Assessment Intro → Level → Goal → Onboarding', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.goal);

      await selectFirstOption(tester);
      await tapPrimary(tester);
      await selectFirstOption(tester);
      await tapPrimary(tester);
      expect(find.byType(AssessmentIntroScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(LevelScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(GoalScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('orqaga qaytganda tanlangan maqsad saqlanib qoladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.goal);

      await selectFirstOption(tester);
      await tapPrimary(tester);
      expect(find.byType(LevelScreen), findsOneWidget);

      await tapBack(tester);

      // Tanlov draft'da saqlangani uchun karta hali ham tanlangan holatda.
      final SelectableOptionCard first = tester.widget<SelectableOptionCard>(
        find.byType(SelectableOptionCard).first,
      );
      expect(first.isSelected, isTrue);
      expect(first.title, GoalOptions.all.first.title);

      // Tanlov mavjud bo'lgani uchun Continue darhol yoqilgan.
      final PrimaryButton cta = tester.widget<PrimaryButton>(
        find.byType(PrimaryButton),
      );
      expect(cta.onPressed, isNotNull);
    });

    testWidgets('orqaga qaytganda tanlangan daraja saqlanib qoladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.goal);

      await selectFirstOption(tester);
      await tapPrimary(tester);
      await selectFirstOption(tester);
      await tapPrimary(tester);
      expect(find.byType(AssessmentIntroScreen), findsOneWidget);

      await tapBack(tester);

      final SelectableOptionCard first = tester.widget<SelectableOptionCard>(
        find.byType(SelectableOptionCard).first,
      );
      expect(first.isSelected, isTrue);
      expect(first.title, EnglishLevels.all.first.title);
    });
  });

  group('Assessment Intro chegarasi', () {
    testWidgets('"Start assessment" keyingi bosqich chegarasiga o\'tadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.assessmentIntro);

      await tapPrimary(tester);

      // Mikrofon ruxsati va audio bu taskda amalga oshirilmagan — bu
      // ataylab qo'yilgan, hujjatlashtirilgan chegara ekrani.
      expect(find.byType(MicrophoneScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Not now" hisob yaratishga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.assessmentIntro);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      // Baholash majburiy emas: keyingi ochiq qadam — hisob yaratish.
      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });
  });
}
