import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Practice ekrani uchun vaqtinchalik o'rin egallovchi.
///
/// TASK 10 doirasida bu ekran ataylab bo'sh: uning vazifasi faqat bosh
/// ekrandagi "Start Practice" navigatsiyasi ishlayotganini ko'rsatish.
/// Mashq, mikrofon va audio yozish keyingi taskda yaratiladi.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  static const String placeholderLabel = 'Practice — next task';

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
