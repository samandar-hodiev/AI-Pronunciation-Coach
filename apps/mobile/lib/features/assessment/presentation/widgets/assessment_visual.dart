import 'package:flutter/material.dart';

/// Assessment Introduction ekranining vizual belgisi.
///
/// Onboarding vizuallari bilan bir xil uslub: yumaloq kvadrat va asosiy
/// rangning shaffof foni. Rasm asseti yuklanmaydi.
///
/// Dekorativ — ma'noni sarlavha beradi.
class AssessmentVisual extends StatelessWidget {
  const AssessmentVisual({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Icon(
          Icons.mic_none_rounded,
          size: size * 0.44,
          color: colors.primary,
        ),
      ),
    );
  }
}
