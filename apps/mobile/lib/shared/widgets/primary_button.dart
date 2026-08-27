import 'package:flutter/material.dart';

/// Ilovaning asosiy harakat tugmasi.
///
/// Uslub `AppTheme` dagi `filledButtonTheme` dan keladi — bu yerda rang yoki
/// o'lcham qattiq yozilmaydi. Shu sababli barcha ekranlarda tugmalar bir xil
/// ko'rinadi.
///
/// Semantika [FilledButton] ning o'zidan keladi: tugma sifatida belgilanish,
/// bosish harakati va yoqilgan/o'chirilgan holat. Ustiga qo'shimcha
/// `Semantics` o'ramasi qo'yilmaydi — u tap action'ni o'chirib yuboradi va
/// tugma ekran o'quvchisi uchun ishlamay qoladi.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// Tugma ustidagi matn. Ayni vaqtda ekran o'quvchisi o'qiydigan nom.
  final String label;

  /// Bosilganda chaqiriladi. `null` bo'lsa tugma o'chirilgan holatga o'tadi.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}
