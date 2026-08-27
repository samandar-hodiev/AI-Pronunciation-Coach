import 'package:flutter/material.dart';

/// Ilovaning to'liq rang palitrasi.
///
/// Palitra ataylab juda cheklangan: har bir element uchun alohida rang
/// o'ylab topilmaydi. Faqat quyidagilar ishlatiladi:
///
/// * [background]    — ekran foni
/// * [primary]       — brend rangi (logo, asosiy urg'u)
/// * [onPrimary]     — [primary] ustidagi kontent
/// * [textPrimary]   — asosiy matn
/// * [textSecondary] — ikkilamchi matn
///
/// Gradient, neon rang, glassmorphism yoki ortiqcha soya ishlatilmaydi.
abstract final class AppColors {
  // --- Light ---
  static const Color background = Color(0xFFFBFBFC);
  static const Color primary = Color(0xFF0F5C63);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF12181B);
  static const Color textSecondary = Color(0xFF5C6B72);

  // --- Dark ---
  static const Color backgroundDark = Color(0xFF0D1416);
  static const Color primaryDark = Color(0xFF4FB3AE);
  static const Color onPrimaryDark = Color(0xFF06211F);
  static const Color textPrimaryDark = Color(0xFFE6EDEF);
  static const Color textSecondaryDark = Color(0xFF8FA3A8);
}
