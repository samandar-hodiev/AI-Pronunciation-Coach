import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_pronunciation_coach/main.dart';

void main() {
  testWidgets('app boots and renders the foundation placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AiPronunciationCoachApp());

    expect(find.text('AI Pronunciation Coach'), findsOneWidget);
    expect(find.text('Task 01 — project foundation'), findsOneWidget);
  });

  testWidgets('app renders a MaterialApp root', (WidgetTester tester) async {
    await tester.pumpWidget(const AiPronunciationCoachApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(FoundationPlaceholder), findsOneWidget);
  });
}
