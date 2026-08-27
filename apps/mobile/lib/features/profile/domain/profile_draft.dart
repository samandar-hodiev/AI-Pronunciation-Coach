import 'package:flutter/foundation.dart';

/// Sozlash jarayonida to'planadigan tanlovlar.
///
/// Maqsad va daraja alohida ekranlarda tanlanadi, lekin bitta so'rov bilan
/// saqlanadi. Shu sababli ular yakuniy qadamgacha shu yerda turadi.
///
/// Bu **vaqtinchalik holat**: ilova yopilsa yo'qoladi. Saqlangan yagona
/// manba — backend.
@immutable
class ProfileDraft {
  const ProfileDraft({this.goalId, this.levelId, this.dailyGoalMinutes});

  final String? goalId;
  final String? levelId;
  final int? dailyGoalMinutes;

  ProfileDraft copyWith({
    String? goalId,
    String? levelId,
    int? dailyGoalMinutes,
  }) {
    return ProfileDraft(
      goalId: goalId ?? this.goalId,
      levelId: levelId ?? this.levelId,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProfileDraft &&
      other.goalId == goalId &&
      other.levelId == levelId &&
      other.dailyGoalMinutes == dailyGoalMinutes;

  @override
  int get hashCode => Object.hash(goalId, levelId, dailyGoalMinutes);
}
