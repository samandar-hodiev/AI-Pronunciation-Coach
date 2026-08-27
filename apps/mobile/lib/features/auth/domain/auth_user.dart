import 'package:flutter/foundation.dart';

/// Tizimga kirgan foydalanuvchi.
///
/// Parol yoki uning xeshi bu yerda umuman yo'q — backend ham ularni
/// qaytarmaydi.
@immutable
class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  /// Backend javobidan o'qiydi.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);
}
