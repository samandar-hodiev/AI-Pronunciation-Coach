import 'package:flutter/foundation.dart';

import 'practice_session.dart';

/// Mashq ekranining holati.
@immutable
sealed class PracticeState {
  const PracticeState();
}

/// Sessiya yaratilmoqda.
final class PracticeInitializing extends PracticeState {
  const PracticeInitializing();
}

/// Mikrofonga ruxsat kerak.
final class PracticePermissionRequired extends PracticeState {
  const PracticePermissionRequired({required this.permanentlyDenied});

  /// `true` bo'lsa ruxsatni faqat Sozlamalar orqali yoqish mumkin.
  final bool permanentlyDenied;

  @override
  bool operator ==(Object other) =>
      other is PracticePermissionRequired &&
      other.permanentlyDenied == permanentlyDenied;

  @override
  int get hashCode => permanentlyDenied.hashCode;
}

/// Yozib olishga tayyor.
final class PracticeReady extends PracticeState {
  const PracticeReady(this.session);

  final PracticeSession session;

  @override
  bool operator ==(Object other) =>
      other is PracticeReady && other.session == session;

  @override
  int get hashCode => session.hashCode;
}

/// Yozib olish davom etmoqda.
final class PracticeRecording extends PracticeState {
  const PracticeRecording({
    required this.session,
    required this.elapsedSeconds,
  });

  final PracticeSession session;
  final int elapsedSeconds;

  @override
  bool operator ==(Object other) =>
      other is PracticeRecording &&
      other.session == session &&
      other.elapsedSeconds == elapsedSeconds;

  @override
  int get hashCode => Object.hash(session, elapsedSeconds);
}

/// Yozuv to'xtatilmoqda va sessiya yakunlanmoqda.
final class PracticeStopping extends PracticeState {
  const PracticeStopping();
}

/// Sessiya yakunlandi.
final class PracticeCompleted extends PracticeState {
  const PracticeCompleted({
    required this.session,
    required this.recordingSaved,
  });

  final PracticeSession session;

  /// Audio fayl haqiqatan yaratilganmi.
  ///
  /// Simulyatorda mikrofon bo'lmasa fayl bo'sh bo'lishi mumkin —
  /// bu holat foydalanuvchidan yashirilmaydi.
  final bool recordingSaved;

  @override
  bool operator ==(Object other) =>
      other is PracticeCompleted &&
      other.session == session &&
      other.recordingSaved == recordingSaved;

  @override
  int get hashCode => Object.hash(session, recordingSaved);
}

/// Xatolik yuz berdi.
final class PracticeFailed extends PracticeState {
  const PracticeFailed(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is PracticeFailed && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
