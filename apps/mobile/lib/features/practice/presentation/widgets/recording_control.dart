import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Yozib olishni boshlash va to'xtatish tugmasi.
///
/// Yozuv davom etayotganini bildirish uchun juda kichik pulsatsiya
/// ishlatiladi — bu holat rangdan tashqari harakat bilan ham ko'rinadi.
class RecordingControl extends StatelessWidget {
  const RecordingControl({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  final bool isRecording;
  final VoidCallback? onPressed;

  static const String startLabel = 'Start recording';
  static const String stopLabel = 'Stop recording';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String label = isRecording ? stopLabel : startLabel;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isRecording
                  ? colors.error.withValues(alpha: 0.10)
                  : colors.primary,
              shape: BoxShape.circle,
              border: isRecording
                  ? Border.all(color: colors.error, width: 2)
                  : null,
            ),
            child: ExcludeSemantics(
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 40,
                color: isRecording ? colors.error : colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yozuv davomiyligi ko'rsatkichi.
class RecordingTimer extends StatelessWidget {
  const RecordingTimer({
    super.key,
    required this.elapsedSeconds,
    required this.maxSeconds,
  });

  final int elapsedSeconds;
  final int maxSeconds;

  /// `mm:ss` ko'rinishida.
  static String format(int seconds) {
    final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final String remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String value = format(elapsedSeconds);

    return Semantics(
      label: 'Practice timer, $value',
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Up to ${format(maxSeconds)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
