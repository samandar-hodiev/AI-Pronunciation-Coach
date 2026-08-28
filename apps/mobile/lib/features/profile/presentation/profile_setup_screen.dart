import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/selectable_option_card.dart';
import '../../../shared/widgets/setup_header.dart';
import '../../auth/presentation/widgets/auth_error_banner.dart';
import '../../auth/presentation/widgets/auth_text_field.dart';
import '../domain/daily_goal_options.dart';
import '../domain/profile_draft.dart';
import '../domain/profile_state.dart';
import 'controllers/profile_controller.dart';

/// Sozlashning oxirgi bosqichi: ism va kunlik mashq maqsadi.
///
/// Maqsad va daraja oldingi ekranlarda tanlangan va [ProfileDraft] da
/// turibdi. Hammasi shu yerda bitta so'rov bilan saqlanadi — yarim
/// saqlangan profil qolmaydi.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  static const String title = 'Set up your profile';
  static const String description = 'Personalize your pronunciation practice.';
  static const String dailyGoalLabel = 'Daily practice goal';
  static const String ctaLabel = 'Save & Continue';

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();

  bool _nameInitialized = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Ism maydonini profildagi qiymat bilan bir marta to'ldiradi.
  ///
  /// Faqat bir marta: aks holda profil qayta yuklanganda foydalanuvchi
  /// yozayotgan matn ustiga yozilardi.
  void _initializeName(ProfileState state) {
    if (_nameInitialized) return;
    if (state is! ProfileReady) return;

    _name.text = state.profile.name;
    _nameInitialized = true;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ProfileDraft draft = ref.read(profileDraftProvider);
    final String? goalId = draft.goalId;
    final String? levelId = draft.levelId;
    final int? minutes = draft.dailyGoalMinutes;

    // Oldingi bosqichlar to'ldirilmagan bo'lsa foydalanuvchini o'sha yerga
    // qaytaramiz — bo'sh so'rov yuborishdan ko'ra foydaliroq.
    if (goalId == null) {
      context.go(AppRoutes.goal);
      return;
    }
    if (levelId == null) {
      context.go(AppRoutes.level);
      return;
    }
    if (minutes == null) {
      setState(() => _errorMessage = 'Please choose a daily practice goal.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(profileControllerProvider.notifier)
          .completeSetup(
            name: _name.text.trim(),
            pronunciationGoal: goalId,
            pronunciationLevel: levelId,
            dailyGoalMinutes: minutes,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      // Sessiya tugagan bo'lsa foydalanuvchini qayta kirishga yuboramiz.
      if (e.isUnauthorized) {
        context.go(AppRoutes.signIn);
        return;
      }
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ProfileState profileState = ref.watch(profileControllerProvider);
    final ProfileDraft draft = ref.watch(profileDraftProvider);

    _initializeName(profileState);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SetupHeader(
              onBack: _submitting ? null : () => context.go(AppRoutes.level),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ProfileSetupScreen.title,
                          style: text.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ProfileSetupScreen.description,
                          style: text.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_errorMessage != null) ...<Widget>[
                          AuthErrorBanner(message: _errorMessage!),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        AuthTextField(
                          label: 'Name',
                          controller: _name,
                          enabled: !_submitting,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          validator: (String? value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Name is required.'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          ProfileSetupScreen.dailyGoalLabel,
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final DailyGoalOption option
                            in DailyGoalOptions.all) ...<Widget>[
                          SelectableOptionCard(
                            leading: Icon(
                              Icons.schedule_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: option.title,
                            description: option.description,
                            isSelected:
                                draft.dailyGoalMinutes == option.minutes,
                            onTap: _submitting
                                ? () {}
                                : () => ref
                                      .read(profileDraftProvider.notifier)
                                      .setDailyGoal(option.minutes),
                          ),
                          if (option != DailyGoalOptions.all.last)
                            const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
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
                label: ProfileSetupScreen.ctaLabel,
                isLoading: _submitting,
                onPressed: (_submitting || draft.dailyGoalMinutes == null)
                    ? null
                    : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
