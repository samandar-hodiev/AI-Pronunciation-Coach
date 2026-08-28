import '../../../core/network/api_exception.dart';
import '../domain/dashboard_data.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_api.dart';

/// [DashboardRepository] ning haqiqiy backend ustidagi implementatsiyasi.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._api);

  final DashboardApi _api;

  @override
  Future<DashboardData> getDashboard() async {
    final Map<String, dynamic> json = await _api.get();

    final Object? data = json['data'];
    if (data is Map<String, dynamic>) {
      final Object? dashboard = data['dashboard'];
      if (dashboard is Map<String, dynamic>) {
        return DashboardData.fromJson(dashboard);
      }
    }

    throw const ApiException(
      message: 'Something went wrong. Please try again.',
    );
  }
}
