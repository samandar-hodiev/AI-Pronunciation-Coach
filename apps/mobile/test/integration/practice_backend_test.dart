@Tags(<String>['backend'])
library;

import 'package:ai_pronunciation_coach/core/network/api_client.dart';
import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/storage/token_storage.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_api.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/practice/data/practice_api.dart';
import 'package:ai_pronunciation_coach/features/practice/data/practice_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/practice/domain/practice_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mashq qatlamini **haqiqiy** Go backend'iga qarshi tekshiradi.
void main() {
  const String baseUrl = 'http://localhost:8081';

  String uniqueEmail() =>
      'practice-${DateTime.now().microsecondsSinceEpoch}@example.com';

  Future<PracticeRepositoryImpl> registeredUser() async {
    final _InMemoryTokenStorage storage = _InMemoryTokenStorage();
    final ApiClient client = ApiClient(
      dio: Dio(BaseOptions(baseUrl: baseUrl)),
      tokenProvider: storage.read,
    );

    await AuthRepositoryImpl(AuthApi(client), storage).register(
      name: 'Practice Test',
      email: uniqueEmail(),
      password: 'password123',
    );

    return PracticeRepositoryImpl(PracticeApi(client));
  }

  test('to\'liq hayot sikli: create -> start -> complete', () async {
    final PracticeRepositoryImpl repository = await registeredUser();

    final PracticeSession created = await repository.createSession();
    expect(created.status, PracticeStatus.created);
    expect(created.durationSeconds, isNull);

    final PracticeSession started = await repository.startSession(created.id);
    expect(started.status, PracticeStatus.recording);

    // Davomiylik seziladigan bo'lishi uchun kutamiz.
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    final PracticeSession completed = await repository.completeSession(
      created.id,
    );
    expect(completed.status, PracticeStatus.completed);
    // Davomiylik server tomonidan hisoblanadi.
    expect(completed.durationSeconds, greaterThanOrEqualTo(1));

    final PracticeSession fetched = await repository.getSession(created.id);
    expect(fetched, completed);
  });

  test('start\'siz yakunlab bo\'lmaydi', () async {
    final PracticeRepositoryImpl repository = await registeredUser();
    final PracticeSession created = await repository.createSession();

    await expectLater(
      () => repository.completeSession(created.id),
      throwsA(
        isA<ApiException>()
            .having((ApiException e) => e.statusCode, 'statusCode', 409)
            .having((ApiException e) => e.code, 'code', 'INVALID_STATE'),
      ),
    );
  });

  test('bekor qilingan sessiya yakunlanmaydi', () async {
    final PracticeRepositoryImpl repository = await registeredUser();
    final PracticeSession created = await repository.createSession();
    await repository.startSession(created.id);

    final PracticeSession cancelled = await repository.cancelSession(
      created.id,
    );
    expect(cancelled.status, PracticeStatus.cancelled);

    await expectLater(
      () => repository.completeSession(created.id),
      throwsA(isA<ApiException>()),
    );
  });

  test('foydalanuvchilar bir-birining sessiyasini ko\'rmaydi', () async {
    final PracticeRepositoryImpl repoA = await registeredUser();
    final PracticeRepositoryImpl repoB = await registeredUser();

    final PracticeSession sessionA = await repoA.createSession();

    // Mavjudligi ham oshkor qilinmasligi kerak — 404.
    await expectLater(
      () => repoB.getSession(sessionA.id),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
    await expectLater(
      () => repoB.startSession(sessionA.id),
      throwsA(isA<ApiException>()),
    );
  });

  test('tokensiz sessiya yaratib bo\'lmaydi', () async {
    final PracticeRepositoryImpl repository = PracticeRepositoryImpl(
      PracticeApi(ApiClient(dio: Dio(BaseOptions(baseUrl: baseUrl)))),
    );

    await expectLater(
      repository.createSession,
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.isUnauthorized,
          'isUnauthorized',
          isTrue,
        ),
      ),
    );
  });
}

/// Testlar uchun xotiradagi token ombori.
class _InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
