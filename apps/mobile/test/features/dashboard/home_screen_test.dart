import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/account/presentation/account_screen.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/sign_in_screen.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/home_screen.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/widgets/home_bottom_navigation.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/widgets/today_practice_section.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/practice_screen.dart';
import 'package:ai_pronunciation_coach/features/welcome/presentation/welcome_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Tizimga kirgan foydalanuvchi bilan bosh ekranni ochadi.
Future<FakeDashboardRepository> pumpHome(
  WidgetTester tester, {
  FakeDashboardRepository? dashboardRepository,
  bool settle = true,
}) async {
  final FakeDashboardRepository repo =
      dashboardRepository ?? FakeDashboardRepository();

  await pumpAppAt(
    tester,
    AppRoutes.home,
    repository: FakeAuthRepository(existingUser: testUser),
    dashboardRepository: repo,
    settle: settle,
  );

  return repo;
}

void main() {
  group('HomeScreen', () {
    testWidgets('ekran ochiladi va salomlashish ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      // Salomlashish kun vaqtiga bog'liq, shuning uchun ism bo'yicha
      // tekshiramiz.
      expect(find.textContaining('Samandar'), findsWidgets);
    });

    testWidgets('haqiqiy ism backenddan keladi', (WidgetTester tester) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          data: testDashboard(name: 'Dilnoza'),
        ),
      );

      expect(find.textContaining('Dilnoza'), findsWidgets);
      // Boshqa foydalanuvchining ismi ko'rinmasligi kerak.
      expect(find.textContaining('Samandar'), findsNothing);
    });

    testWidgets('ism bo\'lmasa umumiy salomlashish ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          data: testDashboard(name: ''),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('bugungi mashq bo\'limi va kunlik maqsad ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          data: testDashboard(goalMinutes: 15),
        ),
      );

      expect(find.byType(TodayPracticeSection), findsOneWidget);
      expect(find.text(TodayPracticeSection.title), findsOneWidget);
      // Qiymat haqiqiy profildan keladi, qattiq yozilmagan.
      expect(find.text('15 min'), findsOneWidget);
    });

    testWidgets('mashq o\'lchovi yo\'qligi halol ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      // Soxta "0 / 10 min" emas — o'lchov hali mavjud emas.
      expect(find.text(TodayPracticeSection.readyLabel), findsOneWidget);
      expect(find.textContaining('/'), findsNothing);
    });

    testWidgets('kunlik maqsad qo\'yilmagan bo\'lsa halol matn ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          data: testDashboard(goalMinutes: null),
        ),
      );

      expect(find.text(TodayPracticeSection.noGoalLabel), findsOneWidget);
    });

    testWidgets('Start Practice tugmasi ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.text(HomeScreen.startPracticeLabel), findsOneWidget);
    });

    testWidgets('progress va tarix bo\'sh holatda ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.text(HomeScreen.progressTitle), findsOneWidget);
      expect(find.text(HomeScreen.progressEmpty), findsOneWidget);
      expect(find.text(HomeScreen.recentTitle), findsOneWidget);
      expect(find.text(HomeScreen.recentEmpty), findsOneWidget);
    });

    testWidgets('soxta statistika ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      // Ball, foiz yoki streak kabi qiymatlar hali mavjud emas.
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);
      expect(find.textContaining('score'), findsNothing);
    });

    testWidgets('pastki navigatsiya ko\'rinadi', (WidgetTester tester) async {
      await pumpHome(tester);

      expect(find.byType(HomeBottomNavigation), findsOneWidget);
      for (final dest in HomeBottomNavigation.destinations) {
        expect(find.text(dest.label), findsOneWidget);
      }
    });
  });

  group('Holatlar', () {
    testWidgets('yuklanish paytida indikator ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          delay: const Duration(milliseconds: 300),
        ),
        settle: false,
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(TodayPracticeSection), findsOneWidget);
    });

    testWidgets('xato holati va sabab ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          error: const ApiException(
            message: 'Cannot reach the server. Check your internet connection.',
          ),
        ),
      );

      expect(find.text(HomeScreen.errorTitle), findsOneWidget);
      expect(
        find.text('Cannot reach the server. Check your internet connection.'),
        findsOneWidget,
      );
      expect(find.text(HomeScreen.retryLabel), findsOneWidget);
    });

    testWidgets('kutilmagan xatoda stack trace ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpHome(
        tester,
        dashboardRepository: FakeDashboardRepository(
          error: StateError('internal failure'),
        ),
      );

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('StateError'), findsNothing);
    });

    testWidgets('401 xatosi foydalanuvchini sessiyadan chiqaradi', (
      WidgetTester tester,
    ) async {
      // Bosh ekran o'zicha kirish ekranini ochmaydi — auth qatlami hal
      // qiladi va foydalanuvchi kirmagan holatga o'tadi.
      final FakeAuthRepository authRepo = FakeAuthRepository(
        existingUser: testUser,
      );

      await pumpAppAt(
        tester,
        AppRoutes.home,
        repository: authRepo,
        dashboardRepository: FakeDashboardRepository(
          error: const ApiException(
            message: 'Your session has expired.',
            statusCode: 401,
          ),
        ),
      );

      expect(authRepo.signOutCalls, 1);
      // Foydalanuvchi himoyalangan ekranda spinner bilan qolib ketmasligi
      // kerak — ilova uni kirish oqimiga qaytaradi.
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });

  group('Navigatsiya', () {
    testWidgets('Start Practice mashq ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.text(HomeScreen.startPracticeLabel));
      await tester.pumpAndSettle();

      expect(find.byType(PracticeScreen), findsOneWidget);
    });

    testWidgets('profil tugmasi Account ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.byKey(DashboardHeader.profileButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(AccountScreen), findsOneWidget);
    });

    testWidgets('chiqilganda Welcome ekraniga qaytadi', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.byKey(DashboardHeader.profileButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AccountScreen.signOutLabel));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });

  group('Layout', () {
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

          await pumpHome(tester);

          expect(find.byType(HomeScreen), findsOneWidget);
          // Pastki navigatsiya har qanday balandlikda ko'rinishi kerak.
          expect(find.byType(HomeBottomNavigation), findsOneWidget);
          expect(find.byType(PrimaryButton), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
