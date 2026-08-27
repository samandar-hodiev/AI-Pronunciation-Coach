import 'package:go_router/go_router.dart';

import '../../features/goal/presentation/goal_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import 'app_routes.dart';

/// Ilovaning navigatsiya konfiguratsiyasi.
///
/// Ilova doim [AppRoutes.splash] dan boshlanadi. Splash keyingi manzilni o'zi
/// hal qilmaydi — buni [resolveRouteAfterSplash] bajaradi, shunda kelajakda
/// sessiya holatini tekshirish uchun bitta aniq joy bo'ladi.
///
/// Hozircha to'rtta ekran ro'yxatdan o'tgan: `/splash`, `/welcome`,
/// `/onboarding` va `/goal`. Oxirgisi vaqtinchalik placeholder — u onboarding
/// tugagandan keyingi manzil bo'lib xizmat qiladi.
abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (_, _) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.goal,
          name: 'goal',
          builder: (_, _) => const GoalScreen(),
        ),
      ],
    );
  }
}

/// Splash tugagandan keyin qaysi ekranga o'tishni hal qiladi.
///
/// Hozircha doim [AppRoutes.welcome] qaytaradi, chunki TASK 02 da hali
/// autentifikatsiya ham, saqlanadigan foydalanuvchi holati ham yo'q.
///
/// Arxitektura darajasida bu funksiya ikki oqimni ajratadigan yagona nuqta:
///
/// * birinchi ochilish — `splash → welcome → onboarding → ... → home`
/// * qaytgan, tizimga kirgan foydalanuvchi — `splash → home`
///
/// Kelajakda bu yerga sessiya/token tekshiruvi qo'shiladi. Ataylab soxta
/// backend yoki soxta holat yaratilmadi.
String resolveRouteAfterSplash({bool hasAuthenticatedSession = false}) {
  return hasAuthenticatedSession ? AppRoutes.home : AppRoutes.welcome;
}
