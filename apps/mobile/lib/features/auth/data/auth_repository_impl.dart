import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'auth_api.dart';

/// [AuthRepository] ning haqiqiy backend va xavfsiz ombor ustidagi
/// implementatsiyasi.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api, this._storage);

  final AuthApi _api;
  final TokenStorage _storage;

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.register(
      name: name,
      email: email,
      password: password,
    );
    return _persistSession(json);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.login(
      email: email,
      password: password,
    );
    return _persistSession(json);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final String? token = await _storage.read();
    if (token == null || token.isEmpty) return null;

    try {
      final Map<String, dynamic> json = await _api.me();
      final Map<String, dynamic> data = _dataOf(json);
      final Object? user = data['user'];
      if (user is! Map<String, dynamic>) return null;

      return AuthUser.fromJson(user);
    } on ApiException catch (e) {
      // Token eskirgan yoki bekor qilingan — uni saqlab qolishdan foyda yo'q.
      if (e.isUnauthorized) {
        await _storage.clear();
        return null;
      }
      // Tarmoq muammosi tokenni yaroqsiz qilmaydi, shuning uchun uni
      // o'chirmaymiz va xatoni yuqoriga uzatamiz.
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _storage.clear();

  /// Javobdagi tokenni saqlaydi va foydalanuvchini qaytaradi.
  Future<AuthUser> _persistSession(Map<String, dynamic> json) async {
    final Map<String, dynamic> data = _dataOf(json);

    final Object? token = data['access_token'];
    final Object? user = data['user'];

    if (token is! String || token.isEmpty || user is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Something went wrong. Please try again.',
      );
    }

    await _storage.write(token);
    return AuthUser.fromJson(user);
  }

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) {
    final Object? data = json['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
