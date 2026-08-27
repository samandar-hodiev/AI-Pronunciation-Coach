import 'package:flutter/widgets.dart';

/// Foydalanuvchi tanlashi mumkin bo'lgan bitta talaffuz maqsadi.
///
/// [id] — barqaror identifikator. U UI matnidan mustaqil, shuning uchun
/// sarlavha yoki izoh o'zgarsa ham saqlangan tanlov buzilmaydi. Kelajakda
/// backend'ga aynan shu qiymat yuboriladi.
@immutable
class GoalOption {
  const GoalOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;

  /// Kartaning chap tomonidagi ikonka. Dekorativ — ma'noni [title] beradi.
  final IconData icon;
}
