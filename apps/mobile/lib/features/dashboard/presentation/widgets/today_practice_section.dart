import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/dashboard_data.dart';

/// Bugungi mashq bo'limi va asosiy harakat tugmasi.
///
/// Mashq vaqti o'lchovi hali yo'q, shuning uchun bu yerda progress bar
/// ko'rsatilmaydi — u o'lchov mavjud degan noto'g'ri taassurot berardi.
class TodayPracticeSection extends StatelessWidget {
  const TodayPracticeSection({
    super.key,
    required this.goalMinutes,
    required this.today,
  });

  final int? goalMinutes;
  final TodayPractice today;

  static const String title = 'Today\'s practice';
  static const String readyLabel = 'Ready for today\'s practice';
  static const String noGoalLabel = 'No daily goal set yet';

  /// Ekranda ko'rinadigan asosiy qiymat.
  String get goalText {
    final int? minutes = goalMinutes;
    if (minutes == null) return noGoalLabel;
    return '$minutes min';
  }

  /// Holatni tavsiflovchi matn.
  String get statusText {
    if (!today.trackingAvailable) return readyLabel;
    final int completed = today.completedMinutes ?? 0;
    final int? goal = goalMinutes;
    return goal == null ? '$completed min done' : '$completed / $goal min';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      label: 'Today\'s practice. $goalText. $statusText.',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              goalText,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(statusText, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
