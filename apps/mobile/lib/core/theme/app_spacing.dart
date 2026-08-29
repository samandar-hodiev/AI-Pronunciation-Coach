/// Bo'shliqlar uchun yagona shkala.
///
/// Widgetlar ichida tasodifiy raqamlar yozilmasligi uchun barcha padding va
/// oraliqlar shu qiymatlardan olinadi. Shkala 4 ga karrali — shu sababli
/// ekranlar bir xil ritmga ega bo'ladi.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double mdl = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;

  /// Eng katta oraliq — faqat ekran bo'limlarini ajratish uchun.
  static const double section = 64;
}
