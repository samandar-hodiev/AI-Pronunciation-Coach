import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/assessment_intro_screen.dart';
import '../../features/goal/presentation/goal_screen.dart';
import '../../features/level/presentation/level_screen.dart';
import '../../features/microphone/presentation/microphone_screen.dart';
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
/// Hozircha yettita ekran ro'yxatdan o'tgan: `/splash`, `/welcome`,
/// `/onboarding`, `/goal`, `/level`, `/assessment-intro` va `/microphone`.
/// Oxirgisi vaqtinchalik placeholder — u Assessment Introduction tugagandan
/// keyingi manzil bo'lib xizmat qiladi va hech qanday ruxsat so'ramaydi.
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
        GoRoute(
          path: AppRoutes.level,
          name: 'level',
          builder: (_, _) => const LevelScreen(),
        ),
        GoRoute(
          path: AppRoutes.assessmentIntro,
          name: 'assessment-intro',
          builder: (_, _) => const AssessmentIntroScreen(),
        ),
        GoRoute(
          path: AppRoutes.microphone,
          name: 'microphone',
          builder: (_, _) => const MicrophoneScreen(),
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
