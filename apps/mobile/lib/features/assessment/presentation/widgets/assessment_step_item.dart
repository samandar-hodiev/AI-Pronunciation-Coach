import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/assessment_step.dart';

/// Baholash bosqichining bitta qatori: tartib raqami, sarlavha va izoh.
///
/// Chapdagi belgi sifatida ikonka emas, **tartib raqami** ishlatiladi.
/// Bosqichlar ketma-ket bajariladi va raqam aynan shu ketma-ketlikni
/// bildiradi — ikonka buni ko'rsata olmaydi.
///
/// Bosqichlar bosiladigan emas, shuning uchun tugma sifatida yozilmaydi.
class AssessmentStepItem extends StatelessWidget {
  const AssessmentStepItem({super.key, required this.step});

  final AssessmentStep step;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      // Ekran o'quvchisi uchun bitta tushunarli jumla. Aks holda raqam,
      // sarlavha va izoh uzuq-yuluq o'qiladi.
      label: 'Step ${step.order}, ${step.title}. ${step.description}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${step.order}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(step.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(step.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
