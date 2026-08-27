/// Ilovaning barcha route yo'llari.
///
/// Bu yerda **butun** first-launch oqimi sanab o'tilgan, chunki yo'llar
/// ro'yxati mahsulot oqimining rasmiy manbasi hisoblanadi. Ammo hozircha
/// [splash] va [welcome] gina haqiqiy ekran sifatida ro'yxatdan o'tgan
/// (`app_router.dart` ga qarang). Qolganlari keyingi tasklarda bosqichma-bosqich
/// qo'shiladi — ularni oldindan bo'sh ekran bilan to'ldirish kerak emas.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // --- Keyingi tasklarda qo'shiladi ---
  static const String onboarding = '/onboarding';

  // --- Autentifikatsiya ---
  static const String createAccount = '/create-account';
  static const String signIn = '/sign-in';

  /// Tizimga kirgan foydalanuvchining birinchi ekrani.
  static const String account = '/account';

  static const String goal = '/goal';
  static const String level = '/level';
  static const String assessmentIntro = '/assessment-intro';
  static const String microphone = '/microphone';
  static const String practice = '/practice';
  static const String analysis = '/analysis';
  static const String result = '/result';
  static const String profileSetup = '/profile-setup';
  static const String subscriptionIntro = '/subscription-intro';
  static const String home = '/home';
}
