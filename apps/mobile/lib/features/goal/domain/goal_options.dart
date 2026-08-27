import 'package:flutter/material.dart';

import 'goal_option.dart';

/// Goal Selection ekranida ko'rsatiladigan variantlar.
///
/// Tartib ataylab shunday: eng keng tarqalgan maqsaddan boshlanib, eng aniq
/// (imtihon) maqsad bilan tugaydi.
abstract final class GoalOptions {
  static const List<GoalOption> all = <GoalOption>[
    GoalOption(
      id: 'speak_clearly',
      title: 'Speak more clearly',
      description: 'Make your English easier to understand.',
      icon: Icons.record_voice_over_outlined,
    ),
    GoalOption(
      id: 'difficult_sounds',
      title: 'Improve difficult sounds',
      description: 'Focus on sounds you often pronounce incorrectly.',
      icon: Icons.graphic_eq_rounded,
    ),
    GoalOption(
      id: 'reduce_accent',
      title: 'Reduce my accent',
      description: 'Work toward more natural English pronunciation.',
      icon: Icons.tune_rounded,
    ),
    GoalOption(
      id: 'speak_confidently',
      title: 'Speak more confidently',
      description: 'Feel more confident when speaking English.',
      icon: Icons.emoji_people_outlined,
    ),
    GoalOption(
      id: 'exam_preparation',
      title: 'Prepare for an exam',
      description: 'Improve pronunciation for IELTS, TOEFL, or other exams.',
      icon: Icons.school_outlined,
    ),
  ];
}
