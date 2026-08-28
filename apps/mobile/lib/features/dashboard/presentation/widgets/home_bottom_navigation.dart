import 'package:flutter/material.dart';

/// Bosh ekranning pastki navigatsiyasi.
///
/// Hozircha faqat Home haqiqiy ekran. Qolgan uchtasi **o'chirilgan** holatda
/// ko'rsatiladi: ular ilovaning kelajakdagi tuzilishini bildiradi, lekin
/// bosilmaydi. Soxta ekran yaratishdan ko'ra o'chirilgan tab halolroq.
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  static const List<({IconData icon, String label})> destinations =
      <({IconData icon, String label})>[
        (icon: Icons.home_rounded, label: 'Home'),
        (icon: Icons.mic_none_rounded, label: 'Practice'),
        (icon: Icons.trending_up_rounded, label: 'Progress'),
        (icon: Icons.person_outline_rounded, label: 'Profile'),
      ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.onSurface.withValues(alpha: 0.10)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavigationItem(
                    icon: destinations[i].icon,
                    label: destinations[i].label,
                    // Faqat birinchi manzil mavjud.
                    isActive: i == 0,
                    isEnabled: i == 0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isEnabled,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color color = switch ((isActive, isEnabled)) {
      (true, _) => colors.primary,
      (_, false) => colors.onSurface.withValues(alpha: 0.30),
      _ => colors.onSurface.withValues(alpha: 0.60),
    };

    return Semantics(
      // Holat faqat rang orqali berilmaydi: ekran o'quvchi ham tanlangan va
      // hali mavjud bo'lmagan bo'limni ajrata oladi.
      label: isEnabled ? label : '$label, coming soon',
      selected: isActive,
      enabled: isEnabled,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
