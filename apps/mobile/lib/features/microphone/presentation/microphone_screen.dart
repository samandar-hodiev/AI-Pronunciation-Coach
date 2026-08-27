import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Microphone Permission ekrani uchun vaqtinchalik o'rin egallovchi.
///
/// TASK 07 doirasida bu ekran ataylab bo'sh va **hech qanday ruxsat
/// so'ramaydi**. Uning vazifasi faqat Assessment Introduction'dan keyingi
/// navigatsiya ishlayotganini ko'rsatish. Haqiqiy ruxsat oqimi keyingi taskda
/// yaratiladi.
class MicrophoneScreen extends StatelessWidget {
  const MicrophoneScreen({super.key});

  static const String placeholderLabel = 'Microphone Permission — next task';

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
