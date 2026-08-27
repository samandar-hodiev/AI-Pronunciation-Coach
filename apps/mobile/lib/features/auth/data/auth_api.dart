import '../../../core/network/api_client.dart';

/// Autentifikatsiya endpointlari.
///
/// Faqat so'rov yuborish va javobni qaytarish bilan shug'ullanadi — hech
/// qanday saqlash yoki holat mantiqi yo'q.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  static const String _base = '/api/v1/auth';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _client.post(
      '$_base/register',
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      '$_base/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> me() {
    return _client.get('$_base/me', authenticated: true);
  }
}
