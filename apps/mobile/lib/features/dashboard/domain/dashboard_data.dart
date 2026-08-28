import 'package:flutter/foundation.dart';

/// Bo'limda ko'rsatiladigan ma'lumot mavjudligi.
///
/// Backend soxta qiymat qaytarish o'rniga "hali ma'lumot yo'q" deydi, ilova
/// esa bo'sh holat ko'rsatadi.
@immutable
class SectionAvailability {
  const SectionAvailability({required this.available});

  final bool available;

  factory SectionAvailability.fromJson(Map<String, dynamic>? json) {
    return SectionAvailability(available: json?['available'] as bool? ?? false);
  }

  @override
  bool operator ==(Object other) =>
      other is SectionAvailability && other.available == available;

  @override
  int get hashCode => available.hashCode;
}

/// Bugungi mashq holati.
@immutable
class TodayPractice {
  const TodayPractice({required this.trackingAvailable, this.completedMinutes});

  /// Mashq vaqtini o'lchash imkoni bor-yo'qligi.
  ///
  /// `false` bo'lsa [completedMinutes] ham `null` bo'ladi — bu "0 daqiqa
  /// mashq qilingan" degani emas, "o'lchov hali yo'q" degani.
  final bool trackingAvailable;

  final int? completedMinutes;

  factory TodayPractice.fromJson(Map<String, dynamic>? json) {
    return TodayPractice(
      trackingAvailable: json?['tracking_available'] as bool? ?? false,
      completedMinutes: json?['completed_minutes'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TodayPractice &&
      other.trackingAvailable == trackingAvailable &&
      other.completedMinutes == completedMinutes;

  @override
  int get hashCode => Object.hash(trackingAvailable, completedMinutes);
}

/// Bosh ekran ma'lumotlari.
@immutable
class DashboardData {
  const DashboardData({
    required this.userName,
    required this.today,
    required this.progress,
    required this.recentPractice,
    this.dailyPracticeGoalMinutes,
  });

  final String userName;

  /// Kunlik mashq maqsadi. Sozlash tugamagan bo'lsa `null`.
  final int? dailyPracticeGoalMinutes;

  final TodayPractice today;
  final SectionAvailability progress;
  final SectionAvailability recentPractice;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final Object? user = json['user'];

    return DashboardData(
      userName: user is Map<String, dynamic>
          ? (user['name'] as String? ?? '')
          : '',
      dailyPracticeGoalMinutes: json['daily_practice_goal_minutes'] as int?,
      today: TodayPractice.fromJson(json['today'] as Map<String, dynamic>?),
      progress: SectionAvailability.fromJson(
        json['progress'] as Map<String, dynamic>?,
      ),
      recentPractice: SectionAvailability.fromJson(
        json['recent_practice'] as Map<String, dynamic>?,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DashboardData &&
      other.userName == userName &&
      other.dailyPracticeGoalMinutes == dailyPracticeGoalMinutes &&
      other.today == today &&
      other.progress == progress &&
      other.recentPractice == recentPractice;

  @override
  int get hashCode => Object.hash(
    userName,
    dailyPracticeGoalMinutes,
    today,
    progress,
    recentPractice,
  );
}
