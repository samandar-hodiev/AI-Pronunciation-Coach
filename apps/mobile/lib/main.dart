import 'package:flutter/material.dart';

void main() {
  runApp(const AiPronunciationCoachApp());
}

/// Root widget for the AI Pronunciation Coach application.
///
/// This is the project foundation only. Routing, theming, state management and
/// product screens are introduced in later tasks.
class AiPronunciationCoachApp extends StatelessWidget {
  const AiPronunciationCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Pronunciation Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C5D0B)),
      ),
      home: const FoundationPlaceholder(),
    );
  }
}

/// Temporary landing surface proving the app builds and runs.
class FoundationPlaceholder extends StatelessWidget {
  const FoundationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'AI Pronunciation Coach',
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Task 01 — project foundation',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
