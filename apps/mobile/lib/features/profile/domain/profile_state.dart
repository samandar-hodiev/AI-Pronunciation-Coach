import 'package:flutter/foundation.dart';

import 'user_profile.dart';

/// Profil yuklanish holati.
///
/// [ProfileLoading] alohida holat: profil yuklanayotganda foydalanuvchini
/// sozlagan yoki sozlamagan deb hisoblab bo'lmaydi, shuning uchun bu paytda
/// yo'naltirish ham qilinmaydi.
@immutable
sealed class ProfileState {
  const ProfileState();
}

/// Profil hali yuklanmagan yoki yuklanmoqda.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profil yuklandi.
final class ProfileReady extends ProfileState {
  const ProfileReady(this.profile);

  final UserProfile profile;

  @override
  bool operator ==(Object other) =>
      other is ProfileReady && other.profile == profile;

  @override
  int get hashCode => profile.hashCode;
}

/// Profilni yuklab bo'lmadi.
final class ProfileFailed extends ProfileState {
  const ProfileFailed(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is ProfileFailed && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
