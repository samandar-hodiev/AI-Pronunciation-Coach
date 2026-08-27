import 'package:flutter/foundation.dart';

/// Foydalanuvchining talaffuz sozlamalari.
///
/// Maydonlar `null` bo'lishi mumkin, chunki sozlash tugagunicha ular
/// to'ldirilmagan bo'ladi. [setupCompleted] serverda hal qilinadi — mijoz uni
/// o'zgartira olmaydi.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.learningLanguage,
    required this.setupCompleted,
    this.pronunciationGoal,
    this.pronunciationLevel,
    this.dailyGoalMinutes,
  });

  final String name;
  final String learningLanguage;
  final bool setupCompleted;

  final String? pronunciationGoal;
  final String? pronunciationLevel;
  final int? dailyGoalMinutes;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      learningLanguage: json['learning_language'] as String? ?? 'en',
      setupCompleted: json['setup_completed'] as bool? ?? false,
      pronunciationGoal: json['pronunciation_goal'] as String?,
      pronunciationLevel: json['pronunciation_level'] as String?,
      dailyGoalMinutes: json['daily_goal_minutes'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.name == name &&
      other.learningLanguage == learningLanguage &&
      other.setupCompleted == setupCompleted &&
      other.pronunciationGoal == pronunciationGoal &&
      other.pronunciationLevel == pronunciationLevel &&
      other.dailyGoalMinutes == dailyGoalMinutes;

  @override
  int get hashCode => Object.hash(
    name,
    learningLanguage,
    setupCompleted,
    pronunciationGoal,
    pronunciationLevel,
    dailyGoalMinutes,
  );
}
