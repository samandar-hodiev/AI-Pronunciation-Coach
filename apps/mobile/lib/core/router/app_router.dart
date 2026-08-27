import 'package:go_router/go_router.dart';

import '../../features/account/presentation/account_screen.dart';
import '../../features/assessment/presentation/assessment_intro_screen.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
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
/// hal qilmaydi — buni [resolveRouteAfterSplash] bajaradi, shunda sessiya
/// holatini tekshirish bitta aniq joyda saqlanadi.
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
          path: AppRoutes.createAccount,
          name: 'create-account',
          builder: (_, _) => const CreateAccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          name: 'sign-in',
          builder: (_, _) => const SignInScreen(),
        ),
        GoRoute(
          path: AppRoutes.account,
          name: 'account',
          builder: (_, _) => const AccountScreen(),
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
/// Ikki oqim shu yerda ajraladi:
///
/// * tizimga kirgan foydalanuvchi — `splash → account`
/// * kirmagan foydalanuvchi — `splash → welcome → onboarding → auth`
///
/// [AuthLoading] holatida `null` qaytariladi: sessiya hali tekshirilmoqda va
/// bu paytda foydalanuvchini na kirgan, na chiqqan deb hisoblash mumkin.
/// Splash bunday holatda kutib turadi.
String? resolveRouteAfterSplash(AuthState state) {
  return switch (state) {
    AuthLoading() => null,
    Authenticated() => AppRoutes.account,
    Unauthenticated() => AppRoutes.welcome,
  };
}
