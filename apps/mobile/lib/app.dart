import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_wordmark.dart';

/// Ilovaning ildiz widgeti.
///
/// Faqat mavzu va navigatsiyani ulaydi. Biznes mantiq bu yerda saqlanmaydi.
class AiPronunciationCoachApp extends StatefulWidget {
  const AiPronunciationCoachApp({super.key, this.router});

  /// Testlarda o'z router'ini berish uchun. `null` bo'lsa standart
  /// konfiguratsiya yaratiladi.
  final GoRouter? router;

  @override
  State<AiPronunciationCoachApp> createState() =>
      _AiPronunciationCoachAppState();
}

class _AiPronunciationCoachAppState extends State<AiPronunciationCoachApp> {
  late final GoRouter _router = widget.router ?? AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppWordmark.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
