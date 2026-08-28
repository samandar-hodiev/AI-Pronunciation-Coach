import '../../../core/network/api_client.dart';

/// Bosh ekran endpointi.
class DashboardApi {
  const DashboardApi(this._client);

  final ApiClient _client;

  /// Bitta yig'ma so'rov — ilova bosh ekranni ochish uchun bir nechta
  /// endpointni ketma-ket chaqirmaydi.
  Future<Map<String, dynamic>> get() =>
      _client.get('/api/v1/dashboard', authenticated: true);
}
