import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/setup_header.dart';
import '../domain/assessment_content.dart';
import '../domain/assessment_step.dart';
import 'widgets/assessment_info_row.dart';
import 'widgets/assessment_step_item.dart';
import 'widgets/assessment_visual.dart';

/// Foydalanuvchini birinchi talaffuz baholashiga tayyorlaydi.
///
/// Ekran faqat **tushuntiradi**: baholash qanday o'tishini, qancha vaqt
/// olishini va mikrofon nima uchun kerakligini. Mikrofon ruxsati bu yerda
/// so'ralmaydi va hech qanday audio yozilmaydi — bu keyingi taskning ishi.
///
/// Ekran holatsiz: dinamik ma'lumot ham, taymer ham yo'q.
class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  static const String title = 'Let\'s check your pronunciation';

  static const String description =
      'We\'ll listen to you speak a few short phrases and identify the '
      'sounds you can improve.';

  static const String ctaLabel = 'Start assessment';

  void _onStart(BuildContext context) {
    // Faqat navigatsiya. Baholash ham, ruxsat so'rovi ham bu yerda
    // boshlanmaydi.
    context.go(AppRoutes.microphone);
  }

  void _onBack(BuildContext context) => context.go(AppRoutes.level);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SetupHeader(onBack: () => _onBack(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      const AssessmentVisual(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(title, style: text.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(description, style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      for (final AssessmentStep step
                          in AssessmentContent.steps) ...<Widget>[
                        AssessmentStepItem(step: step),
                        if (step != AssessmentContent.steps.last)
                          const SizedBox(height: AppSpacing.lg),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AssessmentInfoRow(
                        icon: Icons.schedule_rounded,
                        text: AssessmentContent.estimatedDuration,
                        semanticLabel:
                            'Estimated duration, '
                            '${AssessmentContent.estimatedDuration}.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AssessmentInfoRow(
                        icon: Icons.mic_none_rounded,
                        text: AssessmentContent.microphoneExplanation,
                        semanticLabel: AssessmentContent.microphoneExplanation,
                      ),
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
                label: ctaLabel,
                onPressed: () => _onStart(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
