import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Sarlavha va matndan iborat oddiy bo'lim.
///
/// Ma'lumot hali yo'q bo'lgan bo'limlar uchun ishlatiladi. Ataylab karta
/// emas — bo'sh kartalar ekranni ortiqcha shovqin bilan to'ldiradi.
class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      label: '$title. $message',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
