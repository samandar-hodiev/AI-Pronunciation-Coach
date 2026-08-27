import 'package:flutter/widgets.dart';

/// Foydalanuvchi tanlashi mumkin bo'lgan ingliz tili darajasi.
///
/// [id] — barqaror identifikator. U UI matnidan mustaqil, shuning uchun
/// sarlavha yoki izoh o'zgarsa ham saqlangan tanlov buzilmaydi. Kelajakda
/// backend'ga aynan shu qiymat yuboriladi.
///
/// [rank] — darajaning tartib raqami (1 dan boshlanadi). U ko'rsatkichdagi
/// to'ldirilgan ustunlar sonini belgilaydi va tartibni ma'lumot darajasida
/// saqlaydi, ro'yxatdagi joylashuvga tayanmaydi.
@immutable
class EnglishLevel {
  const EnglishLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.rank,
  });

  final String id;
  final String title;
  final String description;
  final int rank;
}
