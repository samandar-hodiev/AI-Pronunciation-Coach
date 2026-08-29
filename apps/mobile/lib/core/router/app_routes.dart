/// Ilovaning barcha route yo'llari.
///
/// Bu yerda **butun** mahsulot oqimi sanab o'tilgan, chunki yo'llar ro'yxati
/// oqimning rasmiy manbasi hisoblanadi. Ammo `app_router.dart` da faqat
/// haqiqatan mavjud ekranlar ro'yxatdan o'tgan — qolganlari keyingi tasklarda
/// bosqichma-bosqich qo'shiladi.
abstract final class AppRoutes {
  // --- Ilova ochilishi ---
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';

  // --- Autentifikatsiya ---
  static const String createAccount = '/create-account';
  static const String signIn = '/sign-in';

  // --- Profil sozlash ---
  static const String goal = '/goal';
  static const String level = '/level';

  /// Sozlashning oxirgi bosqichi: ism va kunlik mashq maqsadi.
  static const String profileSetup = '/profile-setup';

  /// Sozlash tugagan foydalanuvchining ekrani.
  ///
  /// Dashboard yaratilgach, autentifikatsiyadan keyingi manzil o'sha bo'ladi.
  static const String account = '/account';

  /// Bosh ekran — sozlashni tugatgan foydalanuvchining asosiy ekrani.
  static const String home = '/home';

  /// Mashq ekrani.
  static const String practice = '/practice';

  // --- Keyingi tasklarda qo'shiladi ---
  static const String assessmentIntro = '/assessment-intro';
  static const String microphone = '/microphone';
  static const String analysis = '/analysis';
  static const String result = '/result';
  static const String subscriptionIntro = '/subscription-intro';

  /// Faqat tizimga kirgan foydalanuvchi ocha oladigan yo'llar.
  ///
  /// Sessiya yaroqsiz bo'lib qolganda ilova foydalanuvchini shu ro'yxatdagi
  /// ekranlardan chiqaradi.
  ///
  /// Goal va Level ataylab ro'yxatda yo'q: ular autentifikatsiyadan oldin
  /// ochiladi va tanlovlar lokal draft'da turadi.
  static const Set<String> protected = <String>{
    home,
    practice,
    account,
    profileSetup,
  };

  /// Berilgan yo'l autentifikatsiya talab qiladimi.
  static bool isProtected(String location) => protected.contains(location);
}
