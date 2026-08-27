import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_wordmark.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'widgets/splash_loading_indicator.dart';

/// Ilova ochilganda ko'rinadigan birinchi ekran.
///
/// Vazifasi ataylab tor: brendni ko'rsatish va keyingi manzilga o'tish.
/// Sessiya tekshiruvining o'zi bu yerda emas — u `AuthController` da, keyingi
/// manzil esa [resolveRouteAfterSplash] da hal qilinadi.
///
/// Ekran ikki shartni ham kutadi: brend eng kam vaqt ko'rinishi va sessiya
/// holati aniq bo'lishi. Shu sababli sekin tarmoqda ham ekran "chaqnab"
/// o'tib ketmaydi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Brend eng kamida qancha vaqt ko'rinib turishi.
  static const Duration displayDuration = Duration(milliseconds: 1600);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  /// Eng kam ko'rsatish vaqti tugadimi.
  bool _minimumTimeElapsed = false;

  /// Navigatsiya bir marta bajarilishini ta'minlaydi.
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, () {
      if (!mounted) return;
      setState(() => _minimumTimeElapsed = true);
      _navigateIfReady();
    });
  }

  @override
  void dispose() {
    // Timer widget yo'q qilinganda bekor qilinadi, aks holda `context`
    // ishlatilganda xatolik va memory leak yuzaga keladi.
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _navigateIfReady() {
    if (!mounted || _navigated || !_minimumTimeElapsed) return;

    final String? destination = resolveRouteAfterSplash(
      ref.read(authControllerProvider),
    );
    // Sessiya hali tekshirilmoqda — holat aniqlanganda qayta urinamiz.
    if (destination == null) return;

    _navigated = true;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    // Sessiya holati aniqlanishi bilan navigatsiyani qayta tekshiramiz.
    ref.listen<AuthState>(authControllerProvider, (_, _) {
      _navigateIfReady();
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Belgi ekran kengligiga moslashadi, lekin juda kichik yoki
                // juda katta bo'lib ketmasligi uchun cheklanadi.
                final double markSize = (constraints.maxWidth * 0.24).clamp(
                  64.0,
                  104.0,
                );

                return ConstrainedBox(
                  // Planshet va katta ekranlarda matn juda cho'zilib
                  // ketmasligi uchun.
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      BrandMark(size: markSize),
                      const SizedBox(height: AppSpacing.lg),
                      const AppWordmark(
                        tagline: 'Speak better. Pronounce better.',
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const SplashLoadingIndicator(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
