import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

/// Tizimga kirgan foydalanuvchining birinchi ekrani.
///
/// Bu **Dashboard emas** — u hali yaratilmagan. Bu ekran sessiya haqiqatan
/// ishlayotganini ko'rsatadi: `GET /auth/me` dan kelgan haqiqiy ma'lumot va
/// chiqish tugmasi. Soxta statistika yoki bo'sh kartalar qo'shilmagan.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const String signedInLabel = 'Signed in';
  static const String continueLabel = 'Continue setup';
  static const String signOutLabel = 'Log out';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final AuthState state = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: switch (state) {
            AuthLoading() => const Center(child: CircularProgressIndicator()),
            Unauthenticated() => const Center(
              child: Text('You are signed out.'),
            ),
            Authenticated(:final user) => Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const BrandMark(size: 56),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          AccountScreen.signedInLabel,
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.name,
                          style: text.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.email,
                          style: text.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                PrimaryButton(
                  label: AccountScreen.continueLabel,
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
            ),
          },
        ),
      ),
    );
  }
}
