import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Ekran ostidagi yordamchi ma'lumot qatori: kichik ikonka va matn.
///
/// Davomiylik va mikrofon izohi uchun ishlatiladi. Ikkalasi ham asosiy
/// kontentdan pastroq ierarxiyada turadi.
class AssessmentInfoRow extends StatelessWidget {
  const AssessmentInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.semanticLabel,
  });

  final IconData icon;
  final String text;

  /// Ekran o'quvchisi uchun to'liq jumla — ikonka ma'nosini matn bilan
  /// birlashtiradi.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
