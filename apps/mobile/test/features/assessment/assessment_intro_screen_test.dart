import 'package:ai_pronunciation_coach/app.dart';
import 'package:ai_pronunciation_coach/core/router/app_router.dart';
import 'package:ai_pronunciation_coach/core/router/app_routes.dart';
import 'package:ai_pronunciation_coach/features/assessment/domain/assessment_content.dart';
import 'package:ai_pronunciation_coach/features/assessment/domain/assessment_step.dart';
import 'package:ai_pronunciation_coach/features/assessment/presentation/assessment_intro_screen.dart';
import 'package:ai_pronunciation_coach/features/assessment/presentation/widgets/assessment_step_item.dart';
import 'package:ai_pronunciation_coach/features/level/presentation/level_screen.dart';
import 'package:ai_pronunciation_coach/features/microphone/presentation/microphone_screen.dart';
import 'package:ai_pronunciation_coach/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Assessment Introduction'dan boshlanadigan ilovani quradi.
Future<void> pumpIntro(WidgetTester tester) async {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.assessmentIntro,
    routes: AppRouter.create().configuration.routes,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(AiPronunciationCoachApp(router: router));
  await tester.pumpAndSettle();
}

/// CTA'ni bosadi (kichik viewportlarda ham ko'rinadigan joyga keltirib).
Future<void> tapStart(WidgetTester tester) async {
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

void main() {
  group('AssessmentIntroScreen', () {
    testWidgets('ekran ochiladi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(find.byType(AssessmentIntroScreen), findsOneWidget);
    });

    testWidgets('sarlavha ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(find.text(AssessmentIntroScreen.title), findsOneWidget);
    });

    testWidgets('izoh matni ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(find.text(AssessmentIntroScreen.description), findsOneWidget);
    });

    testWidgets('uchta bosqich ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(find.byType(AssessmentStepItem), findsNWidgets(3));
    });

    testWidgets('"Listen" bosqichi ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);

      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Listen to a short phrase.'), findsOneWidget);
    });

    testWidgets('"Speak" bosqichi ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);

      expect(find.text('Speak'), findsOneWidget);
      expect(find.text('Repeat the phrase naturally.'), findsOneWidget);
    });

    testWidgets('"Improve" bosqichi ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);

      expect(find.text('Improve'), findsOneWidget);
      expect(
        find.text('Get feedback on the sounds you can improve.'),
        findsOneWidget,
      );
    });

    testWidgets('bosqichlar tartib raqami bilan ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);

      for (final AssessmentStep step in AssessmentContent.steps) {
        expect(find.text('${step.order}'), findsOneWidget);
      }
    });

    testWidgets('taxminiy davomiylik ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(find.text(AssessmentContent.estimatedDuration), findsOneWidget);
    });

    testWidgets('mikrofon izohi ko\'rinadi', (WidgetTester tester) async {
      await pumpIntro(tester);
      expect(
        find.text(AssessmentContent.microphoneExplanation),
        findsOneWidget,
      );
    });

    testWidgets('CTA ko\'rinadi va yoqilgan', (WidgetTester tester) async {
      await pumpIntro(tester);

      expect(find.text(AssessmentIntroScreen.ctaLabel), findsOneWidget);

      final PrimaryButton button = tester.widget<PrimaryButton>(
        find.byType(PrimaryButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('bosqichni bosish hech qanday harakatga olib kelmaydi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);

      await tester.tap(find.text('Listen'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Bosqichlar ma'lumot beradi, ular tugma emas — ekran o'zgarmaydi.
      expect(find.byType(AssessmentIntroScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Navigatsiya', () {
    testWidgets('CTA mikrofon ekraniga o\'tkazadi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);
      await tapStart(tester);

      expect(find.byType(MicrophoneScreen), findsOneWidget);
      expect(find.text(MicrophoneScreen.placeholderLabel), findsOneWidget);
      expect(find.byType(AssessmentIntroScreen), findsNothing);
    });

    testWidgets('Back English Level\'ga qaytaradi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(LevelScreen), findsOneWidget);
    });

    testWidgets('bosqich konteksti ko\'rsatilmaydi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);

      // Assessment Intro personalizatsiya savoli emas — "Step N of 2"
      // chiqmasligi kerak.
      expect(find.textContaining('Step 1 of'), findsNothing);
      expect(find.textContaining('Step 2 of'), findsNothing);
      expect(find.textContaining('Step 3 of'), findsNothing);
    });

    testWidgets('navigatsiya paytida exception chiqmaydi', (
      WidgetTester tester,
    ) async {
      await pumpIntro(tester);
      await tapStart(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility', () {
    testWidgets('bosqichlar bitta tushunarli jumla sifatida o\'qiladi', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpIntro(tester);

      expect(
        find.bySemanticsLabel('Step 1, Listen. Listen to a short phrase.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Step 2, Speak. Repeat the phrase naturally.'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Step 3, Improve. Get feedback on the sounds you can improve.',
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('davomiylik to\'liq jumla sifatida o\'qiladi', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpIntro(tester);

      expect(
        find.bySemanticsLabel(
          'Estimated duration, ${AssessmentContent.estimatedDuration}.',
        ),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  group('Assessment layout', () {
    const List<Size> sizes = <Size>[
      Size(320, 568),
      Size(375, 667),
      Size(390, 844),
      Size(393, 852),
      Size(430, 932),
      Size(440, 956),
    ];

    for (final Size size in sizes) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()} da overflow yo\'q',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await pumpIntro(tester);

          expect(find.byType(AssessmentIntroScreen), findsOneWidget);
          // CTA har qanday balandlikda ko'rinib turishi kerak.
          expect(find.byType(PrimaryButton), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('kichik ekranda kontent aylanadi', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpIntro(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
