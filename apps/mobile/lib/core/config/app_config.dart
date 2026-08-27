/// Ilovaning muhitga bog'liq sozlamalari.
///
/// Qiymatlar `--dart-define` orqali beriladi, shuning uchun build vaqtida
/// o'zgartirish mumkin va kodga qattiq yozilmaydi.
abstract final class AppConfig {
  /// Backend API manzili.
  ///
  /// Standart qiymat lokal ishlab chiqish uchun. iOS simulyatori host
  /// mashinaning `localhost` iga to'g'ridan-to'g'ri kira oladi.
  ///
  /// Boshqa manzil uchun:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
