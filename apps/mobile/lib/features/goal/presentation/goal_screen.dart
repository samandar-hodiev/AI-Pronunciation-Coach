import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/goal_option.dart';
import '../domain/goal_options.dart';
import 'widgets/goal_option_card.dart';

/// Foydalanuvchining asosiy talaffuz maqsadini so'raydi.
///
/// Onboarding'dan keyingi birinchi personalizatsiya bosqichi. Faqat bitta
/// maqsad tanlanadi va tanlov qilinmaguncha davom etib bo'lmaydi.
///
/// Tanlov hozircha faqat ekran holatida saqlanadi — backend ham,
/// saqlanadigan profil ham hali yo'q.
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  static const String title = 'What is your main pronunciation goal?';

  static const String description =
      'Choose the goal that matters most to you. You can change it later.';

  static const String ctaLabel = 'Continue';

  /// Personalizatsiya savollari soni: maqsad va ingliz tili darajasi.
  ///
  /// Bu raqam o'ylab topilgan emas — mahsulot oqimida aynan shu ikki savol
  /// bor. Uchinchi savol qo'shilsa, shu yerni yangilash kerak.
  static const int personalizationStepCount = 2;
  static const int stepIndex = 1;

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  /// Tanlangan maqsadning barqaror identifikatori. `null` — hali tanlanmagan.
  String? _selectedGoalId;

  bool get _hasSelection => _selectedGoalId != null;

  void _onGoalSelected(String id) {
    // Bitta tanlov: yangi qiymat oldingisini almashtiradi, shuning uchun
    // alohida "deselect" mantiqi kerak emas.
    setState(() => _selectedGoalId = id);
  }

  void _onContinue() {
    if (!_hasSelection) return;
    context.go(AppRoutes.level);
  }

  void _onBack() => context.go(AppRoutes.onboarding);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _GoalHeader(onBack: _onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  // Katta ekranlarda matn va kartalar cho'zilib ketmasligi
                  // uchun.
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(GoalScreen.title, style: text.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(GoalScreen.description, style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      for (final GoalOption option in GoalOptions.all) ...[
                        GoalOptionCard(
                          option: option,
                          isSelected: _selectedGoalId == option.id,
                          onSelected: _onGoalSelected,
                        ),
                        if (option != GoalOptions.all.last)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                label: GoalScreen.ctaLabel,
                // `null` tugmani o'chirilgan holatga o'tkazadi — maqsad
                // tanlanmaguncha davom etib bo'lmaydi.
                onPressed: _hasSelection ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yuqori qator: orqaga qaytish va bosqich konteksti.
class _GoalHeader extends StatelessWidget {
  const _GoalHeader({required this.onBack});

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
              'Step ${GoalScreen.stepIndex} of '
              '${GoalScreen.personalizationStepCount}',
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
