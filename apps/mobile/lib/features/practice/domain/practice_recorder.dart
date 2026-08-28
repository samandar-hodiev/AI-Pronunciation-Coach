import 'package:flutter/foundation.dart';

/// Mikrofonga kirish holati.
enum MicrophonePermission {
  /// Ruxsat berilgan.
  granted,

  /// Rad etilgan, lekin qayta so'rash mumkin.
  ///
  /// iOS'da hali so'ralmagan holat ham shu qiymat bilan keladi.
  denied,

  /// Butunlay rad etilgan — faqat Sozlamalar orqali yoqiladi.
  permanentlyDenied,
}

/// Tugallangan yozuv haqidagi ma'lumot.
@immutable
class RecordingFile {
  const RecordingFile({required this.path, required this.sizeBytes});

  final String path;
  final int sizeBytes;

  /// Fayl haqiqatan yozilganmi.
  ///
  /// Bo'sh fayl muvaffaqiyat deb hisoblanmaydi: mikrofon ruxsati yo'q yoki
  /// qurilmada mikrofon ishlamayotgan bo'lsa aynan shunday bo'ladi.
  bool get isUsable => sizeBytes > 0;
}

/// Audio yozib oluvchi.
///
/// Interfeys sifatida saqlanadi, chunki haqiqiy diktofon widget testlarida
/// ishlamaydi — u platforma kanallariga tayanadi. Testlarda boshqariladigan
/// implementatsiya beriladi, ilova kodida esa doim haqiqiysi ishlatiladi.
abstract interface class PracticeRecorder {
  /// Joriy ruxsat holatini qaytaradi (so'ramasdan).
  Future<MicrophonePermission> checkPermission();

  /// Foydalanuvchidan ruxsat so'raydi.
  Future<MicrophonePermission> requestPermission();

  /// Yozib olishni boshlaydi.
  Future<void> start();

  /// Yozib olishni to'xtatadi va fayl haqida ma'lumot qaytaradi.
  Future<RecordingFile?> stop();

  /// Yozuvni bekor qiladi va faylni o'chiradi.
  Future<void> cancel();

  /// Resurslarni bo'shatadi.
  Future<void> dispose();
}
