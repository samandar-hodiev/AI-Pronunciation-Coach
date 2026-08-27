import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/goal_option.dart';

/// Bitta maqsad varianti — butun karta bosiladigan.
///
/// Tanlangan holat **faqat rang orqali** berilmaydi: chegara qalinlashadi va
/// o'ng tomonda belgi paydo bo'ladi. Shu sababli holat rangni ajrata olmaydigan
/// foydalanuvchi uchun ham ko'rinadi.
///
/// Palitraga yangi rang qo'shilmaydi — chegara va fon mavjud rollarning
/// shaffof variantlaridan olinadi.
class GoalOptionCard extends StatelessWidget {
  const GoalOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final GoalOption option;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  /// Holat o'zgarishi sezilarli, lekin diqqatni tortmaydigan bo'lishi uchun.
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color borderColor = isSelected
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.12);

    return Semantics(
      // Radio guruhidagi element: ekran o'quvchisi "selected" / "not selected"
      // holatini e'lon qiladi va faqat bittasi tanlanishini bildiradi.
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(option.id),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.06)
                  : Colors.transparent,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.6 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(option.icon, size: 24, color: colors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(option.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        option.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(
                  child: _SelectionIndicator(isSelected: isSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartaning o'ng tomonidagi tanlov belgisi.
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              key: const ValueKey<bool>(true),
              size: 22,
              color: colors.primary,
            )
          : Icon(
              Icons.circle_outlined,
              key: const ValueKey<bool>(false),
              size: 22,
              color: colors.onSurface.withValues(alpha: 0.25),
            ),
    );
  }
}
