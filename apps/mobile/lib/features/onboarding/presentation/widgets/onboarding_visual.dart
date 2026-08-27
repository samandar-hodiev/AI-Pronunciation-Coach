import 'package:flutter/material.dart';

/// Onboarding sahifasining vizual belgisi.
///
/// Value proposition ikonkalari bilan bir xil uslub — yumaloq kvadrat va
/// asosiy rangning shaffof foni. Palitraga yangi rang qo'shilmaydi va rasm
/// asseti yuklanmaydi.
///
/// Dekorativ, shuning uchun semantik daraxtdan chiqarib tashlangan: ma'noni
/// yonidagi sarlavha beradi.
class OnboardingVisual extends StatelessWidget {
  const OnboardingVisual({super.key, required this.icon, this.size = 112});

  final IconData icon;

  /// Kvadratning tomoni. Kichik ekranlarda kichraytiriladi.
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
        child: Icon(icon, size: size * 0.42, color: colors.primary),
      ),
    );
  }
}
