import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Pronunciation Assessment Introduction ekrani uchun vaqtinchalik
/// o'rin egallovchi.
///
/// TASK 06 doirasida bu ekran ataylab bo'sh: uning vazifasi faqat English
/// Level'dan keyingi navigatsiya ishlayotganini ko'rsatish. To'liq UI keyingi
/// taskda yaratiladi.
class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  static const String placeholderLabel = 'Pronunciation Assessment — next task';

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
