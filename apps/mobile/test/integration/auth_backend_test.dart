@Tags(<String>['backend'])
library;

import 'package:ai_pronunciation_coach/core/network/api_client.dart';
import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_api.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_user.dart';
import 'package:ai_pronunciation_coach/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ilovaning tarmoq qatlamini **haqiqiy** Go backend'iga qarshi tekshiradi.
///
/// Bu testlar mock ishlatmaydi: ular `ApiClient` → HTTP → Gin → PostgreSQL
/// yo'lini to'liq bosib o'tadi. Shu sababli ular faqat backend ishlab
/// turganda ma'noli:
///
/// ```
/// flutter test --tags backend
/// ```
///
/// Backend ishlamayotgan bo'lsa testlar o'tkazib yuboriladi.
void main() {
  const String baseUrl = 'http://localhost:8081';

  late ApiClient client;
  late AuthApi api;

  setUpAll(() async {
    client = ApiClient(dio: Dio(BaseOptions(baseUrl: baseUrl)));
    try {
      await client.get('/health');
    } catch (_) {
      // Marker: setUp'da skip qilib bo'lmaydi, shuning uchun har bir testda
      // tekshiriladi.
      client = ApiClient(dio: Dio(BaseOptions(baseUrl: baseUrl)));
    }
    api = AuthApi(client);
  });

  /// Backend javob berayotganini tekshiradi; bermasa testni o'tkazib yuboradi.
  Future<void> requireBackend() async {
    try {
      await client.get('/health');
    } catch (_) {
      markTestSkipped('Backend is not running at $baseUrl');
      return;
    }
  }

  String uniqueEmail() =>
      'flutter-${DateTime.now().microsecondsSinceEpoch}@example.com';

  test('health endpoint javob beradi', () async {
    await requireBackend();
    final Map<String, dynamic> json = await client.get('/health');
    expect(json['status'], 'ok');
  });

  test('register haqiqiy foydalanuvchi yaratadi va token qaytaradi', () async {
    await requireBackend();

    final Map<String, dynamic> json = await api.register(
      name: 'Flutter Test',
      email: uniqueEmail(),
      password: 'password123',
    );

    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    expect(data['access_token'], isA<String>());
    expect((data['access_token'] as String).isNotEmpty, isTrue);

    final Map<String, dynamic> user = data['user'] as Map<String, dynamic>;
    expect(user['name'], 'Flutter Test');
    // Parol yoki uning xeshi javobda bo'lmasligi kerak.
    expect(user.containsKey('password'), isFalse);
    expect(user.containsKey('password_hash'), isFalse);
  });

  test('takroriy email ApiException beradi', () async {
    await requireBackend();

    final String email = uniqueEmail();
    await api.register(name: 'A', email: email, password: 'password123');

    await expectLater(
      () => api.register(name: 'A', email: email, password: 'password123'),
      throwsA(
        isA<ApiException>()
            .having(
              (ApiException e) => e.code,
              'code',
              'EMAIL_ALREADY_REGISTERED',
            )
            .having((ApiException e) => e.statusCode, 'statusCode', 409),
      ),
    );
  });

  test('login to\'g\'ri parol bilan ishlaydi', () async {
    await requireBackend();

    final String email = uniqueEmail();
    await api.register(name: 'B', email: email, password: 'password123');

    final Map<String, dynamic> json = await api.login(
      email: email,
      password: 'password123',
    );
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    expect(data['access_token'], isA<String>());
  });

  test('login noto\'g\'ri parolda ApiException beradi', () async {
    await requireBackend();

    final String email = uniqueEmail();
    await api.register(name: 'C', email: email, password: 'password123');

    await expectLater(
      () => api.login(email: email, password: 'wrong-password'),
      throwsA(
        isA<ApiException>()
            .having((ApiException e) => e.code, 'code', 'INVALID_CREDENTIALS')
            .having(
              (ApiException e) => e.isUnauthorized,
              'isUnauthorized',
              isTrue,
            ),
      ),
    );
  });

  test('repository sessiyani saqlaydi va /auth/me orqali tiklaydi', () async {
    await requireBackend();

    // Xotiradagi ombor: platforma kanali testda mavjud emas, lekin
    // repozitoriyning qolgan mantiqi haqiqiy backend bilan tekshiriladi.
    final _InMemoryTokenStorage storage = _InMemoryTokenStorage();
    final ApiClient authedClient = ApiClient(
      dio: Dio(BaseOptions(baseUrl: baseUrl)),
      tokenProvider: storage.read,
    );
    final AuthRepositoryImpl repository = AuthRepositoryImpl(
      AuthApi(authedClient),
      storage,
    );

    final String email = uniqueEmail();
    final AuthUser registered = await repository.register(
      name: 'Session Test',
      email: email,
      password: 'password123',
    );

    expect(registered.email, email);
    expect(await storage.read(), isNotNull);

    final AuthUser? restored = await repository.restoreSession();
    expect(restored, isNotNull);
    expect(restored!.id, registered.id);
    expect(restored.email, email);

    await repository.signOut();
    expect(await storage.read(), isNull);
    expect(await repository.restoreSession(), isNull);
  });
}

/// Testlar uchun xotiradagi token ombori.
///
/// `flutter_secure_storage` platforma kanaliga tayanadi va u Dart VM
/// testlarida mavjud emas. Repozitoriyning qolgan mantiqi baribir haqiqiy
/// backend bilan tekshiriladi.
class _InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
