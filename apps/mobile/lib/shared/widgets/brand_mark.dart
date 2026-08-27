import 'package:flutter/material.dart';

/// AI Pronunciation Coach brend belgisi.
///
/// Vaqtinchalik, to'liq vektor asosidagi treatment: yumaloq kvadrat ichida
/// nutq to'lqinini eslatuvchi to'rtta ustun. Rasm asseti ishlatilmaydi —
/// ilova ochilishini sekinlashtirmaydi va hech qanday mualliflik huquqi bilan
/// himoyalangan material yuklab olinmaydi.
///
/// Splash'dan tashqari Home va boshqa ekranlarda ham qayta ishlatish uchun
/// [size] parametri orqali moslashtiriladi.
///
/// Belgi dekorativ, shuning uchun semantik daraxtdan chiqarib tashlangan:
/// uning ma'nosini yonidagi ilova nomi allaqachon beradi.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88});

  /// Belgining tomoni (kvadrat).
  final double size;

  /// To'lqin ustunlarining nisbiy balandliklari.
  static const List<double> _barHeightFactors = <double>[0.34, 0.62, 0.46, 0.24];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Ichki o'lchamlar tomonga nisbatan hisoblanadi, shuning uchun belgi
    // istalgan o'lchamda mutanosib qoladi.
    final double barWidth = size * 0.085;
    final double gap = size * 0.075;
    final double radius = size * 0.28;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < _barHeightFactors.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: gap),
                _WaveBar(
                  width: barWidth,
                  height: size * _barHeightFactors[i],
                  color: colors.onPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Brend belgisidagi bitta to'lqin ustuni.
class _WaveBar extends StatelessWidget {
  const _WaveBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}
