import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:record/record.dart';

import '../domain/practice_recorder.dart';

/// Qurilmaning mikrofoni orqali yozib oluvchi.
///
/// Fayl ilovaning hujjatlar katalogida saqlanadi — repozitoriy ichiga
/// yozilmaydi va git'ga tushmaydi.
class DevicePracticeRecorder implements PracticeRecorder {
  DevicePracticeRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  /// Joriy yozuv fayli yo'li.
  String? _currentPath;

  /// Talaffuz tahlili uchun siqilmagan format afzal: siqish fonemalarni
  /// ajratishga xalaqit berishi mumkin.
  static const RecordConfig _config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  @override
  Future<MicrophonePermission> checkPermission() async {
    return _map(await ph.Permission.microphone.status);
  }

  @override
  Future<MicrophonePermission> requestPermission() async {
    return _map(await ph.Permission.microphone.request());
  }

  @override
  Future<void> start() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path =
        '${directory.path}/practice_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(_config, path: path);
    _currentPath = path;
  }

  @override
  Future<RecordingFile?> stop() async {
    final String? path = await _recorder.stop();
    _currentPath = null;

    if (path == null) return null;

    final File file = File(path);
    if (!file.existsSync()) return null;

    return RecordingFile(path: path, sizeBytes: await file.length());
  }

  @override
  Future<void> cancel() async {
    // Yozuvni to'xtatamiz va faylni o'chiramiz — bekor qilingan mashqning
    // audiosi qurilmada qolib ketmasligi kerak.
    final String? path = await _recorder.stop().catchError((_) => null);
    final String? target = path ?? _currentPath;
    _currentPath = null;

    if (target == null) return;
    final File file = File(target);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> dispose() => _recorder.dispose();

  MicrophonePermission _map(ph.PermissionStatus status) {
    return switch (status) {
      ph.PermissionStatus.granted ||
      ph.PermissionStatus.limited ||
      ph.PermissionStatus.provisional => MicrophonePermission.granted,
      ph.PermissionStatus.permanentlyDenied ||
      ph.PermissionStatus.restricted => MicrophonePermission.permanentlyDenied,
      ph.PermissionStatus.denied => MicrophonePermission.denied,
    };
  }
}
