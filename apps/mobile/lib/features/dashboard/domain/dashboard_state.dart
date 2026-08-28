import 'package:flutter/foundation.dart';

import 'dashboard_data.dart';

/// Bosh ekran holati.
@immutable
sealed class DashboardState {
  const DashboardState();
}

/// Ma'lumot yuklanmoqda.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Ma'lumot yuklandi.
final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.data);

  final DashboardData data;

  @override
  bool operator ==(Object other) =>
      other is DashboardLoaded && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

/// Ma'lumotni yuklab bo'lmadi.
final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is DashboardError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
