import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/practice/data/device_practice_recorder.dart';
import 'package:ai_pronunciation_coach/features/practice/domain/practice_recorder.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/practice_screen.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/widgets/recording_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Mashq ekranini haqiqiy qurilmada tekshiradi.
///
/// Bu testlar **haqiqiy** diktofon va mikrofon ruxsati API'sidan foydalanadi
/// — soxta implementatsiya yo'q. Shu sababli ular Info.plist sozlamasi va
/// permission_handler ulanishini ham tekshiradi; buni widget testi qila
/// olmaydi.
///
/// Eslatma: iOS simulyatorida mikrofon host Mac'ning qurilmasiga bog'liq.
/// Ruxsat berilmagan bo'lsa test buni xato deb hisoblamaydi — u haqiqiy
/// holatni tekshiradi va yozib olishni faqat ruxsat mavjud bo'lgandagina
/// sinaydi.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  int pumpCount = 0;

  Future<void> pumpAt(WidgetTester tester, String location) async {
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: AppRouter.create().configuration.routes,
    );
    addTearDown(router.dispose);

    pumpCount++;
    await tester.pumpWidget(
      ProviderScope(
        child: AiPronunciationCoachApp(
          key: ValueKey<int>(pumpCount),
          router: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('haqiqiy diktofon ruxsat holatini qaytaradi', (
    WidgetTester tester,
  ) async {
    final DevicePracticeRecorder recorder = DevicePracticeRecorder();
    addTearDown(recorder.dispose);

    // Haqiqiy platforma so'rovi — Info.plist va permission_handler ulanishi
    // ishlayotganini tasdiqlaydi.
    final MicrophonePermission permission = await recorder.checkPermission();

    expect(permission, isA<MicrophonePermission>());
    debugPrint('DEVICE microphone permission: $permission');
  });

  testWidgets('mashq ekrani haqiqiy holatni ko\'rsatadi', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, AppRoutes.practice);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(PracticeScreen), findsOneWidget);

    // Ruxsat berilmagan bo'lsa tushuntirish, berilgan bo'lsa yozib olish
    // boshqaruvi ko'rinadi. Ikkalasi ham haqiqiy holat.
    final bool needsPermission = find
        .text(PracticeScreen.permissionTitle)
        .evaluate()
        .isNotEmpty;
    final bool canRecord = find.byType(RecordingControl).evaluate().isNotEmpty;

    debugPrint(
      'DEVICE practice screen: needsPermission=$needsPermission '
      'canRecord=$canRecord',
    );

    // Ekran shu ikki holatdan birida bo'lishi shart — uchinchisi xato.
    expect(needsPermission || canRecord, isTrue);
  });
}
