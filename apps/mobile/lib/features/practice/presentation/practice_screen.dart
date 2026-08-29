import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/setup_header.dart';
import '../domain/practice_state.dart';
import 'controllers/practice_controller.dart';
import 'widgets/recording_control.dart';

/// Mashq sessiyasi ekrani.
///
/// Bu bosqichda talaffuz tahlili yo'q: ekran sessiyani boshlaydi, audio
/// yozadi va sessiyani yakunlaydi. Hech qanday ball yoki natija
/// ko'rsatilmaydi.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  static const String title = 'Practice';
  static const String instruction = 'Read the sentence aloud.';

  /// Mashq matni hozircha o'zgarmas — dars kontenti keyingi taskda.
  static const String prompt = 'She sells seashells by the seashore.';

  static const String permissionTitle = 'Microphone access needed';
  static const String permissionMessage =
      'Microphone access is needed to record your pronunciation.';
  static const String allowLabel = 'Allow microphone';
  static const String openSettingsLabel = 'Open Settings';

  static const String completedTitle = 'Practice completed';
  static const String completedMessage =
      'Your recording is ready for analysis.';
  static const String noAudioMessage =
      'The session was saved, but no audio was recorded on this device.';
  static const String doneLabel = 'Done';
  static const String retryLabel = 'Try again';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PracticeState state = ref.watch(practiceControllerProvider);

    return PopScope(
      // Yozuv davom etayotganda tasodifan chiqib ketish audio'ni yo'qotadi.
      canPop: state is! PracticeRecording,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        await _confirmLeave(context, ref);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              SetupHeader(onBack: () => _leave(context, ref, state)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: switch (state) {
                    PracticeInitializing() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    PracticePermissionRequired(:final permanentlyDenied) =>
                      _PermissionView(permanentlyDenied: permanentlyDenied),
                    PracticeReady() => const _RecordingView(
                      isRecording: false,
                      elapsedSeconds: 0,
                    ),
                    PracticeRecording(:final elapsedSeconds) => _RecordingView(
                      isRecording: true,
                      elapsedSeconds: elapsedSeconds,
                    ),
                    PracticeStopping() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    PracticeCompleted(:final session, :final recordingSaved) =>
                      _CompletedView(
                        durationSeconds: session.durationSeconds,
                        recordingSaved: recordingSaved,
                      ),
                    PracticeFailed(:final message) => _FailedView(
                      message: message,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Orqaga qaytish. Yozuv davom etayotgan bo'lsa tasdiq so'raladi.
  Future<void> _leave(
    BuildContext context,
    WidgetRef ref,
    PracticeState state,
  ) async {
    if (state is PracticeRecording) {
      await _confirmLeave(context, ref);
      return;
    }

    await ref.read(practiceControllerProvider.notifier).cancel();
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Stop recording and leave?'),
        content: const Text('Your recording will be discarded.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep recording'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (leave != true) return;

    await ref.read(practiceControllerProvider.notifier).cancel();
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }
}

/// Mikrofonga ruxsat so'ralayotgan holat.
class _PermissionView extends ConsumerWidget {
  const _PermissionView({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.mic_off_rounded,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            PracticeScreen.permissionTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            PracticeScreen.permissionMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            // Butunlay rad etilgan bo'lsa qayta so'rash ish bermaydi —
            // foydalanuvchini Sozlamalarga yuboramiz.
            label: permanentlyDenied
                ? PracticeScreen.openSettingsLabel
                : PracticeScreen.allowLabel,
            onPressed: permanentlyDenied
                ? openAppSettings
                : () => ref
                      .read(practiceControllerProvider.notifier)
                      .requestPermission(),
          ),
        ],
      ),
    );
  }
}

/// Yozib olishga tayyor va yozib olinayotgan holat.
class _RecordingView extends ConsumerWidget {
  const _RecordingView({
    required this.isRecording,
    required this.elapsedSeconds,
  });

  final bool isRecording;
  final int elapsedSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final PracticeController controller = ref.read(
      practiceControllerProvider.notifier,
    );

    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpacing.sm),
        Text(PracticeScreen.title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(PracticeScreen.instruction, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          PracticeScreen.prompt,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        RecordingTimer(
          elapsedSeconds: elapsedSeconds,
          maxSeconds: PracticeController.maxRecordingSeconds,
        ),
        const SizedBox(height: AppSpacing.xl),
        RecordingControl(
          isRecording: isRecording,
          onPressed: isRecording
              ? controller.stopRecording
              : controller.startRecording,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// Sessiya yakunlangan holat.
class _CompletedView extends StatelessWidget {
  const _CompletedView({
    required this.durationSeconds,
    required this.recordingSaved,
  });

  final int? durationSeconds;
  final bool recordingSaved;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  PracticeScreen.completedTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // Audio yozilmagan bo'lsa buni yashirmaymiz.
                  recordingSaved
                      ? PracticeScreen.completedMessage
                      : PracticeScreen.noAudioMessage,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (durationSeconds != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    RecordingTimer.format(durationSeconds!),
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: PracticeScreen.doneLabel,
          onPressed: () => context.go(AppRoutes.home),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Xatolik holati.
class _FailedView extends ConsumerWidget {
  const _FailedView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: PracticeScreen.retryLabel,
            onPressed: () =>
                ref.read(practiceControllerProvider.notifier).retry(),
          ),
        ],
      ),
    );
  }
}
