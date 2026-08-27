import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/value_proposition_item.dart';

/// Splash'dan keyingi birinchi mazmunli ekran.
///
/// Vazifasi — foydalanuvchiga mahsulot qiymatini qisqa tushuntirish va uni
/// keyingi bosqichga o'tkazish. Bu ekran holatsiz (stateless): dinamik
/// ma'lumot ham, backend so'rovi ham yo'q. Matnlar UI konfiguratsiyasi
/// sifatida shu yerda saqlanadi.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String headline = 'Improve your English pronunciation.';

  static const String description =
      'Speak naturally. Find the sounds you need to improve. '
      'Practice with focused feedback.';

  static const String ctaLabel = 'Start practicing';

  /// Ekranda ko'rsatiladigan uchta asosiy qiymat.
  static const List<({IconData icon, String title, String description})>
  valuePropositions = <({IconData icon, String title, String description})>[
    (
      icon: Icons.mic_none_rounded,
      title: 'Speak',
      description: 'Practice real English sounds.',
    ),
    (
      icon: Icons.graphic_eq_rounded,
      title: 'Analyze',
      description: 'Understand which sounds need improvement.',
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Improve',
      description: 'Build better pronunciation through focused practice.',
    ),
  ];

  void _startPracticing(BuildContext context) {
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: <Widget>[
              // Kontent aylanadi, CTA esa doim pastda ko'rinib turadi —
              // shu sababli tugma hech qachon ekrandan chiqib ketmaydi va
              // overflow yuzaga kelmaydi.
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        // minHeight — kontent kalta bo'lsa uni vertikal
                        // markazlashtirish uchun; maxWidth — katta ekranlarda
                        // matn haddan tashqari cho'zilmasligi uchun.
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxWidth: 460,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // Joy yetarli bo'lsa markazlashadi, yetmasa
                          // yuqoridan boshlanadi va aylanadi.
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const BrandMark(size: 56),
                            const SizedBox(height: AppSpacing.lg),
                            Text(headline, style: text.headlineMedium),
                            const SizedBox(height: AppSpacing.sm),
                            Text(description, style: text.bodyLarge),
                            const SizedBox(height: AppSpacing.xl),
                            for (final prop in valuePropositions) ...<Widget>[
                              ValuePropositionItem(
                                icon: prop.icon,
                                title: prop.title,
                                description: prop.description,
                              ),
                              if (prop != valuePropositions.last)
                                const SizedBox(height: AppSpacing.lg),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.lg,
                ),
                child: PrimaryButton(
                  label: ctaLabel,
                  onPressed: () => _startPracticing(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
