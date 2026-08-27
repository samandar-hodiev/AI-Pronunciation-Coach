/// Backend yoki tarmoq xatosining ilova ichidagi ko'rinishi.
///
/// UI hech qachon `DioException` yoki stack trace ko'rmaydi — barcha xatolar
/// shu turga o'giriladi va [message] to'g'ridan-to'g'ri foydalanuvchiga
/// ko'rsatish uchun mos bo'ladi.
class ApiException implements Exception {
  const ApiException({required this.message, this.code, this.statusCode});

  /// Foydalanuvchiga ko'rsatiladigan matn.
  final String message;

  /// Backend bergan mashina o'qiy oladigan kod (`INVALID_CREDENTIALS` va h.k.).
  ///
  /// Tarmoq xatolarida `null` bo'ladi.
  final String? code;

  final int? statusCode;

  /// Sessiya yaroqsiz — foydalanuvchi qayta kirishi kerak.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
