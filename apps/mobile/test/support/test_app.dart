import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_repository.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_user.dart';
import 'package:ai_pronunciation_coach/features/auth/presentation/controllers/auth_controller.dart';
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
  bool settle = true,
}) async {
  final FakeAuthRepository repo = repository ?? FakeAuthRepository();

  final GoRouter router = GoRouter(
    initialLocation: location,
    routes: AppRouter.create().configuration.routes,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[authRepositoryProvider.overrideWithValue(repo)],
      child: AiPronunciationCoachApp(router: router),
    ),
  );

  if (settle) await tester.pumpAndSettle();
  return repo;
}
