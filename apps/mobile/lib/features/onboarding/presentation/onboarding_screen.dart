import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/onboarding_content.dart';
import '../domain/onboarding_item.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_page_indicator.dart';

/// Ilova qanday ishlashini uchta qisqa sahifada tushuntiradi.
///
/// Sahifalar gorizontal `PageView` orqali almashadi: foydalanuvchi ham
/// surish (swipe), ham tugma orqali harakatlanishi mumkin. Ikkala usul ham
/// bir xil holatni yangilaydi, chunki [PageView.onPageChanged] yagona manba.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String skipLabel = 'Skip';
  static const String nextLabel = 'Next';
  static const String finishLabel = 'Get started';

  /// Sahifa almashish animatsiyasi. Qisqa va oldindan aytib bo'ladigan.
  static const Duration transitionDuration = Duration(milliseconds: 280);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == OnboardingContent.pageCount - 1;
  bool get _isFirstPage => _currentIndex == 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: OnboardingScreen.transitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPrimaryPressed() {
    if (_isLastPage) {
      _completeOnboarding();
      return;
    }
    _goToPage(_currentIndex + 1);
  }

  void _onBackPressed() => _goToPage(_currentIndex - 1);

  /// Onboarding tugagach chaqiriladi.
  ///
  /// Skip ham, oxirgi sahifadagi CTA ham aynan shu metodni ishlatadi —
  /// tugash manzili bitta joyda saqlanadi va navigatsiya mantiqi
  /// takrorlanmaydi.
  ///
  /// Keyingi qadam — personalizatsiya (maqsad, keyin daraja).
  ///
  /// Hisob yaratish ataylab keyinroq: foydalanuvchi avval ilova nima
  /// taklif qilishini ko'radi, ro'yxatdan o'tish esa qiymat ko'rsatilgandan
  /// keyin so'raladi. Tanlovlar shu paytgacha lokal draft'da turadi.
  void _completeOnboarding() {
    context.go(AppRoutes.goal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _OnboardingHeader(
              showBack: !_isFirstPage,
              onBack: _onBackPressed,
              onSkip: _completeOnboarding,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingContent.pageCount,
                itemBuilder: (BuildContext context, int index) {
                  final OnboardingItem item = OnboardingContent.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: OnboardingPage(item: item),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: <Widget>[
                  OnboardingPageIndicator(
                    currentIndex: _currentIndex,
                    pageCount: OnboardingContent.pageCount,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isLastPage
                        ? OnboardingScreen.finishLabel
                        : OnboardingScreen.nextLabel,
                    onPressed: _onPrimaryPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ekranning yuqori qatori: orqaga qaytish va o'tkazib yuborish.
///
/// Birinchi sahifada orqaga tugmasi ko'rinmaydi, lekin egallagan joyi
/// saqlanadi — aks holda sahifa almashganda "Skip" chapga sakrab ketardi.
class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.showBack,
    required this.onBack,
    required this.onSkip,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Visibility(
            visible: showBack,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Go back',
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            child: const Text(OnboardingScreen.skipLabel),
          ),
        ],
      ),
    );
  }
}
