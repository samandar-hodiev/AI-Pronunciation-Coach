import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/profile_api.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/profile_draft.dart';
import '../../domain/profile_repository.dart';
import '../../domain/profile_state.dart';
import '../../domain/user_profile.dart';

/// Profil repozitoriysi.
///
/// Testlarda `overrideWithValue` orqali almashtiriladi.
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (Ref ref) =>
          ProfileRepositoryImpl(ProfileApi(ref.watch(apiClientProvider))),
    );

/// Sozlash jarayonidagi vaqtinchalik tanlovlar.
final NotifierProvider<ProfileDraftController, ProfileDraft>
profileDraftProvider = NotifierProvider<ProfileDraftController, ProfileDraft>(
  ProfileDraftController.new,
);

/// Maqsad va daraja tanlovlarini yakuniy saqlashgacha ushlab turadi.
class ProfileDraftController extends Notifier<ProfileDraft> {
  @override
  ProfileDraft build() => const ProfileDraft();

  void setGoal(String goalId) => state = state.copyWith(goalId: goalId);

  void setLevel(String levelId) => state = state.copyWith(levelId: levelId);

  void setDailyGoal(int minutes) =>
      state = state.copyWith(dailyGoalMinutes: minutes);

  void clear() => state = const ProfileDraft();
}

/// Foydalanuvchi profilining holati.
final NotifierProvider<ProfileController, ProfileState>
profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

/// Profilni yuklaydi va saqlaydi.
///
/// Autentifikatsiya holatini kuzatadi: foydalanuvchi kirganda profil
/// yuklanadi, chiqqanda holat tozalanadi. Shu sababli ekranlar profilni
/// qo'lda yuklashni so'ramaydi.
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final AuthState auth = ref.watch(authControllerProvider);

    switch (auth) {
      case AuthLoading():
        return const ProfileLoading();
      case Unauthenticated():
        // Chiqilganda oldingi foydalanuvchining ma'lumoti qolib ketmasligi
        // kerak.
        return const ProfileLoading();
      case Authenticated():
        unawaited(_load());
        return const ProfileLoading();
    }
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<void> _load() async {
    try {
      final UserProfile profile = await _repository.getProfile();
      state = ProfileReady(profile);
    } on ApiException catch (e) {
      state = ProfileFailed(e.message);
    } catch (_) {
      state = const ProfileFailed('Something went wrong. Please try again.');
    }
  }

  /// Profilni qaytadan yuklaydi (xatodan keyin qayta urinish uchun).
  Future<void> reload() async {
    state = const ProfileLoading();
    await _load();
  }

  /// Sozlash ma'lumotlarini saqlaydi.
  ///
  /// Xatoni ushlamaydi — uni chaqiruvchi ekran ko'rsatadi.
  Future<void> completeSetup({
    required String name,
    required String pronunciationGoal,
    required String pronunciationLevel,
    required int dailyGoalMinutes,
  }) async {
    final UserProfile profile = await _repository.updateProfile(
      name: name,
      pronunciationGoal: pronunciationGoal,
      pronunciationLevel: pronunciationLevel,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    state = ProfileReady(profile);
    ref.read(profileDraftProvider.notifier).clear();
  }
}
