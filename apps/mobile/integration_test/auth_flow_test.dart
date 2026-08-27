import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/create_account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/sign_in_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Haqiqiy qurilmada (iPhone simulyatorida) to'liq autentifikatsiya oqimi.
///
/// Bu testlar **mock ishlatmaydi**: ular haqiqiy `AuthRepositoryImpl`,
/// haqiqiy `flutter_secure_storage` (iOS Keychain) va ishlab turgan Go
/// backend orqali o'tadi. Shu sababli ular qurilmadagi tarmoq sozlamalarini
/// (ATS) va Keychain'ga yozishni ham tekshiradi — bu narsalarni oddiy widget
/// testi tekshira olmaydi.
///
/// Ishlatish:
/// ```
/// flutter test integration_test/auth_flow_test.dart -d <device-id>
/// ```
/// Backend `http://localhost:8081` da ishlab turishi shart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Har bir ishga tushirishda noyob email — test qayta-qayta ishlashi kerak.
  String uniqueEmail() =>
      'device-${DateTime.now().microsecondsSinceEpoch}@example.com';

  int pumpCount = 0;

  Future<void> pumpAt(WidgetTester tester, String location) async {
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: AppRouter.create().configuration.routes,
    );
    addTearDown(router.dispose);

    // Har bir pump uchun noyob kalit.
    //
    // Kalitsiz Flutter bir xil turdagi widget uchun mavjud `State` ni qayta
    // ishlatadi va ilova eski router'da qolib ketadi — natijada yangi
    // boshlang'ich manzil e'tiborga olinmaydi.
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

  testWidgets('haqiqiy backend bilan ro\'yxatdan o\'tish va sessiya', (
    WidgetTester tester,
  ) async {
    final String email = uniqueEmail();

    await pumpAt(tester, AppRoutes.createAccount);
    expect(find.byType(CreateAccountScreen), findsOneWidget);

    await enterField(tester, 'Name', 'Device Test');
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await enterField(tester, 'Confirm password', 'password123');

    await tester.tap(find.byType(PrimaryButton));
    // Haqiqiy tarmoq so'rovi — javob kelishini kutamiz.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Backend foydalanuvchini yaratdi va ilova Account ekraniga o'tdi.
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text('Device Test'), findsOneWidget);
    expect(find.text(email), findsOneWidget);
  });

  testWidgets('ro\'yxatdan o\'tgan foydalanuvchi tizimga kira oladi', (
    WidgetTester tester,
  ) async {
    final String email = uniqueEmail();

    // Avval hisob yaratamiz.
    await pumpAt(tester, AppRoutes.createAccount);
    await enterField(tester, 'Name', 'Sign In Test');
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await enterField(tester, 'Confirm password', 'password123');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.byType(AccountScreen), findsOneWidget);

    // Chiqamiz, keyin o'sha ma'lumot bilan qayta kiramiz.
    await tester.tap(find.text(AccountScreen.signOutLabel));
    await tester.pumpAndSettle();

    await pumpAt(tester, AppRoutes.signIn);
    expect(find.byType(SignInScreen), findsOneWidget);

    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text(email), findsOneWidget);
  });

  testWidgets('noto\'g\'ri parol backenddan kelgan xatoni ko\'rsatadi', (
    WidgetTester tester,
  ) async {
    final String email = uniqueEmail();

    await pumpAt(tester, AppRoutes.createAccount);
    await enterField(tester, 'Name', 'Wrong Password Test');
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'password123');
    await enterField(tester, 'Confirm password', 'password123');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    await tester.tap(find.text(AccountScreen.signOutLabel));
    await tester.pumpAndSettle();

    await pumpAt(tester, AppRoutes.signIn);
    await enterField(tester, 'Email', email);
    await enterField(tester, 'Password', 'definitely-wrong');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Backend bergan aniq xato matni ko'rsatiladi va ekran o'zgarmaydi.
    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
