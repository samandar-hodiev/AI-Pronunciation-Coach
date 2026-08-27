import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Onboarding ekrani uchun vaqtinchalik o'rin egallovchi.
///
/// TASK 03 doirasida bu ekran ataylab bo'sh: uning vazifasi faqat Welcome
/// CTA'sidan keyingi navigatsiya ishlayotganini ko'rsatish. To'liq UI keyingi
/// taskda yaratiladi.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String placeholderLabel = 'Onboarding — next task';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              placeholderLabel,
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
