import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_state.dart';
import 'package:ai_pronunciation_coach/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveRouteAfterSplash', () {
    const AuthUser user = AuthUser(
      id: 'u1',
      name: 'Samandar',
      email: 'user@example.com',
    );

    test('sessiya yo\'q bo\'lsa Welcome\'ga yuboradi', () {
      expect(
        resolveRouteAfterSplash(const Unauthenticated()),
        AppRoutes.welcome,
      );
    });

    test('sessiya bor bo\'lsa Account\'ga yuboradi', () {
      expect(
        resolveRouteAfterSplash(const Authenticated(user)),
        AppRoutes.account,
      );
    });

    test('holat hali aniqlanmagan bo\'lsa hech qayerga yubormaydi', () {
      // Sessiya tekshirilayotgan paytda foydalanuvchini na kirgan, na
      // chiqqan deb hisoblash mumkin — Splash kutib turishi kerak.
      expect(resolveRouteAfterSplash(const AuthLoading()), isNull);
    });
  });
}
