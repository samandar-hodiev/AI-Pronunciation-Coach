import 'english_level.dart';

/// English Level Selection ekranidagi darajalar — oddiydan murakkabga.
abstract final class EnglishLevels {
  static const List<EnglishLevel> all = <EnglishLevel>[
    EnglishLevel(
      id: 'beginner',
      title: 'Beginner',
      description: 'I\'m just starting to learn English.',
      rank: 1,
    ),
    EnglishLevel(
      id: 'elementary',
      title: 'Elementary',
      description: 'I can understand and use simple English.',
      rank: 2,
    ),
    EnglishLevel(
      id: 'intermediate',
      title: 'Intermediate',
      description: 'I can communicate in everyday situations.',
      rank: 3,
    ),
    EnglishLevel(
      id: 'upper_intermediate',
      title: 'Upper-Intermediate',
      description: 'I can communicate comfortably in most situations.',
      rank: 4,
    ),
    EnglishLevel(
      id: 'advanced',
      title: 'Advanced',
      description: 'I can use English confidently and naturally.',
      rank: 5,
    ),
  ];

  /// Ko'rsatkichdagi ustunlar soni — eng yuqori daraja tartibiga teng.
  static int get count => all.length;
}
