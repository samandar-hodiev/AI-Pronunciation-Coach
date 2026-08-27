import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveRouteAfterSplash', () {
    test('sessiya yo\'q bo\'lsa Welcome\'ga yuboradi', () {
      expect(
        resolveRouteAfterSplash(hasAuthenticatedSession: false),
        AppRoutes.welcome,
      );
    });

    test('sessiya bor bo\'lsa Home\'ga yuboradi', () {
      expect(
        resolveRouteAfterSplash(hasAuthenticatedSession: true),
        AppRoutes.home,
      );
    });

    test('standart holat — birinchi ochilish oqimi', () {
      expect(resolveRouteAfterSplash(), AppRoutes.welcome);
    });
  });
}
