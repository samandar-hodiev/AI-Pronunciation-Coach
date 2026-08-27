import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/personalization_steps.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/setup_header.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/selectable_option_card.dart';
import '../domain/goal_option.dart';
import '../domain/goal_options.dart';

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

  void _onBack() => context.go(AppRoutes.account);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SetupHeader(stepIndex: PersonalizationSteps.goal, onBack: _onBack),
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
                        SelectableOptionCard(
                          leading: Icon(
                            option.icon,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: option.title,
                          description: option.description,
                          isSelected: _selectedGoalId == option.id,
                          onTap: () => _onGoalSelected(option.id),
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
