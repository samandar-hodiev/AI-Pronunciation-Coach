import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Onboarding sahifalari indikatori.
///
/// Faqat bezak emas — joriy sahifa holatini bildiradi. Nuqtalarning o'zi
/// dekorativ, shuning uchun butun qator bitta semantik yorliq bilan
/// almashtiriladi ("Page 2 of 3"). Aks holda ekran o'quvchisi ma'nosiz
/// elementlarni birma-bir o'qib chiqadi.
///
/// Holat faqat rang orqali berilmaydi: faol nuqta kengroq ham bo'ladi.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  final int currentIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${currentIndex + 1} of $pageCount',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < pageCount; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: i == currentIndex ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == currentIndex
                    ? colors.onPrimaryContainer
                    : colors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
