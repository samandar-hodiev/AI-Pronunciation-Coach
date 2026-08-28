import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/device_practice_recorder.dart';
import '../../data/practice_api.dart';
import '../../data/practice_repository_impl.dart';
import '../../domain/practice_recorder.dart';
import '../../domain/practice_repository.dart';
import '../../domain/practice_session.dart';
import '../../domain/practice_state.dart';

/// Mashq repozitoriysi.
final Provider<PracticeRepository> practiceRepositoryProvider =
    Provider<PracticeRepository>(
      (Ref ref) =>
          PracticeRepositoryImpl(PracticeApi(ref.watch(apiClientProvider))),
    );

/// Audio yozib oluvchi.
///
/// Testlarda `overrideWithValue` orqali almashtiriladi — haqiqiy diktofon
/// platforma kanallariga tayanadi va widget testida ishlamaydi.
final Provider<PracticeRecorder> practiceRecorderProvider =
    Provider<PracticeRecorder>((Ref ref) {
      final DevicePracticeRecorder recorder = DevicePracticeRecorder();
      ref.onDispose(recorder.dispose);
      return recorder;
    });

/// Mashq ekranining holati.
final NotifierProvider<PracticeController, PracticeState>
practiceControllerProvider =
    NotifierProvider<PracticeController, PracticeState>(PracticeController.new);

/// Mashq sessiyasi va yozib olish jarayonini boshqaradi.
class PracticeController extends Notifier<PracticeState> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  /// Yozuvning eng uzun davomiyligi. Backenddagi chegara bilan bir xil.
  static const int maxRecordingSeconds = 60;

  @override
  PracticeState build() {
    ref.onDispose(_stopTimer);
    unawaited(initialize());
    return const PracticeInitializing();
  }

  PracticeRepository get _repository => ref.read(practiceRepositoryProvider);
  PracticeRecorder get _recorder => ref.read(practiceRecorderProvider);

  /// Sessiya yaratadi va ruxsatni tekshiradi.
  Future<void> initialize() async {
    state = const PracticeInitializing();

    final MicrophonePermission permission = await _recorder.checkPermission();
    if (permission != MicrophonePermission.granted) {
      state = PracticePermissionRequired(
        permanentlyDenied: permission == MicrophonePermission.permanentlyDenied,
      );
      return;
    }

    await _createSession();
  }

  /// Mikrofonga ruxsat so'raydi.
  Future<void> requestPermission() async {
    final MicrophonePermission permission = await _recorder.requestPermission();

    if (permission != MicrophonePermission.granted) {
      state = PracticePermissionRequired(
        permanentlyDenied: permission == MicrophonePermission.permanentlyDenied,
      );
      return;
    }

    state = const PracticeInitializing();
    await _createSession();
  }

  Future<void> _createSession() async {
    try {
      state = PracticeReady(await _repository.createSession());
    } on ApiException catch (e) {
      state = PracticeFailed(e.message);
    } catch (_) {
      state = const PracticeFailed('Something went wrong. Please try again.');
    }
  }

  /// Yozib olishni boshlaydi.
  ///
  /// Avval serverda sessiya `recording` holatiga o'tkaziladi: davomiylik
  /// server vaqtidan hisoblanadi. So'rov muvaffaqiyatsiz bo'lsa yozib olish
  /// umuman boshlanmaydi — serverda izsiz yozuv qolmasligi uchun.
  Future<void> startRecording() async {
    final PracticeState current = state;
    if (current is! PracticeReady) return;

    try {
      final PracticeSession session = await _repository.startSession(
        current.session.id,
      );
      await _recorder.start();

      _elapsedSeconds = 0;
      state = PracticeRecording(session: session, elapsedSeconds: 0);
      _startTimer();
    } on ApiException catch (e) {
      state = PracticeFailed(e.message);
    } catch (_) {
      state = const PracticeFailed(
        'Recording could not be started. Please try again.',
      );
    }
  }

  /// Yozib olishni to'xtatadi va sessiyani yakunlaydi.
  Future<void> stopRecording() async {
    final PracticeState current = state;
    if (current is! PracticeRecording) return;

    _stopTimer();
    state = const PracticeStopping();

    try {
      final RecordingFile? file = await _recorder.stop();
      final PracticeSession session = await _repository.completeSession(
        current.session.id,
      );

      state = PracticeCompleted(
        session: session,
        // Bo'sh fayl muvaffaqiyat deb hisoblanmaydi.
        recordingSaved: file?.isUsable ?? false,
      );
    } on ApiException catch (e) {
      state = PracticeFailed(e.message);
    } catch (_) {
      state = const PracticeFailed(
        'Your practice could not be saved. Please try again.',
      );
    }
  }

  /// Mashqni bekor qiladi va yozuvni o'chiradi.
  Future<void> cancel() async {
    final PracticeState current = state;
    _stopTimer();

    // Yozuv davom etayotgan bo'lsa avval uni to'xtatib, faylni o'chiramiz.
    if (current is PracticeRecording) {
      await _recorder.cancel();
    }

    final String? sessionID = switch (current) {
      PracticeReady(:final session) => session.id,
      PracticeRecording(:final session) => session.id,
      _ => null,
    };

    if (sessionID == null) return;

    try {
      await _repository.cancelSession(sessionID);
    } catch (_) {
      // Bekor qilish serverda muvaffaqiyatsiz bo'lsa ham foydalanuvchini
      // ushlab turishning ma'nosi yo'q — sessiya baribir tugallanmagan
      // holatda qoladi.
    }
  }

  /// Xatodan keyin qayta urinish.
  Future<void> retry() => initialize();

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final PracticeState current = state;
      if (current is! PracticeRecording) {
        _stopTimer();
        return;
      }

      _elapsedSeconds++;
      state = PracticeRecording(
        session: current.session,
        elapsedSeconds: _elapsedSeconds,
      );

      // Cheksiz yozib olishga yo'l qo'yilmaydi.
      if (_elapsedSeconds >= maxRecordingSeconds) {
        unawaited(stopRecording());
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
