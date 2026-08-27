import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Mahsulot qiymatini tushuntiruvchi bitta qator: ikonka, sarlavha va izoh.
///
/// Elementlar bir-biridan **rang bilan farqlanmaydi** — vizual ierarxiya faqat
/// bo'shliq va tipografiya orqali quriladi. Ikonka foni asosiy rangning shaffof
/// varianti, ya'ni palitraga yangi rang qo'shilmaydi.
///
/// Welcome'dan tashqari keyingi onboarding ekranlarida ham ishlatish uchun
/// `shared/widgets/` ichida joylashgan.
class ValuePropositionItem extends StatelessWidget {
  const ValuePropositionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Qatorning chap tomonidagi ikonka. Dekorativ — semantik ma'no bermaydi,
  /// chunki uning ma'nosini [title] allaqachon beradi.
  final IconData icon;

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: colors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
