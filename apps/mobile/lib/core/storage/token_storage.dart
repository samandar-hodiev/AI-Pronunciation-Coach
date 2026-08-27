/// Access tokenni saqlash shartnomasi.
///
/// Repozitoriy aynan shu abstraksiyaga bog'lanadi, konkret omborga emas.
/// Shu sababli saqlash usulini almashtirish (yoki testda xotiradagi ombor
/// berish) qolgan kodga ta'sir qilmaydi.
abstract interface class TokenStorage {
  /// Saqlangan tokenni qaytaradi, yoki `null`.
  Future<String?> read();

  /// Tokenni saqlaydi.
  Future<void> write(String token);

  /// Tokenni o'chiradi (chiqish paytida).
  Future<void> clear();
}
