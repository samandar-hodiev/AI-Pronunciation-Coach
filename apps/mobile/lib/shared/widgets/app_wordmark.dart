import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Ilova nomi va ixtiyoriy tagline.
///
/// Splash'dan tashqari boshqa ekranlarda ham qayta ishlatish mumkin bo'lishi
/// uchun alohida komponentga ajratilgan.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.tagline});

  /// Ilova nomi ostidagi qisqa izoh. `null` bo'lsa ko'rsatilmaydi.
  final String? tagline;

  /// Ilovaning rasmiy nomi.
  static const String appName = 'AI Pronunciation Coach';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String? tagline = this.tagline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          appName,
          style: text.headlineMedium,
          textAlign: TextAlign.center,
          // Kichik ekranlarda ham matn kesilmasligi uchun.
          softWrap: true,
        ),
        if (tagline != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(tagline, style: text.bodyMedium, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
