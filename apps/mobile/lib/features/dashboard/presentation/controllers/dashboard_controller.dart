import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/dashboard_api.dart';
import '../../data/dashboard_repository_impl.dart';
import '../../domain/dashboard_data.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/dashboard_state.dart';

/// Bosh ekran repozitoriysi.
///
/// Testlarda `overrideWithValue` orqali almashtiriladi.
final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>(
      (Ref ref) =>
          DashboardRepositoryImpl(DashboardApi(ref.watch(apiClientProvider))),
    );

/// Bosh ekran holati.
final NotifierProvider<DashboardController, DashboardState>
dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );

/// Bosh ekran ma'lumotini yuklaydi.
///
/// Autentifikatsiya holatini kuzatadi: foydalanuvchi chiqsa oldingi
/// ma'lumot qolib ketmaydi.
class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    final AuthState auth = ref.watch(authControllerProvider);

    if (auth is Authenticated) {
      unawaited(_load());
    }
    return const DashboardLoading();
  }

  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  Future<void> _load() async {
    try {
      final DashboardData data = await _repository.getDashboard();
      state = DashboardLoaded(data);
    } on ApiException catch (e) {
      // 401 bo'lsa sessiya yaroqsiz — auth qatlami buni o'zi hal qiladi va
      // foydalanuvchini kirish oqimiga qaytaradi. Bosh ekran o'zicha login
      // ekranini ochmaydi.
      if (e.isUnauthorized) {
        await ref.read(authControllerProvider.notifier).signOut();
        return;
      }
      state = DashboardError(e.message);
    } catch (_) {
      state = const DashboardError('Something went wrong. Please try again.');
    }
  }

  /// Ma'lumotni qaytadan yuklaydi (qayta urinish va pull-to-refresh uchun).
  Future<void> refresh() async {
    state = const DashboardLoading();
    await _load();
  }
}
