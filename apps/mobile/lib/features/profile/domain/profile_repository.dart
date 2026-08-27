import 'user_profile.dart';

/// Profil amallari.
///
/// UI shu shartnomaga bog'lanadi, HTTP tafsilotlariga emas.
abstract interface class ProfileRepository {
  /// Joriy foydalanuvchining profilini qaytaradi.
  ///
  /// Profil hali yo'q bo'lsa server uni bo'sh holatda yaratadi.
  Future<UserProfile> getProfile();

  /// Sozlash ma'lumotlarini saqlaydi.
  ///
  /// Muvaffaqiyatli saqlangach server `setupCompleted` ni `true` qiladi.
  Future<UserProfile> updateProfile({
    required String name,
    required String pronunciationGoal,
    required String pronunciationLevel,
    required int dailyGoalMinutes,
  });
}
