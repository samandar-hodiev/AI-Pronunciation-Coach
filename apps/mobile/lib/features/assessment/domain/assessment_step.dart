import 'package:flutter/widgets.dart';

/// Talaffuz baholashining bitta bosqichi tushuntirilishi.
///
/// [id] — barqaror identifikator, UI matnidan mustaqil.
/// [order] — bosqich tartib raqami (1 dan boshlanadi). U ekranda ko'rsatiladi,
/// chunki bosqichlar ketma-ketligi foydalanuvchi uchun muhim ma'lumot.
@immutable
class AssessmentStep {
  const AssessmentStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
  });

  final String id;
  final int order;
  final String title;
  final String description;
}
