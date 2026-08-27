import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/create_account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/sign_in_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Formani to'g'ri qiymatlar bilan to'ldiradi.
Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Name'),
    'Samandar',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    'new@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'password123',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirm password'),
    'password123',
  );
  await tester.pump();
}

void main() {
  group('CreateAccountScreen', () {
    testWidgets('ekran va forma maydonlari ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.createAccount);

      expect(find.byType(CreateAccountScreen), findsOneWidget);
      expect(find.text(CreateAccountScreen.title), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirm password'),
        findsOneWidget,
      );
    });

    testWidgets('bo\'sh forma yuborilsa validatsiya xatolari chiqadi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.createAccount,
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);

      // Validatsiya o'tmagani uchun tarmoqqa chiqilmasligi kerak.
      expect(repo.registerCalls, 0);
    });

    testWidgets('parollar mos kelmasa xato chiqadi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.createAccount,
      );

      await fillValidForm(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'different123',
      );
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(repo.registerCalls, 0);
    });

    testWidgets(
      'muvaffaqiyatli ro\'yxatdan o\'tish Account ekraniga olib boradi',
      (WidgetTester tester) async {
        final FakeAuthRepository repo = await pumpAppAt(
          tester,
          AppRoutes.createAccount,
          repository: FakeAuthRepository(registerResult: testUser),
        );

        await fillValidForm(tester);
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        expect(repo.registerCalls, 1);
        expect(find.byType(AccountScreen), findsOneWidget);
        expect(find.text(testUser.name), findsOneWidget);
        expect(find.text(testUser.email), findsOneWidget);
      },
    );

    testWidgets('backend xatosi foydalanuvchiga ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.createAccount,
        repository: FakeAuthRepository(
          registerResult: const ApiException(
            message: 'An account with this email already exists.',
            code: 'EMAIL_ALREADY_REGISTERED',
            statusCode: 409,
          ),
        ),
      );

      await fillValidForm(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('An account with this email already exists.'),
        findsOneWidget,
      );
      // Ekran o'zgarmasligi kerak.
      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });

    testWidgets('kutilmagan xatoda ham stack trace ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.createAccount,
        repository: FakeAuthRepository(
          registerResult: StateError('internal database failure'),
        ),
      );

      await fillValidForm(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('StateError'), findsNothing);
      expect(find.textContaining('internal database failure'), findsNothing);
    });

    testWidgets('yuborish paytida tugma loading holatida bo\'ladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.createAccount,
        repository: FakeAuthRepository(
          registerResult: testUser,
          delay: const Duration(milliseconds: 300),
        ),
      );

      await fillValidForm(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      // So'rov davom etayotganda spinner ko'rinadi va tugma o'chirilgan.
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
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.createAccount,
        repository: FakeAuthRepository(
          registerResult: testUser,
          delay: const Duration(milliseconds: 300),
        ),
      );

      await fillValidForm(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      await tester.pumpAndSettle();

      expect(repo.registerCalls, 1);
    });

    testWidgets('Sign in havolasi kirish ekraniga olib boradi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.createAccount);

      final Finder link = find.text(CreateAccountScreen.signInPrompt);
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });
}
