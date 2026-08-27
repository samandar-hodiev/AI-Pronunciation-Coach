import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Goal Selection ekrani uchun vaqtinchalik o'rin egallovchi.
///
/// TASK 04 doirasida bu ekran ataylab bo'sh: uning vazifasi faqat onboarding
/// tugagandan keyingi navigatsiya ishlayotganini ko'rsatish. To'liq UI
/// keyingi taskda yaratiladi.
class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  static const String placeholderLabel = 'Goal Selection — next task';

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
