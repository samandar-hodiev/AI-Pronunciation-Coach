import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'greeting.dart';

/// Bosh ekranning yuqori qatori: salomlashish va profil tugmasi.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.onProfilePressed,
    this.now,
  });

  final String userName;
  final VoidCallback onProfilePressed;

  /// Testlarda vaqtni belgilash uchun. `null` bo'lsa hozirgi vaqt.
  final DateTime? now;

  static const String supportingText = 'Ready to work on your pronunciation?';

  /// Profil tugmasining kaliti — testlar uni shu orqali topadi.
  static const Key profileButtonKey = ValueKey<String>('dashboard.profile');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String greeting = greetingFor(now ?? DateTime.now(), userName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(greeting, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(supportingText, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _ProfileButton(
          key: DashboardHeader.profileButtonKey,
          initials: initialsFor(userName),
          onPressed: onProfilePressed,
        ),
      ],
    );
  }
}

/// Bosh harflardan iborat avatar tugmasi.
///
/// Tashqi rasm yuklanmaydi — foydalanuvchi rasmi hali saqlanmaydi.
class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    super.key,
    required this.initials,
    required this.onPressed,
  });

  final String initials;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Account',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: ExcludeSemantics(
            child: Text(
              initials,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
