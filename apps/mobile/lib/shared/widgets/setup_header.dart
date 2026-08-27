import 'package:flutter/material.dart';

import '../../core/constants/personalization_steps.dart';
import '../../core/theme/app_spacing.dart';

/// Setup oqimidagi ekranlarning yuqori qatori.
///
/// Chapda doim orqaga qaytish tugmasi. O'ngda — agar ekran personalizatsiya
/// savoli bo'lsa — bosqich konteksti ("Step 1 of 2").
///
/// [stepIndex] `null` bo'lsa bosqich matni ko'rsatilmaydi. Bu ataylab:
/// Assessment Introduction personalizatsiya savoli emas, shuning uchun unda
/// "Step 3 of 2" kabi noto'g'ri ma'lumot chiqmasligi kerak.
class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key, required this.onBack, this.stepIndex});

  /// `null` bo'lsa tugma o'chiriladi — masalan, forma yuborilayotgan paytda
  /// foydalanuvchi orqaga qaytib jarayonni yarim qoldirmasligi uchun.
  final VoidCallback? onBack;

  /// Joriy personalizatsiya bosqichi (1 dan boshlanadi), yoki `null`.
  final int? stepIndex;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int? stepIndex = this.stepIndex;

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
          if (stepIndex != null)
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
