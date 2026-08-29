import 'package:flutter/material.dart';

/// Splash ekranidagi juda kichik yuklanish belgisi.
///
/// Ataylab sezilmas darajada: foydalanuvchi e'tiborini brenddan tortib
/// olmasligi kerak.
class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Yuklanmoqda',
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            colors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
