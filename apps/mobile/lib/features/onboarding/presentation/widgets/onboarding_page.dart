import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/onboarding_item.dart';
import 'onboarding_visual.dart';

/// Bitta onboarding sahifasi.
///
/// Uchala sahifa ham aynan shu tuzilmadan foydalanadi — vizual, sarlavha,
/// izoh. Faqat mazmun o'zgaradi, layout emas.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Past ekranlarda vizual kichrayadi, shunda matn uchun joy qoladi.
        final double visualSize = (constraints.maxHeight * 0.22).clamp(
          72.0,
          112.0,
        );

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OnboardingVisual(icon: item.icon, size: visualSize),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  item.title,
                  style: text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  // Izoh qatorlari haddan tashqari cho'zilmasligi uchun.
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(
                    item.description,
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
