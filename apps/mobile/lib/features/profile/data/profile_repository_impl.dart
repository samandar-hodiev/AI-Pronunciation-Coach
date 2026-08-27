import '../../../core/network/api_exception.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';
import 'profile_api.dart';

/// [ProfileRepository] ning haqiqiy backend ustidagi implementatsiyasi.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._api);

  final ProfileApi _api;

  @override
  Future<UserProfile> getProfile() async => _parse(await _api.get());

  @override
  Future<UserProfile> updateProfile({
    required String name,
    required String pronunciationGoal,
    required String pronunciationLevel,
    required int dailyGoalMinutes,
  }) async {
    return _parse(
      await _api.update(
        name: name,
        pronunciationGoal: pronunciationGoal,
        pronunciationLevel: pronunciationLevel,
        dailyGoalMinutes: dailyGoalMinutes,
      ),
    );
  }

  UserProfile _parse(Map<String, dynamic> json) {
    final Object? data = json['data'];
    if (data is Map<String, dynamic>) {
      final Object? profile = data['profile'];
      if (profile is Map<String, dynamic>) {
        return UserProfile.fromJson(profile);
      }
    }
    throw const ApiException(
      message: 'Something went wrong. Please try again.',
    );
  }
}
