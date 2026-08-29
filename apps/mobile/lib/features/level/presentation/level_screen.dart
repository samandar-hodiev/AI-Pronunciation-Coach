import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/personalization_steps.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/setup_header.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/selectable_option_card.dart';
import '../domain/english_level.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../profile/presentation/controllers/profile_controller.dart';
import '../domain/english_levels.dart';
import 'widgets/level_indicator.dart';

/// Foydalanuvchining hozirgi ingliz tili darajasini so'raydi.
///
/// Personalizatsiyaning ikkinchi va oxirgi bosqichi. Faqat bitta daraja
/// tanlanadi va tanlov qilinmaguncha davom etib bo'lmaydi.
///
/// Tanlov lokal draft'da saqlanadi va backend'ga faqat Profile Setup
/// bosqichida yuboriladi.
class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key});

  static const String title = 'What\'s your English level?';

  static const String description =
      'This helps us tailor your pronunciation practice.';

  static const String ctaLabel = 'Continue';

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  /// Tanlangan darajaning barqaror identifikatori. `null` — hali tanlanmagan.
  String? _selectedLevelId;

  @override
  void initState() {
    super.initState();
    _selectedLevelId = ref.read(profileDraftProvider).levelId;
  }

  bool get _hasSelection => _selectedLevelId != null;

  void _onLevelSelected(String id) {
    // Bitta tanlov: yangi qiymat oldingisini almashtiradi.
    setState(() => _selectedLevelId = id);
  }

  void _onContinue() {
    final String? levelId = _selectedLevelId;
    if (levelId == null) return;

    ref.read(profileDraftProvider.notifier).setLevel(levelId);
    context.go(_nextRoute());
  }

  /// Daraja tanlangandan keyingi manzil.
  ///
  /// Personalizatsiya oqimiga ikki tomondan kirish mumkin:
  ///
  /// * kirmagan foydalanuvchi — onboarding'dan keladi va keyingi qadam
  ///   Assessment Introduction bo'ladi;
  /// * kirgan, lekin profilini tugatmagan foydalanuvchi — splash'dan
  ///   keladi va uni Profile Setup'ga qaytarish kerak, aks holda profili
  ///   hech qachon saqlanmay qoladi.
  String _nextRoute() {
    final AuthState auth = ref.read(authControllerProvider);
    return auth is Authenticated
        ? AppRoutes.profileSetup
        : AppRoutes.assessmentIntro;
  }

  void _onBack() => context.go(AppRoutes.goal);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SetupHeader(stepIndex: PersonalizationSteps.level, onBack: _onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  // Katta ekranlarda kartalar cho'zilib ketmasligi uchun.
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(LevelScreen.title, style: text.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(LevelScreen.description, style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      for (final EnglishLevel level in EnglishLevels.all) ...[
                        SelectableOptionCard(
                          leading: LevelIndicator(
                            filledCount: level.rank,
                            totalCount: EnglishLevels.count,
                          ),
                          title: level.title,
                          description: level.description,
                          isSelected: _selectedLevelId == level.id,
                          onTap: () => _onLevelSelected(level.id),
                        ),
                        if (level != EnglishLevels.all.last)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                label: LevelScreen.ctaLabel,
                // `null` tugmani o'chirilgan holatga o'tkazadi.
                onPressed: _hasSelection ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
