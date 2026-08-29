import 'package:flutter/material.dart';

/// Ilovaning yagona rang manbasi.
///
/// Har bir rang **semantik rol** nomi bilan saqlanadi ("primary", "border"),
/// rang nomi bilan emas ("teal", "grey"). Shu sababli brend rangi
/// o'zgarganda widgetlarga umuman tegilmaydi.
///
/// ## Rasmiy brend rangi
///
/// `oklch(77.7% 0.152 181.912)` → sRGB `#00D5BE`.
///
/// Bu rang OKLCH fazosida sRGB gamutidan biroz tashqarida (qizil kanal manfiy
/// chiqadi), shuning uchun eng yaqin sRGB qiymatiga siqilgan.
///
/// ## Nima uchun ikkita brend rol bor
///
/// Brend rangi **och** (L = 77.7%). Oq fon ustida uning kontrasti atigi
/// 1.86:1 — matn yoki ikonka sifatida o'qib bo'lmaydi. Shuning uchun:
///
/// * [primary] — **to'ldirilgan yuzalar** uchun (tugma foni, brend belgisi).
///   Ustiga [primaryForeground] qo'yiladi, kontrast 9.5:1.
/// * [primaryInk] — **neytral fon ustidagi brend kontenti** uchun (ikonka,
///   chegara, tanlangan holat). Ayni ottenok, lekin quyuqroq: oq fonda 5.2:1.
///
/// Qorong'i rejimda ikkalasi ham [primary] ga teng, chunki `#00D5BE` quyuq
/// fon ustida 10:1 kontrast beradi.
///
/// Gradient, neon, glassmorphism va ortiqcha soya ishlatilmaydi.
abstract final class AppColors {
  // ===== Light =====

  /// Ekran foni — deyarli oq, sezilmas darajada sovuq.
  static const Color background = Color(0xFFFBFCFC);

  /// Fon ustida ko'tarilgan yuza (karta, varaq).
  static const Color surface = Color(0xFFFFFFFF);

  /// Ikkilamchi yuza — ajratilgan, lekin diqqat tortmaydigan bloklar.
  static const Color surfaceSecondary = Color(0xFFF1F5F5);

  /// Rasmiy brend rangi. Faqat to'ldirilgan yuzalar uchun.
  static const Color primary = Color(0xFF00D5BE);

  /// [primary] ustidagi matn va ikonka.
  static const Color primaryForeground = Color(0xFF04231F);

  /// Neytral fon ustidagi brend kontenti (ikonka, chegara, tanlov).
  static const Color primaryInk = Color(0xFF007B6D);

  /// Brendning eng yengil ottenogi — ikonka podlojkasi, tanlangan karta foni.
  static const Color primarySoft = Color(0xFFDFFAF5);

  static const Color textPrimary = Color(0xFF0D1618);
  static const Color textSecondary = Color(0xFF526164);

  /// Uchinchi darajali matn: izoh, hint, faol bo'lmagan yorliq.
  static const Color textTertiary = Color(0xFF7C8D91);

  /// Ajratuvchi chiziq va karta chegarasi.
  static const Color border = Color(0xFFE1E8E8);

  static const Color error = Color(0xFFB3352B);
  static const Color onError = Color(0xFFFFFFFF);

  /// Muvaffaqiyat holati uchun ajratilgan rol.
  ///
  /// Hozircha UI'da ishlatilmaydi — birinchi haqiqiy muvaffaqiyat holati
  /// (masalan, baholash natijasi) paydo bo'lganda shu yerdan olinadi.
  static const Color success = Color(0xFF0F7355);

  /// O'chirilgan tugma foni.
  static const Color disabled = Color(0xFFDCE3E3);

  /// [disabled] ustidagi matn.
  static const Color onDisabled = Color(0xFF8A9698);

  // ===== Dark =====

  static const Color backgroundDark = Color(0xFF0B1213);
  static const Color surfaceDark = Color(0xFF111A1B);
  static const Color surfaceSecondaryDark = Color(0xFF182223);

  /// Brend rangi qorong'i rejimda o'zgarmaydi — ilova bir xil brendga ega
  /// bo'lib qoladi va quyuq fonda kontrasti allaqachon yetarli.
  static const Color primaryDark = Color(0xFF00D5BE);
  static const Color primaryForegroundDark = Color(0xFF04231F);
  static const Color primaryInkDark = Color(0xFF00D5BE);
  static const Color primarySoftDark = Color(0xFF0E2B27);

  static const Color textPrimaryDark = Color(0xFFE7EEEE);
  static const Color textSecondaryDark = Color(0xFF9EB0B1);
  static const Color textTertiaryDark = Color(0xFF6F8183);

  static const Color borderDark = Color(0xFF253130);

  static const Color errorDark = Color(0xFFF08B7F);
  static const Color onErrorDark = Color(0xFF2A0B07);
  static const Color successDark = Color(0xFF4CC79B);

  static const Color disabledDark = Color(0xFF232E2F);
  static const Color onDisabledDark = Color(0xFF66787A);
}
