import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'shared/widgets/app_wordmark.dart';

/// Ilovaning ildiz widgeti.
///
/// Mavzu va navigatsiyani ulaydi. Biznes mantiq bu yerda saqlanmaydi.
class AiPronunciationCoachApp extends ConsumerStatefulWidget {
  const AiPronunciationCoachApp({super.key, this.router});

  /// Testlarda o'z router'ini berish uchun. `null` bo'lsa standart
  /// konfiguratsiya yaratiladi.
  final GoRouter? router;

  @override
  ConsumerState<AiPronunciationCoachApp> createState() =>
      _AiPronunciationCoachAppState();
}

class _AiPronunciationCoachAppState
    extends ConsumerState<AiPronunciationCoachApp> {
  late final GoRouter _router = widget.router ?? AppRouter.create();

  @override
  Widget build(BuildContext context) {
    // Sessiya yaroqsiz bo'lib qolganda foydalanuvchini himoyalangan
    // ekranlarda qoldirib bo'lmaydi.
    //
    // Bu ilova darajasida bajariladi, ekranlar ichida emas: aks holda har bir
    // himoyalangan ekran o'zicha kirish oqimini ochishi kerak bo'lardi va
    // mantiq takrorlanardi.
    ref.listen<AuthState>(authControllerProvider, (
      AuthState? previous,
      AuthState next,
    ) {
      if (next is! Unauthenticated) return;
      if (previous is! Authenticated) return;

      final String location = _router.state.uri.path;
      if (!AppRoutes.isProtected(location)) return;

      _router.go(AppRoutes.signIn);
    });

    return MaterialApp.router(
      title: AppWordmark.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
