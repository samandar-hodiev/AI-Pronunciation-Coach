import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/goal/domain/goal_options.dart';
import 'package:ai_pronunciation_coach/features/goal/presentation/goal_screen.dart';
import 'package:ai_pronunciation_coach/features/level/domain/english_levels.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/level_screen.dart';
import 'package:ai_pronunciation_coach/features/profile/presentation/profile_setup_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Haqiqiy qurilmada to'liq sozlash oqimi.
///
/// Mock yo'q: haqiqiy repozitoriylar, haqiqiy Keychain va ishlab turgan Go
/// backend orqali o'tadi.
///
/// ```
/// flutter test integration_test/profile_setup_flow_test.dart -d <device-id>
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String uniqueEmail() =>
      'setup-${DateTime.now().microsecondsSinceEpoch}@example.com';

  int pumpCount = 0;

  Future<void> pumpAt(WidgetTester tester, String location) async {
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: AppRouter.create().configuration.routes,
    );
    addTearDown(router.dispose);

    // Noyob kalit: aks holda Flutter mavjud State'ni qayta ishlatadi va
    // ilova eski router'da qolib ketadi.
    pumpCount++;
    await tester.pumpWidget(
      ProviderScope(
        child: AiPronunciationCoachApp(
          key: ValueKey<int>(pumpCount),
          router: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final Finder field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final Finder finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('ro\'yxatdan o\'tish va to\'liq profil sozlash', (
    WidgetTester tester,
  ) async {
    final String email = uniqueEmail();

    // 1. Hisob yaratamiz.
    await pumpAt(tester, AppRoutes.createAccount);
    await enterField(tester, 'Name', 'Setup Flow');
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await enterField(tester, 'Confirm password', 'password123');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.byType(AccountScreen), findsOneWidget);

    // 2. Sozlashni boshlaymiz: maqsad.
    await pumpAt(tester, AppRoutes.goal);
    expect(find.byType(GoalScreen), findsOneWidget);
    await tapText(tester, GoalOptions.all[1].title);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    // 3. Daraja.
    expect(find.byType(LevelScreen), findsOneWidget);
    await tapText(tester, EnglishLevels.all[3].title);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    // 4. Ism va kunlik maqsad.
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    await enterField(tester, 'Name', 'Setup Flow Done');
    await tapText(tester, '15 minutes');

    await tester.tap(find.byType(PrimaryButton));
    // Haqiqiy PUT /api/v1/profile so'rovi.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 5. Sozlash tugadi.
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text('Setup Flow Done'), findsOneWidget);
  });

  testWidgets('sozlagan foydalanuvchi Splash\'dan Account\'ga o\'tadi', (
    WidgetTester tester,
  ) async {
    final String email = uniqueEmail();

    await pumpAt(tester, AppRoutes.createAccount);
    await enterField(tester, 'Name', 'Returning User');
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await enterField(tester, 'Confirm password', 'password123');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Sozlashni tugatamiz.
    await pumpAt(tester, AppRoutes.goal);
    await tapText(tester, GoalOptions.all[0].title);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tapText(tester, EnglishLevels.all[0].title);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tapText(tester, '5 minutes');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.byType(AccountScreen), findsOneWidget);

    // Ilovani qaytadan ochamiz — token Keychain'da, profil sozlangan.
    await pumpAt(tester, AppRoutes.splash);
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Sozlash qayta so'ralmasligi kerak.
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.byType(GoalScreen), findsNothing);
  });
}
