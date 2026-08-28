import '../../../core/network/api_client.dart';

/// Mashq sessiyasi endpointlari.
class PracticeApi {
  const PracticeApi(this._client);

  final ApiClient _client;

  static const String _base = '/api/v1/practice/sessions';

  Future<Map<String, dynamic>> create() =>
      _client.post(_base, authenticated: true);

  Future<Map<String, dynamic>> get(String id) =>
      _client.get('$_base/$id', authenticated: true);

  Future<Map<String, dynamic>> start(String id) =>
      _client.post('$_base/$id/start', authenticated: true);

  Future<Map<String, dynamic>> complete(String id) =>
      _client.post('$_base/$id/complete', authenticated: true);

  Future<Map<String, dynamic>> cancel(String id) =>
      _client.post('$_base/$id/cancel', authenticated: true);
}
