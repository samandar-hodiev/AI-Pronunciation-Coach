import 'dashboard_data.dart';

/// Bosh ekran ma'lumotlarini oladi.
abstract interface class DashboardRepository {
  /// Joriy foydalanuvchining bosh ekran ma'lumotini qaytaradi.
  Future<DashboardData> getDashboard();
}
