import 'package:ai_pronunciation_coach/core/network/api_exception.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/dashboard/presentation/home_screen.dart';
import 'package:ai_pronunciation_coach/features/practice/domain/practice_recorder.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/controllers/practice_controller.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/practice_screen.dart';
import 'package:ai_pronunciation_coach/features/practice/presentation/widgets/recording_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

/// Mashq ekranini tizimga kirgan foydalanuvchi bilan ochadi.
Future<(FakePracticeRepository, FakePracticeRecorder)> pumpPractice(
  WidgetTester tester, {
  FakePracticeRepository? repository,
  FakePracticeRecorder? recorder,
  bool settle = true,
}) async {
  final FakePracticeRepository repo = repository ?? FakePracticeRepository();
  final FakePracticeRecorder rec = recorder ?? FakePracticeRecorder();

  await pumpAppAt(
    tester,
    AppRoutes.practice,
    repository: FakeAuthRepository(existingUser: testUser),
    practiceRepository: repo,
    practiceRecorder: rec,
    settle: settle,
  );

  return (repo, rec);
}

/// Yozib olishni boshlaydi.
Future<void> startRecording(WidgetTester tester) async {
  await tester.tap(find.byType(RecordingControl));
  await tester.pumpAndSettle();
}

void main() {
  group('PracticeScreen', () {
    testWidgets('ekran ochiladi va sessiya yaratiladi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, _) = await pumpPractice(tester);

      expect(find.byType(PracticeScreen), findsOneWidget);
      expect(repo.createCalls, 1);
      expect(find.text(PracticeScreen.instruction), findsOneWidget);
      expect(find.text(PracticeScreen.prompt), findsOneWidget);
    });

    testWidgets('boshida taymer nolda va yozuv boshlanmagan', (
      WidgetTester tester,
    ) async {
      final (_, FakePracticeRecorder rec) = await pumpPractice(tester);

      expect(find.text('00:00'), findsOneWidget);
      // Taymer yozuv boshlanmasdan ishlamasligi kerak.
      expect(rec.startCalls, 0);
    });

    testWidgets('sessiya yaratish xatosi ko\'rsatiladi va qayta urinish bor', (
      WidgetTester tester,
    ) async {
      await pumpPractice(
        tester,
        repository: FakePracticeRepository(
          createError: const ApiException(
            message: 'Cannot reach the server. Check your internet connection.',
          ),
        ),
      );

      expect(
        find.text('Cannot reach the server. Check your internet connection.'),
        findsOneWidget,
      );
      expect(find.text(PracticeScreen.retryLabel), findsOneWidget);
    });

    testWidgets('kutilmagan xatoda stack trace ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpPractice(
        tester,
        repository: FakePracticeRepository(
          createError: StateError('internal failure'),
        ),
      );

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('StateError'), findsNothing);
    });
  });

  group('Mikrofon ruxsati', () {
    testWidgets('ruxsat berilmagan bo\'lsa tushuntirish ko\'rsatiladi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, _) = await pumpPractice(
        tester,
        recorder: FakePracticeRecorder(permission: MicrophonePermission.denied),
      );

      expect(find.text(PracticeScreen.permissionTitle), findsOneWidget);
      expect(find.text(PracticeScreen.permissionMessage), findsOneWidget);
      expect(find.text(PracticeScreen.allowLabel), findsOneWidget);
      // Ruxsatsiz sessiya ham yaratilmasligi kerak.
      expect(repo.createCalls, 0);
    });

    testWidgets('ruxsat berilgach sessiya yaratiladi', (
      WidgetTester tester,
    ) async {
      final (
        FakePracticeRepository repo,
        FakePracticeRecorder rec,
      ) = await pumpPractice(
        tester,
        recorder: FakePracticeRecorder(
          permission: MicrophonePermission.denied,
          permissionAfterRequest: MicrophonePermission.granted,
        ),
      );

      await tester.tap(find.text(PracticeScreen.allowLabel));
      await tester.pumpAndSettle();

      expect(rec.requestCalls, 1);
      expect(repo.createCalls, 1);
      expect(find.byType(RecordingControl), findsOneWidget);
    });

    testWidgets('butunlay rad etilgan bo\'lsa Sozlamalar taklif qilinadi', (
      WidgetTester tester,
    ) async {
      await pumpPractice(
        tester,
        recorder: FakePracticeRecorder(
          permission: MicrophonePermission.permanentlyDenied,
        ),
      );

      // Qayta so'rash ish bermaydi, shuning uchun boshqa harakat taklif
      // qilinadi.
      expect(find.text(PracticeScreen.openSettingsLabel), findsOneWidget);
      expect(find.text(PracticeScreen.allowLabel), findsNothing);
    });
  });

  group('Yozib olish', () {
    testWidgets('yozuv boshlanadi va serverda belgilanadi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, FakePracticeRecorder rec) =
          await pumpPractice(tester);

      await startRecording(tester);

      // Server avval xabardor qilinadi, keyin yozuv boshlanadi.
      expect(repo.startCalls, 1);
      expect(rec.startCalls, 1);

      // Tugma to'xtatish holatiga o'tishi kerak.
      final RecordingControl control = tester.widget<RecordingControl>(
        find.byType(RecordingControl),
      );
      expect(control.isRecording, isTrue);
    });

    testWidgets('taymer har soniyada yangilanadi', (WidgetTester tester) async {
      await pumpPractice(tester);
      await startRecording(tester);

      expect(find.text('00:00'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:01'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:03'), findsOneWidget);

      // Ekranni yopamiz — taymer qolib ketmasligi kerak.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('server xatosi bo\'lsa yozuv umuman boshlanmaydi', (
      WidgetTester tester,
    ) async {
      final (_, FakePracticeRecorder rec) = await pumpPractice(
        tester,
        repository: FakePracticeRepository(
          startError: const ApiException(message: 'Server unavailable.'),
        ),
      );

      await startRecording(tester);

      // Serverda izsiz yozuv qolmasligi uchun mikrofon ham ishga
      // tushmasligi kerak.
      expect(rec.startCalls, 0);
      expect(find.text('Server unavailable.'), findsOneWidget);
    });

    testWidgets('to\'xtatilganda sessiya yakunlanadi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, FakePracticeRecorder rec) =
          await pumpPractice(tester);

      await startRecording(tester);
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.byType(RecordingControl));
      await tester.pumpAndSettle();

      expect(rec.stopCalls, 1);
      expect(repo.completeCalls, 1);
      expect(find.text(PracticeScreen.completedTitle), findsOneWidget);
      expect(find.text(PracticeScreen.completedMessage), findsOneWidget);
      // Server hisoblagan davomiylik ko'rsatiladi.
      expect(find.text('00:07'), findsOneWidget);
    });

    testWidgets('eng uzun davomiylikda yozuv avtomatik to\'xtaydi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, _) = await pumpPractice(tester);

      await startRecording(tester);
      await tester.pump(
        const Duration(seconds: PracticeController.maxRecordingSeconds),
      );
      await tester.pumpAndSettle();

      // Cheksiz yozib olishga yo'l qo'yilmaydi.
      expect(repo.completeCalls, 1);
      expect(find.text(PracticeScreen.completedTitle), findsOneWidget);
    });

    testWidgets('audio yozilmasa bu yashirilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpPractice(
        tester,
        // Simulyatorda mikrofon bo'lmasa aynan shunday bo'ladi.
        recorder: FakePracticeRecorder(file: null),
      );

      await startRecording(tester);
      await tester.tap(find.byType(RecordingControl));
      await tester.pumpAndSettle();

      expect(find.text(PracticeScreen.noAudioMessage), findsOneWidget);
      expect(find.text(PracticeScreen.completedMessage), findsNothing);
    });

    testWidgets('bo\'sh fayl muvaffaqiyat deb hisoblanmaydi', (
      WidgetTester tester,
    ) async {
      await pumpPractice(
        tester,
        recorder: FakePracticeRecorder(
          file: const RecordingFile(path: '/tmp/empty.wav', sizeBytes: 0),
        ),
      );

      await startRecording(tester);
      await tester.tap(find.byType(RecordingControl));
      await tester.pumpAndSettle();

      expect(find.text(PracticeScreen.noAudioMessage), findsOneWidget);
    });

    testWidgets('yakunlash xatosi ko\'rsatiladi', (WidgetTester tester) async {
      await pumpPractice(
        tester,
        repository: FakePracticeRepository(
          completeError: const ApiException(
            message: 'Your practice could not be saved.',
          ),
        ),
      );

      await startRecording(tester);
      await tester.tap(find.byType(RecordingControl));
      await tester.pumpAndSettle();

      expect(find.text('Your practice could not be saved.'), findsOneWidget);
    });
  });

  group('Chiqish', () {
    testWidgets('yozuv boshlanmagan bo\'lsa darhol chiqadi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, _) = await pumpPractice(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(repo.cancelCalls, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('yozuv davom etayotganda tasdiq so\'raladi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, FakePracticeRecorder rec) =
          await pumpPractice(tester);

      await startRecording(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Audio jimgina yo'qotilmasligi kerak.
      expect(find.text('Stop recording and leave?'), findsOneWidget);
      expect(repo.cancelCalls, 0);
      expect(rec.cancelCalls, 0);
    });

    testWidgets('tasdiqdan voz kechilsa yozuv davom etadi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, _) = await pumpPractice(tester);

      await startRecording(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep recording'));
      await tester.pumpAndSettle();

      expect(repo.cancelCalls, 0);
      expect(find.byType(PracticeScreen), findsOneWidget);
    });

    testWidgets('tasdiqlansa yozuv o\'chiriladi va sessiya bekor qilinadi', (
      WidgetTester tester,
    ) async {
      final (FakePracticeRepository repo, FakePracticeRecorder rec) =
          await pumpPractice(tester);

      await startRecording(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(rec.cancelCalls, 1);
      expect(repo.cancelCalls, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('yakunlangach Done bosh ekranga qaytaradi', (
      WidgetTester tester,
    ) async {
      await pumpPractice(tester);

      await startRecording(tester);
      await tester.tap(find.byType(RecordingControl));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PracticeScreen.doneLabel));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Layout', () {
    const List<Size> sizes = <Size>[
      Size(320, 568),
      Size(390, 844),
      Size(430, 932),
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpPractice(tester);

          expect(find.byType(RecordingControl), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Taymer formati', () {
    test('soniyalarni mm:ss ko\'rinishida beradi', () {
      expect(RecordingTimer.format(0), '00:00');
      expect(RecordingTimer.format(7), '00:07');
      expect(RecordingTimer.format(60), '01:00');
      expect(RecordingTimer.format(125), '02:05');
    });
  });
}
