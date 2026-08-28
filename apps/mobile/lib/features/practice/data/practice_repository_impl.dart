import '../../../core/network/api_exception.dart';
import '../domain/practice_repository.dart';
import '../domain/practice_session.dart';
import 'practice_api.dart';

/// [PracticeRepository] ning haqiqiy backend ustidagi implementatsiyasi.
class PracticeRepositoryImpl implements PracticeRepository {
  const PracticeRepositoryImpl(this._api);

  final PracticeApi _api;

  @override
  Future<PracticeSession> createSession() async => _parse(await _api.create());

  @override
  Future<PracticeSession> getSession(String id) async =>
      _parse(await _api.get(id));

  @override
  Future<PracticeSession> startSession(String id) async =>
      _parse(await _api.start(id));

  @override
  Future<PracticeSession> completeSession(String id) async =>
      _parse(await _api.complete(id));

  @override
  Future<PracticeSession> cancelSession(String id) async =>
      _parse(await _api.cancel(id));

  PracticeSession _parse(Map<String, dynamic> json) {
    final Object? data = json['data'];
    if (data is Map<String, dynamic>) {
      final Object? session = data['session'];
      if (session is Map<String, dynamic>) {
        return PracticeSession.fromJson(session);
      }
    }
    throw const ApiException(
      message: 'Something went wrong. Please try again.',
    );
  }
}
