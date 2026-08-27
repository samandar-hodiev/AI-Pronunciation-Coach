import '../../../core/network/api_client.dart';

/// Profil endpointlari.
class ProfileApi {
  const ProfileApi(this._client);

  final ApiClient _client;

  static const String _path = '/api/v1/profile';

  Future<Map<String, dynamic>> get() => _client.get(_path, authenticated: true);

  Future<Map<String, dynamic>> update({
    required String name,
    required String pronunciationGoal,
    required String pronunciationLevel,
    required int dailyGoalMinutes,
  }) {
    return _client.put(
      _path,
      body: <String, dynamic>{
        'name': name,
        'pronunciation_goal': pronunciationGoal,
        'pronunciation_level': pronunciationLevel,
        'daily_goal_minutes': dailyGoalMinutes,
      },
      authenticated: true,
    );
  }
}
