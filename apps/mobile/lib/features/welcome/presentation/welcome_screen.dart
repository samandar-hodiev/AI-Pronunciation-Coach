import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Welcome / Value Proposition ekrani uchun vaqtinchalik o'rin egallovchi.
///
/// TASK 02 doirasida bu ekran ataylab bo'sh: uning vazifasi faqat splash'dan
/// keyingi navigatsiya ishlayotganini ko'rsatish. To'liq UI keyingi taskda
/// yaratiladi.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Ekranning vaqtinchalik ekanini bildiruvchi matn.
  static const String placeholderLabel =
      'Welcome / Value Proposition — next task';

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
