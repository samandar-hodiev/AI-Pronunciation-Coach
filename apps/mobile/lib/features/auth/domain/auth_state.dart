import 'package:flutter/foundation.dart';

import 'auth_user.dart';

/// Ilovaning autentifikatsiya holati.
///
/// Uchta holat ataylab aniq ajratilgan: ilova ochilganda sessiya tiklanayotgan
/// paytda [AuthLoading] bo'ladi va bu vaqtda foydalanuvchini na kirgan, na
/// chiqqan deb hisoblash mumkin emas.
@immutable
sealed class AuthState {
  const AuthState();
}

/// Sessiya hali tekshirilmoqda.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Foydalanuvchi tizimga kirgan.
final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AuthUser user;

  @override
  bool operator ==(Object other) =>
      other is Authenticated && other.user == user;

  @override
  int get hashCode => user.hashCode;
}

/// Foydalanuvchi tizimga kirmagan.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}
