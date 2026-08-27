import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/presentation/widgets/auth_error_banner.dart';
import '../../profile/domain/profile_state.dart';
import '../../profile/presentation/controllers/profile_controller.dart';

/// Tizimga kirgan foydalanuvchining ekrani.
///
/// Bu **Dashboard emas** — u hali yaratilmagan. Ekran sessiya va profil
/// haqiqatan ishlayotganini ko'rsatadi: serverdan kelgan ma'lumot, sozlash
/// holati va chiqish tugmasi. Soxta statistika yoki mashq ma'lumoti yo'q.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const String signedInLabel = 'Signed in';
  static const String setupIncompleteLabel = 'Finish setting up your profile';
  static const String continueSetupLabel = 'Continue setup';
  static const String signOutLabel = 'Log out';
  static const String retryLabel = 'Try again';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final AuthState auth = ref.watch(authControllerProvider);
    final ProfileState profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: switch (auth) {
            AuthLoading() => const Center(child: CircularProgressIndicator()),
            Unauthenticated() => const Center(
              child: Text('You are signed out.'),
            ),
            Authenticated(:final user) => _SignedIn(
              // Ism profildan olinadi: sozlash paytida foydalanuvchi uni
              // o'zgartirishi mumkin, shuning uchun ro'yxatdan o'tishdagi
              // qiymat eskirgan bo'lishi mumkin.
              name: switch (profileState) {
                ProfileReady(:final profile) when profile.name.isNotEmpty =>
                  profile.name,
                _ => user.name,
              },
              email: user.email,
              profileState: profileState,
              textTheme: text,
            ),
          },
        ),
      ),
    );
  }
}

/// Tizimga kirgan holatdagi kontent.
class _SignedIn extends ConsumerWidget {
  const _SignedIn({
    required this.name,
    required this.email,
    required this.profileState,
    required this.textTheme,
  });

  final String name;
  final String email;
  final ProfileState profileState;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool setupCompleted = switch (profileState) {
      ProfileReady(:final profile) => profile.setupCompleted,
      _ => true,
    };

    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const BrandMark(size: 56),
                const SizedBox(height: AppSpacing.lg),
                Text(AccountScreen.signedInLabel, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (profileState is ProfileFailed) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  AuthErrorBanner(
                    message: (profileState as ProfileFailed).message,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () =>
                        ref.read(profileControllerProvider.notifier).reload(),
                    child: const Text(AccountScreen.retryLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Sozlash tugamagan bo'lsa uni davom ettirish taklif qilinadi.
        if (!setupCompleted)
          PrimaryButton(
            label: AccountScreen.continueSetupLabel,
            onPressed: () => context.go(AppRoutes.goal),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
            if (!context.mounted) return;
            context.go(AppRoutes.welcome);
          },
          child: const Text(AccountScreen.signOutLabel),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
