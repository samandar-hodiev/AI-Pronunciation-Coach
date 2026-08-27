import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Bitta tanlanadigan variant — butun karta bosiladigan.
///
/// Personalizatsiya ekranlari (maqsad, daraja) bir xil tanlov naqshidan
/// foydalanadi, shuning uchun karta `shared/widgets/` ichida saqlanadi va
/// har bir ekranda qaytadan yozilmaydi.
///
/// Tanlangan holat **faqat rang orqali** berilmaydi: chegara qalinlashadi va
/// o'ng tomonda belgi paydo bo'ladi. Shu sababli holat rangni ajrata olmaydigan
/// foydalanuvchi uchun ham ko'rinadi.
///
/// Palitraga yangi rang qo'shilmaydi — chegara va fon mavjud rollarning
/// shaffof variantlaridan olinadi.
class SelectableOptionCard extends StatelessWidget {
  const SelectableOptionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  /// Kartaning chap tomonidagi vizual. Dekorativ deb hisoblanadi va semantik
  /// daraxtdan chiqariladi — ma'noni [title] beradi.
  final Widget leading;

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  /// Holat o'zgarishi sezilarli, lekin diqqatni tortmaydigan bo'lishi uchun.
  static const Duration animationDuration = Duration(milliseconds: 200);

  static const double _borderRadius = 14;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      // Radio guruhidagi element: ekran o'quvchisi "selected" / "not selected"
      // holatini e'lon qiladi va faqat bittasi tanlanishini bildiradi.
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.06)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.12),
                width: isSelected ? 1.6 : 1,
              ),
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(child: leading),
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
      duration: SelectableOptionCard.animationDuration,
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
