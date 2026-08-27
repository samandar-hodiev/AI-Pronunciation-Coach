import 'package:flutter/material.dart';

import 'onboarding_item.dart';

/// Onboarding sahifalarining tartibi va mazmuni.
///
/// Ikonkalar Welcome ekranidagi value proposition ikonkalari bilan bir xil —
/// mahsulot bo'ylab yagona vizual til saqlanadi.
abstract final class OnboardingContent {
  static const List<OnboardingItem> items = <OnboardingItem>[
    OnboardingItem(
      title: 'Speak',
      description: 'Practice English sounds by speaking naturally.',
      icon: Icons.mic_none_rounded,
    ),
    OnboardingItem(
      title: 'Understand',
      description: 'See which sounds and words need improvement.',
      icon: Icons.graphic_eq_rounded,
    ),
    OnboardingItem(
      title: 'Improve',
      description: 'Practice focused sounds and track your progress.',
      icon: Icons.trending_up_rounded,
    ),
  ];

  static int get pageCount => items.length;
}
