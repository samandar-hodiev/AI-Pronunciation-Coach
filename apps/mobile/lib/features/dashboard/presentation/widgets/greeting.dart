/// Kun vaqtiga qarab salomlashish matnini beradi.
///
/// Alohida funksiya sifatida saqlanadi, chunki uni UI'siz test qilish
/// mumkin va uchala holat ham aniq tekshiriladi.
String greetingFor(DateTime time, String? name) {
  final String part = switch (time.hour) {
    >= 5 && < 12 => 'Good morning',
    >= 12 && < 18 => 'Good afternoon',
    _ => 'Good evening',
  };

  final String trimmed = name?.trim() ?? '';
  // Ism bo'lmasa salomlashish baribir tabiiy o'qilishi kerak.
  if (trimmed.isEmpty) return 'Welcome back';

  return '$part, $trimmed';
}

/// Ism bosh harflaridan avatar matnini yasaydi.
///
/// Tashqi rasm yuklanmaydi.
String initialsFor(String? name) {
  final List<String> parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();

  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

  return parts.first.substring(0, 1).toUpperCase() +
      parts[1].substring(0, 1).toUpperCase();
}
