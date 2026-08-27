import 'package:flutter/foundation.dart';

/// Kunlik mashq maqsadi varianti.
@immutable
class DailyGoalOption {
  const DailyGoalOption({
    required this.minutes,
    required this.title,
    required this.description,
  });

  /// Backend'ga yuboriladigan qiymat.
  final int minutes;

  final String title;
  final String description;
}

/// Tanlash mumkin bo'lgan kunlik maqsadlar.
///
/// Qiymatlar backend'dagi ruxsat etilgan ro'yxat bilan bir xil bo'lishi
/// shart — backend ham ularni tekshiradi.
abstract final class DailyGoalOptions {
  static const List<DailyGoalOption> all = <DailyGoalOption>[
    DailyGoalOption(
      minutes: 5,
      title: '5 minutes',
      description: 'A quick daily warm-up.',
    ),
    DailyGoalOption(
      minutes: 10,
      title: '10 minutes',
      description: 'A steady daily habit.',
    ),
    DailyGoalOption(
      minutes: 15,
      title: '15 minutes',
      description: 'Focused daily practice.',
    ),
    DailyGoalOption(
      minutes: 20,
      title: '20 minutes',
      description: 'Serious daily training.',
    ),
  ];
}
