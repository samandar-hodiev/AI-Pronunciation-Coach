import 'practice_session.dart';

/// Mashq sessiyasi amallari.
abstract interface class PracticeRepository {
  /// Yangi sessiya yaratadi.
  Future<PracticeSession> createSession();

  /// Sessiyani o'qiydi.
  Future<PracticeSession> getSession(String id);

  /// Yozib olish boshlanganini belgilaydi.
  ///
  /// Davomiylik shu paytdan hisoblanadi.
  Future<PracticeSession> startSession(String id);

  /// Sessiyani yakunlaydi.
  Future<PracticeSession> completeSession(String id);

  /// Sessiyani bekor qiladi.
  Future<PracticeSession> cancelSession(String id);
}
