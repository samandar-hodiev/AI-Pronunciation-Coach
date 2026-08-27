import 'auth_user.dart';

/// Autentifikatsiya amallari.
///
/// UI shu shartnomaga bog'lanadi, HTTP yoki saqlash tafsilotlariga emas.
/// Shu sababli testlarda soxta implementatsiya berish mumkin, ilova kodida
/// esa faqat haqiqiy backend ishlatiladi.
abstract interface class AuthRepository {
  /// Yangi hisob yaratadi va sessiyani saqlaydi.
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  });

  /// Tizimga kiradi va sessiyani saqlaydi.
  Future<AuthUser> signIn({required String email, required String password});

  /// Saqlangan token orqali joriy foydalanuvchini qaytaradi.
  ///
  /// Token yo'q yoki yaroqsiz bo'lsa `null` qaytaradi.
  Future<AuthUser?> restoreSession();

  /// Sessiyani tugatadi va tokenni o'chiradi.
  Future<void> signOut();
}
