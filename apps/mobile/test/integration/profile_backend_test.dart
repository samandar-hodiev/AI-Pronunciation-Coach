@Tags(<String>['backend'])
library;

import 'package:ai_pronunciation_coach/core/network/api_client.dart';
import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/storage/token_storage.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_api.dart';
import 'package:ai_pronunciation_coach/features/auth/data/auth_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/profile/data/profile_api.dart';
import 'package:ai_pronunciation_coach/features/profile/data/profile_repository_impl.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Profil qatlamini **haqiqiy** Go backend'iga qarshi tekshiradi.
///
/// ```
/// flutter test --tags backend --run-skipped
/// ```
void main() {
  const String baseUrl = 'http://localhost:8081';

  String uniqueEmail() =>
      'profile-${DateTime.now().microsecondsSinceEpoch}@example.com';

  /// Ro'yxatdan o'tgan foydalanuvchi uchun profil repozitoriysini qaytaradi.
  Future<(ProfileRepositoryImpl, _InMemoryTokenStorage)>
  registeredUser() async {
    final _InMemoryTokenStorage storage = _InMemoryTokenStorage();
    final ApiClient client = ApiClient(
      dio: Dio(BaseOptions(baseUrl: baseUrl)),
      tokenProvider: storage.read,
    );

    await AuthRepositoryImpl(AuthApi(client), storage).register(
      name: 'Profile Test',
      email: uniqueEmail(),
      password: 'password123',
    );

    return (ProfileRepositoryImpl(ProfileApi(client)), storage);
  }

  test('yangi foydalanuvchining profili sozlanmagan holatda keladi', () async {
    final (ProfileRepositoryImpl repository, _) = await registeredUser();

    final UserProfile profile = await repository.getProfile();

    expect(profile.setupCompleted, isFalse);
    expect(profile.pronunciationGoal, isNull);
    expect(profile.pronunciationLevel, isNull);
    expect(profile.dailyGoalMinutes, isNull);
    expect(profile.learningLanguage, 'en');
    expect(profile.name, 'Profile Test');
  });

  test('profil saqlangach setup_completed true bo\'ladi', () async {
    final (ProfileRepositoryImpl repository, _) = await registeredUser();

    final UserProfile saved = await repository.updateProfile(
      name: 'Saved Name',
      pronunciationGoal: 'difficult_sounds',
      pronunciationLevel: 'advanced',
      dailyGoalMinutes: 20,
    );

    expect(saved.setupCompleted, isTrue);
    expect(saved.name, 'Saved Name');
    expect(saved.pronunciationGoal, 'difficult_sounds');
    expect(saved.pronunciationLevel, 'advanced');
    expect(saved.dailyGoalMinutes, 20);

    // Keyingi o'qish ham saqlangan qiymatlarni qaytarishi kerak.
    final UserProfile fetched = await repository.getProfile();
    expect(fetched, saved);
  });

  test('backend noto\'g\'ri qiymatni rad etadi', () async {
    final (ProfileRepositoryImpl repository, _) = await registeredUser();

    // Mijoz validatsiyasini aylanib o'tgan so'rov ham to'xtatilishi kerak.
    await expectLater(
      () => repository.updateProfile(
        name: 'X',
        pronunciationGoal: 'not_a_real_goal',
        pronunciationLevel: 'advanced',
        dailyGoalMinutes: 20,
      ),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.statusCode,
          'statusCode',
          422,
        ),
      ),
    );

    // Rad etilgan so'rov sozlashni tugallangan deb belgilamasligi kerak.
    expect((await repository.getProfile()).setupCompleted, isFalse);
  });

  test('tokensiz profilga kirib bo\'lmaydi', () async {
    final ApiClient anonymous = ApiClient(
      dio: Dio(BaseOptions(baseUrl: baseUrl)),
    );
    final ProfileRepositoryImpl repository = ProfileRepositoryImpl(
      ProfileApi(anonymous),
    );

    await expectLater(
      repository.getProfile,
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.isUnauthorized,
          'isUnauthorized',
          isTrue,
        ),
      ),
    );
  });

  test('foydalanuvchilar bir-birining profilini ko\'rmaydi', () async {
    final (ProfileRepositoryImpl repoA, _) = await registeredUser();
    final (ProfileRepositoryImpl repoB, _) = await registeredUser();

    await repoA.updateProfile(
      name: 'User A',
      pronunciationGoal: 'exam_preparation',
      pronunciationLevel: 'beginner',
      dailyGoalMinutes: 5,
    );

    final UserProfile profileB = await repoB.getProfile();

    expect(profileB.name, isNot('User A'));
    expect(profileB.setupCompleted, isFalse);
    expect(profileB.pronunciationGoal, isNull);
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
