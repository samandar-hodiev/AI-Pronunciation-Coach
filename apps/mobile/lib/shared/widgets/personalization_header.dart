import 'package:flutter/material.dart';

import '../../core/constants/personalization_steps.dart';
import '../../core/theme/app_spacing.dart';

/// Personalizatsiya ekranlarining yuqori qatori: orqaga qaytish va bosqich
/// konteksti ("Step 1 of 2").
///
/// Maqsad va daraja ekranlari bir xil sarlavha qatoridan foydalanadi, shuning
/// uchun u `shared/widgets/` ichida saqlanadi.
class PersonalizationHeader extends StatelessWidget {
  const PersonalizationHeader({
    super.key,
    required this.stepIndex,
    required this.onBack,
  });

  /// Joriy bosqich raqami (1 dan boshlanadi).
  final int stepIndex;

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(
              'Step $stepIndex of ${PersonalizationSteps.total}',
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
