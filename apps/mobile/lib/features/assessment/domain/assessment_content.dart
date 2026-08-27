import 'assessment_step.dart';

/// Assessment Introduction ekranidagi kontent.
///
/// Matnlar shu yerda saqlanadi, widget ichida emas — davomiylik yoki
/// bosqichlar o'zgarsa UI kodiga tegish shart emas.
abstract final class AssessmentContent {
  static const List<AssessmentStep> steps = <AssessmentStep>[
    AssessmentStep(
      id: 'listen',
      order: 1,
      title: 'Listen',
      description: 'Listen to a short phrase.',
    ),
    AssessmentStep(
      id: 'speak',
      order: 2,
      title: 'Speak',
      description: 'Repeat the phrase naturally.',
    ),
    AssessmentStep(
      id: 'improve',
      order: 3,
      title: 'Improve',
      description: 'Get feedback on the sounds you can improve.',
    ),
  ];

  /// Baholashning taxminiy davomiyligi.
  ///
  /// Hozircha faqat matn — hech qanday taymer yoki backend qiymati yo'q.
  /// Haqiqiy davomiylik aniqlangach shu yerni yangilash kifoya.
  static const String estimatedDuration = 'About 2 minutes';

  /// Mikrofon nima uchun kerakligi.
  ///
  /// Ataylab faqat faktik: audio qanday saqlanishi yoki saqlanmasligi haqida
  /// va'da berilmaydi, chunki bunday siyosat hali belgilanmagan.
  static const String microphoneExplanation =
      'Microphone access is needed so we can hear your pronunciation.';
}
