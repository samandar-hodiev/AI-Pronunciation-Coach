import 'package:flutter/widgets.dart';

/// Bitta onboarding sahifasining mazmuni.
///
/// Kontent widget ichida qattiq yozilmaydi — shu model orqali beriladi.
/// Natijada matnni o'zgartirish yoki sahifa qo'shish uchun UI kodiga tegish
/// shart emas.
///
/// Ataylab oddiy `immutable` klass: bu lokal UI konfiguratsiyasi, shuning
/// uchun repository yoki ma'lumotlar bazasi qatlami yaratilmadi.
@immutable
class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;

  /// Sahifaning vizual belgisi. Dekorativ — ma'noni [title] beradi.
  final IconData icon;
}
