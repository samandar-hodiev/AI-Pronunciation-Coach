import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/create_account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/sign_in_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

Future<void> fillCredentials(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    'user@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'password123',
  );
  await tester.pump();
}

void main() {
  group('SignInScreen', () {
    testWidgets('ekran va maydonlar ko\'rinadi', (WidgetTester tester) async {
      await pumpAppAt(tester, AppRoutes.signIn);

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text(SignInScreen.title), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('bo\'sh forma tarmoqqa chiqmaydi', (WidgetTester tester) async {
      final FakeAuthRepository repo = await pumpAppAt(tester, AppRoutes.signIn);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(repo.signInCalls, 0);
    });

    testWidgets('muvaffaqiyatli kirish Account ekraniga olib boradi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.signIn,
        repository: FakeAuthRepository(signInResult: testUser),
      );

      await fillCredentials(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(repo.signInCalls, 1);
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.text(testUser.email), findsOneWidget);
    });

    testWidgets('noto\'g\'ri ma\'lumot xatosi ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.signIn,
        repository: FakeAuthRepository(
          signInResult: const ApiException(
            message: 'Incorrect email or password.',
            code: 'INVALID_CREDENTIALS',
            statusCode: 401,
          ),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('tarmoq xatosi tushunarli matn bilan ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(
        tester,
        AppRoutes.signIn,
        repository: FakeAuthRepository(
          signInResult: const ApiException(
            message: 'Cannot reach the server. Check your internet connection.',
          ),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Cannot reach the server. Check your internet connection.'),
        findsOneWidget,
      );
    });

    testWidgets('takroriy bosish ikkinchi so\'rov yubormaydi', (
      WidgetTester tester,
    ) async {
      final FakeAuthRepository repo = await pumpAppAt(
        tester,
        AppRoutes.signIn,
        repository: FakeAuthRepository(
          signInResult: testUser,
          delay: const Duration(milliseconds: 300),
        ),
      );

      await fillCredentials(tester);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.signInCalls, 1);
    });

    testWidgets('hisob yaratish havolasi ishlaydi', (
      WidgetTester tester,
    ) async {
      await pumpAppAt(tester, AppRoutes.signIn);

      final Finder link = find.text(SignInScreen.createAccountPrompt);
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });
  });
}
