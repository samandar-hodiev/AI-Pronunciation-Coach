import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/auth_api.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../domain/auth_user.dart';

/// Xavfsiz token ombori.
final Provider<SecureTokenStorage> secureTokenStorageProvider =
    Provider<SecureTokenStorage>((Ref ref) => const SecureTokenStorage());

/// HTTP mijoz.
///
/// Token har bir so'rovdan oldin ombordan o'qiladi, shuning uchun kirish yoki
/// chiqishdan keyin mijozni qayta yaratish shart emas.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final SecureTokenStorage storage = ref.watch(secureTokenStorageProvider);
  return ApiClient(tokenProvider: storage.read);
});

/// Autentifikatsiya repozitoriysi.
///
/// Testlarda `overrideWithValue` orqali almashtiriladi.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepositoryImpl(
        AuthApi(ref.watch(apiClientProvider)),
        ref.watch(secureTokenStorageProvider),
      ),
    );

/// Ilovaning autentifikatsiya holati.
final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Autentifikatsiya holatini boshqaradi.
///
/// Bu yerda UI kodi yo'q va ekranlar bu sinfning ichki ishlashini bilmaydi —
/// ular faqat holatni kuzatadi va metodlarni chaqiradi.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Ilova ochilishi bilan saqlangan sessiyani tiklashga urinamiz.
    unawaited(restoreSession());
    return const AuthLoading();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Saqlangan token orqali sessiyani tiklaydi.
  ///
  /// Xato yuz bersa foydalanuvchi kirmagan deb hisoblanadi — ilova ochilishi
  /// tarmoq muammosi tufayli to'xtab qolmasligi kerak.
  Future<void> restoreSession() async {
    try {
      final AuthUser? user = await _repository.restoreSession();
      state = user == null ? const Unauthenticated() : Authenticated(user);
    } catch (_) {
      state = const Unauthenticated();
    }
  }

  /// Yangi hisob yaratadi.
  ///
  /// Xatoni ushlamaydi — uni chaqiruvchi ekran ko'rsatadi.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final AuthUser user = await _repository.register(
      name: name,
      email: email,
      password: password,
    );
    state = Authenticated(user);
  }

  /// Tizimga kiradi.
  Future<void> signIn({required String email, required String password}) async {
    final AuthUser user = await _repository.signIn(
      email: email,
      password: password,
    );
    state = Authenticated(user);
  }

  /// Sessiyani tugatadi.
  Future<void> signOut() async {
    await _repository.signOut();
    state = const Unauthenticated();
  }
}
