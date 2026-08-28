@Tags(<String>['backend'])
library;

import 'package:ai_pronunciation_coach/core/network/api_client.dart';
import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/storage/token_storage.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_api.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/dashboard/data/dashboard_api.dart';
import 'package:ai_pronunciation_coach/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/dashboard/domain/dashboard_data.dart';
import 'package:ai_pronunciation_coach/features/profile/data/profile_api.dart';
import 'package:ai_pronunciation_coach/features/profile/data/profile_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bosh ekran qatlamini **haqiqiy** Go backend'iga qarshi tekshiradi.
void main() {
  const String baseUrl = 'http://localhost:8081';

  String uniqueEmail() =>
      'dashboard-${DateTime.now().microsecondsSinceEpoch}@example.com';

  /// Ro'yxatdan o'tgan va profili to'ldirilgan foydalanuvchi yaratadi.
  Future<DashboardRepositoryImpl> setUpUser({
    required String name,
    required int goalMinutes,
  }) async {
    final _InMemoryTokenStorage storage = _InMemoryTokenStorage();
    final ApiClient client = ApiClient(
      dio: Dio(BaseOptions(baseUrl: baseUrl)),
      tokenProvider: storage.read,
    );

    await AuthRepositoryImpl(
      AuthApi(client),
      storage,
    ).register(name: name, email: uniqueEmail(), password: 'password123');

    await ProfileRepositoryImpl(ProfileApi(client)).updateProfile(
      name: name,
      pronunciationGoal: 'speak_clearly',
      pronunciationLevel: 'beginner',
      dailyGoalMinutes: goalMinutes,
    );

    return DashboardRepositoryImpl(DashboardApi(client));
  }

  test('bosh ekran haqiqiy profil ma\'lumotini qaytaradi', () async {
    final DashboardRepositoryImpl repository = await setUpUser(
      name: 'Dashboard Real',
      goalMinutes: 15,
    );

    final DashboardData data = await repository.getDashboard();

    expect(data.userName, 'Dashboard Real');
    expect(data.dailyPracticeGoalMinutes, 15);
  });

  test('mavjud bo\'lmagan bo\'limlar halol belgilanadi', () async {
    final DashboardRepositoryImpl repository = await setUpUser(
      name: 'Empty Sections',
      goalMinutes: 5,
    );

    final DashboardData data = await repository.getDashboard();

    // Mashq o'lchovi, progress va tarix hali yo'q — soxta nol emas.
    expect(data.today.trackingAvailable, isFalse);
    expect(data.today.completedMinutes, isNull);
    expect(data.progress.available, isFalse);
    expect(data.recentPractice.available, isFalse);
  });

  test('tokensiz bosh ekranga kirib bo\'lmaydi', () async {
    final DashboardRepositoryImpl repository = DashboardRepositoryImpl(
      DashboardApi(ApiClient(dio: Dio(BaseOptions(baseUrl: baseUrl)))),
    );

    await expectLater(
      repository.getDashboard,
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.isUnauthorized,
          'isUnauthorized',
          isTrue,
        ),
      ),
    );
  });

  test('foydalanuvchilar bir-birining ma\'lumotini ko\'rmaydi', () async {
    final DashboardRepositoryImpl repoA = await setUpUser(
      name: 'User A',
      goalMinutes: 20,
    );
    final DashboardRepositoryImpl repoB = await setUpUser(
      name: 'User B',
      goalMinutes: 5,
    );

    final DashboardData dataA = await repoA.getDashboard();
    final DashboardData dataB = await repoB.getDashboard();

    expect(dataA.userName, 'User A');
    expect(dataA.dailyPracticeGoalMinutes, 20);
    expect(dataB.userName, 'User B');
    expect(dataB.dailyPracticeGoalMinutes, 5);
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
