import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

/// JWT access tokenni qurilmaning xavfsiz omborida saqlaydi.
///
/// iOS'da Keychain, Android'da EncryptedSharedPreferences ishlatiladi.
/// Token maxfiy ma'lumot, shuning uchun oddiy `SharedPreferences` da
/// saqlanmaydi.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_access_token';

  @override
  Future<String?> read() => _storage.read(key: _tokenKey);

  @override
  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
