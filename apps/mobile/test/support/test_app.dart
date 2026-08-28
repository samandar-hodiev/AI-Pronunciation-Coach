import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_repository.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_user.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_pronunciation_coach/features/dashboard/domain/dashboard_data.dart';
import 'package:ai_pronunciation_coach/features/dashboard/domain/dashboard_repository.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/profile_repository.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/user_profile.dart';
import 'package:ai_pronunciation_coach/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Testlarda ishlatiladigan boshqariladigan [AuthRepository].
///
/// Faqat `test/` ichida yashaydi — ilova kodi hech qachon soxta
/// implementatsiyadan foydalanmaydi. Bu widget testlarini tarmoqqa bog'lamay,
/// har bir holatni (muvaffaqiyat, xato, kechikish) aniq tekshirish imkonini
/// beradi.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.existingUser,
    this.registerResult,
    this.signInResult,
    this.delay = Duration.zero,
  });

  /// [restoreSession] qaytaradigan foydalanuvchi. `null` — sessiya yo'q.
  final AuthUser? existingUser;

  /// Muvaffaqiyatda qaytariladigan foydalanuvchi, yoki tashlanadigan xato.
  final Object? registerResult;
  final Object? signInResult;

  /// So'rov qancha davom etishini taqlid qiladi (loading holatini tekshirish
  /// uchun).
  final Duration delay;

  /// Har bir metod necha marta chaqirilgani — takroriy yuborishni tekshirish
  /// uchun.
  int registerCalls = 0;
  int signInCalls = 0;
  int signOutCalls = 0;

  bool signedOut = false;

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    return _resolve(registerResult);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    return _resolve(signInResult);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return existingUser;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    signedOut = true;
  }

  Future<AuthUser> _resolve(Object? result) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (result is AuthUser) return result;
    if (result is Object) throw result;
    throw StateError('FakeAuthRepository: no result configured');
  }
}

/// Testlarda ishlatiladigan boshqariladigan [ProfileRepository].
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    UserProfile? profile,
    this.getResult,
    this.updateResult,
    this.delay = Duration.zero,
  }) : _profile = profile ?? testProfile(setupCompleted: true);

  UserProfile _profile;

  /// `getProfile` tashlashi kerak bo'lgan xato. `null` — muvaffaqiyat.
  final Object? getResult;

  /// `updateProfile` natijasi: [UserProfile] yoki tashlanadigan xato.
  final Object? updateResult;

  final Duration delay;

  int getCalls = 0;
  int updateCalls = 0;

  /// Oxirgi saqlangan qiymatlar — testlar nima yuborilganini tekshiradi.
  String? savedName;
  String? savedGoal;
  String? savedLevel;
  int? savedMinutes;

  @override
  Future<UserProfile> getProfile() async {
    getCalls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final Object? failure = getResult;
    if (failure != null) throw failure;
    return _profile;
  }

  @override
  Future<UserProfile> updateProfile({
    required String name,
    required String pronunciationGoal,
    required String pronunciationLevel,
    required int dailyGoalMinutes,
  }) async {
    updateCalls++;
    savedName = name;
    savedGoal = pronunciationGoal;
    savedLevel = pronunciationLevel;
    savedMinutes = dailyGoalMinutes;

    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final Object? result = updateResult;
    if (result is UserProfile) {
      _profile = result;
      return result;
    }
    if (result != null) throw result;

    _profile = UserProfile(
      name: name,
      learningLanguage: 'en',
      setupCompleted: true,
      pronunciationGoal: pronunciationGoal,
      pronunciationLevel: pronunciationLevel,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    return _profile;
  }
}

/// Testlarda ishlatiladigan boshqariladigan [DashboardRepository].
class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({
    DashboardData? data,
    this.error,
    this.delay = Duration.zero,
  }) : _data = data ?? testDashboard();

  final DashboardData _data;

  /// `getDashboard` tashlashi kerak bo'lgan xato. `null` — muvaffaqiyat.
  final Object? error;

  final Duration delay;

  int calls = 0;

  @override
  Future<DashboardData> getDashboard() async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final Object? failure = error;
    if (failure != null) throw failure;
    return _data;
  }
}

/// Test uchun namunaviy bosh ekran ma'lumoti.
///
/// Standart holat mahsulotning hozirgi haqiqiy holatini aks ettiradi:
/// mashq o'lchovi, progress va tarix hali mavjud emas.
DashboardData testDashboard({
  String name = 'Samandar',
  int? goalMinutes = 10,
}) => DashboardData(
  userName: name,
  dailyPracticeGoalMinutes: goalMinutes,
  today: const TodayPractice(trackingAvailable: false),
  progress: const SectionAvailability(available: false),
  recentPractice: const SectionAvailability(available: false),
);

/// Test uchun namunaviy profil.
UserProfile testProfile({required bool setupCompleted}) => UserProfile(
  name: 'Samandar',
  learningLanguage: 'en',
  setupCompleted: setupCompleted,
  pronunciationGoal: setupCompleted ? 'reduce_accent' : null,
  pronunciationLevel: setupCompleted ? 'intermediate' : null,
  dailyGoalMinutes: setupCompleted ? 10 : null,
);

/// Test uchun namunaviy foydalanuvchi.
const AuthUser testUser = AuthUser(
  id: 'user-1',
  name: 'Samandar',
  email: 'samandar@example.com',
);

/// Ilovani berilgan boshlang'ich manzildan ishga tushiradi.
///
/// [repository] berilmasa sessiyasi yo'q soxta repozitoriy ishlatiladi,
/// shuning uchun testlar hech qachon haqiqiy tarmoqqa chiqmaydi.
Future<FakeAuthRepository> pumpAppAt(
  WidgetTester tester,
  String location, {
  FakeAuthRepository? repository,
  FakeProfileRepository? profileRepository,
  FakeDashboardRepository? dashboardRepository,
  bool settle = true,
}) async {
  final FakeAuthRepository repo = repository ?? FakeAuthRepository();
  final FakeProfileRepository profileRepo =
      profileRepository ?? FakeProfileRepository();
  final FakeDashboardRepository dashboardRepo =
      dashboardRepository ?? FakeDashboardRepository();

  final GoRouter router = GoRouter(
    initialLocation: location,
    routes: AppRouter.create().configuration.routes,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(repo),
        profileRepositoryProvider.overrideWithValue(profileRepo),
        dashboardRepositoryProvider.overrideWithValue(dashboardRepo),
      ],
      child: AiPronunciationCoachApp(router: router),
    ),
  );

  if (settle) await tester.pumpAndSettle();
  return repo;
}
