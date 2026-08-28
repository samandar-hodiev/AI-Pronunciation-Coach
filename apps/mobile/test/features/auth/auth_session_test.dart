import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/home_screen.dart';
import 'package:ai_pronunciation_coach/features/splash/presentation/splash_screen.dart';
import 'package:ai_pronunciation_coach/features/welcome/presentation/welcome_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  group('Sessiya tiklash', () {
    testWidgets('saqlangan sessiya bo\'lsa Splash Account\'ga o\'tadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.splash,
        repository: FakeAuthRepository(existingUser: testUser),
        settle: false,
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(SplashScreen.displayDuration);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('sessiya bo\'lmasa Splash Welcome\'ga o\'tadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.splash,
        repository: FakeAuthRepository(),
        settle: false,
      );

      await tester.pump(SplashScreen.displayDuration);
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('sessiya sekin tiklansa Splash kutib turadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.splash,
        repository: FakeAuthRepository(
          existingUser: testUser,
          delay: const Duration(seconds: 3),
        ),
        settle: false,
      );

      // Eng kam ko'rsatish vaqti tugadi, lekin sessiya hali aniqlanmagan —
      // ekran hech qayerga o'tmasligi kerak.
      await tester.pump(SplashScreen.displayDuration);
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      // Sessiya aniqlangach o'tadi.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Chiqish', () {
    testWidgets('Log out sessiyani tugatadi va Welcome\'ga qaytaradi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.account,
        repository: FakeAuthRepository(existingUser: testUser),
      );

      expect(find.text(testUser.email), findsOneWidget);

      await tester.tap(find.text(AccountScreen.signOutLabel));
      await tester.pumpAndSettle();

      expect(repo.signOutCalls, 1);
      expect(repo.signedOut, isTrue);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });
}
