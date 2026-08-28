import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/dashboard_data.dart';
import '../domain/dashboard_state.dart';
import 'controllers/dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_section.dart';
import 'widgets/home_bottom_navigation.dart';
import 'widgets/today_practice_section.dart';

/// Tizimga kirgan va sozlashni tugatgan foydalanuvchining bosh ekrani.
///
/// Barcha ma'lumot bitta so'rov bilan backenddan keladi. Bu yerda soxta
/// statistika, soxta ball yoki soxta mashq tarixi yo'q — ma'lumot mavjud
/// bo'lmasa bo'sh holat ko'rsatiladi.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String startPracticeLabel = 'Start Practice';

  static const String progressTitle = 'Pronunciation progress';
  static const String progressEmpty =
      'Start practicing to build your pronunciation progress.';

  static const String recentTitle = 'Recent practice';
  static const String recentEmpty = 'Your practice history will appear here.';

  static const String errorTitle = 'Something went wrong.';
  static const String errorHint = 'Check your connection and try again.';
  static const String retryLabel = 'Try again';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardState state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: switch (state) {
                DashboardLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                DashboardError(:final message) => _ErrorView(message: message),
                DashboardLoaded(:final data) => _LoadedView(data: data),
              },
            ),
            const HomeBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

/// Ma'lumot yuklangandagi ko'rinish.
class _LoadedView extends ConsumerWidget {
  const _LoadedView({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: <Widget>[
          DashboardHeader(
            userName: data.userName,
            onProfilePressed: () => context.go(AppRoutes.account),
          ),
          const SizedBox(height: AppSpacing.xl),
          TodayPracticeSection(
            goalMinutes: data.dailyPracticeGoalMinutes,
            today: data.today,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: HomeScreen.startPracticeLabel,
            onPressed: () => context.go(AppRoutes.practice),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Talaffuz ballari hali saqlanmaydi, shuning uchun backend bu
          // bo'limni "mavjud emas" deb qaytaradi va bo'sh holat ko'rsatiladi.
          DashboardSection(
            title: HomeScreen.progressTitle,
            message: HomeScreen.progressEmpty,
          ),
          const SizedBox(height: AppSpacing.xl),
          DashboardSection(
            title: HomeScreen.recentTitle,
            message: HomeScreen.recentEmpty,
          ),
        ],
      ),
    );
  }
}

/// Ma'lumotni yuklab bo'lmagandagi ko'rinish.
class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              HomeScreen.errorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              // Backenddan kelgan matn foydalanuvchi uchun yozilgan.
              message.isEmpty ? HomeScreen.errorHint : message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: HomeScreen.retryLabel,
              onPressed: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }
}
