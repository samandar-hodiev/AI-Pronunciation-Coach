import 'package:flutter/material.dart';

/// Ikkilamchi harakat tugmasi.
///
/// Ekranda [PrimaryButton] bilan yonma-yon turadi va asosiy harakatdan
/// ko'ra pastroq urg'uga ega: foni yo'q, faqat brend rangidagi matn.
/// Shu sababli ikkita to'ldirilgan tugma bir-biri bilan diqqat uchun
/// kurashmaydi.
///
/// Uslub `AppTheme` dagi `textButtonTheme` dan keladi — bu yerda rang yoki
/// o'lcham qattiq yozilmaydi.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
