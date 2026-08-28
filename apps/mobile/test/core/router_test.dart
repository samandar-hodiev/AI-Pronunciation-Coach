import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_state.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_user.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/profile_state.dart';
import 'package:ai_pronunciation_coach/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const AuthUser user = AuthUser(
    id: 'u1',
    name: 'Samandar',
    email: 'user@example.com',
  );

  UserProfile profile({required bool setupCompleted}) => UserProfile(
    name: 'Samandar',
    learningLanguage: 'en',
    setupCompleted: setupCompleted,
  );

  group('resolveRouteAfterSplash', () {
    test('sessiya yo\'q bo\'lsa Welcome\'ga yuboradi', () {
      expect(
        resolveRouteAfterSplash(
          const Unauthenticated(),
          const ProfileLoading(),
        ),
        AppRoutes.welcome,
      );
    });

    test('sessiya holati aniqlanmagan bo\'lsa hech qayerga yubormaydi', () {
      expect(
        resolveRouteAfterSplash(const AuthLoading(), const ProfileLoading()),
        isNull,
      );
    });

    test('kirgan, lekin profil yuklanmoqda — hech qayerga yubormaydi', () {
      // Bu paytda foydalanuvchini sozlagan yoki sozlamagan deb hisoblab
      // bo'lmaydi, shuning uchun sakrash yuz bermasligi kerak.
      expect(
        resolveRouteAfterSplash(
          const Authenticated(user),
          const ProfileLoading(),
        ),
        isNull,
      );
    });

    test('sozlash tugamagan bo\'lsa Goal ekraniga yuboradi', () {
      expect(
        resolveRouteAfterSplash(
          const Authenticated(user),
          ProfileReady(profile(setupCompleted: false)),
        ),
        AppRoutes.goal,
      );
    });

    test('sozlash tugagan bo\'lsa Account ekraniga yuboradi', () {
      expect(
        resolveRouteAfterSplash(
          const Authenticated(user),
          ProfileReady(profile(setupCompleted: true)),
        ),
        AppRoutes.home,
      );
    });

    test('profil yuklanmasa foydalanuvchi chiqarib yuborilmaydi', () {
      // Tarmoq muammosi sessiyani yaroqsiz qilmaydi.
      expect(
        resolveRouteAfterSplash(
          const Authenticated(user),
          const ProfileFailed('Cannot reach the server.'),
        ),
        AppRoutes.home,
      );
    });
  });
}
