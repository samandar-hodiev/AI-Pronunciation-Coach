/// Autentifikatsiya formalarining tekshiruvlari.
///
/// Alohida saqlanadi, chunki ular UI'siz test qilinadi va ikkala forma ham
/// bir xil qoidalardan foydalanadi.
///
/// Bu tekshiruvlar backend tekshiruvining o'rnini bosmaydi — ular faqat
/// keraksiz tarmoq so'rovini oldini oladi va xatoni tezroq ko'rsatadi.
abstract final class AuthValidators {
  /// Backend talab qiladigan eng qisqa parol uzunligi.
  static const int minPasswordLength = 8;

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }
    // Ataylab soddalashtirilgan: yakuniy tekshiruvni backend bajaradi.
    final bool looksValid = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$')
        .hasMatch(email);
    if (!looksValid) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  /// Parol tasdig'i asosiy parolga mos kelishini tekshiradi.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
