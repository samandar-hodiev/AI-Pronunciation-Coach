import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/splash_loading_indicator.dart';
import '../../../shared/widgets/app_wordmark.dart';
import '../../../shared/widgets/brand_mark.dart';

/// Ilova ochilganda ko'rinadigan birinchi ekran.
///
/// Vazifasi ataylab tor: brendni ko'rsatish va keyingi manzilga o'tish.
/// Bu yerda hech qanday biznes mantiq bo'lmaydi — keyingi ekranni
/// [resolveRouteAfterSplash] hal qiladi.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Brend qancha vaqt ko'rinib turishi.
  ///
  /// Yetarlicha qisqa — foydalanuvchini kutdirmaydi, lekin ekran "chaqnab"
  /// o'tib ketmaydi.
  static const Duration displayDuration = Duration(milliseconds: 1600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, _goToNextScreen);
  }

  @override
  void dispose() {
    // Timer widget yo'q qilinganda bekor qilinadi, aks holda `context`
    // ishlatilganda xatolik va memory leak yuzaga keladi.
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _goToNextScreen() {
    if (!mounted) return;
    context.go(resolveRouteAfterSplash());
  }

  @override
  Widget build(BuildContext context) {
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
