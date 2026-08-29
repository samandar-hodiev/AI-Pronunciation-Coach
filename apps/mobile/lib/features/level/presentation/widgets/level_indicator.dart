import 'package:flutter/material.dart';

/// Ingliz tili darajasini ustunlar bilan ko'rsatadi.
///
/// Ikonka o'rniga ustunlar ishlatilgan, chunki darajalar **tartiblangan**:
/// Beginner'dan Advanced'gacha o'sadi. Ustunlar bu tartibni bir qarashda
/// ko'rsatadi, oddiy ikonka esa ko'rsatmaydi.
///
/// Vizual til brend belgisidagi (BrandMark) to'lqin ustunlariga mos.
class LevelIndicator extends StatelessWidget {
  const LevelIndicator({
    super.key,
    required this.filledCount,
    required this.totalCount,
  });

  /// To'ldirilgan ustunlar soni (daraja tartib raqami).
  final int filledCount;

  /// Umumiy ustunlar soni.
  final int totalCount;

  static const double _barWidth = 3;
  static const double _gap = 2.5;
  static const double _maxHeight = 22;
  static const double _minHeight = 7;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: totalCount * _barWidth + (totalCount - 1) * _gap,
      height: _maxHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < totalCount; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: _gap),
            Container(
              width: _barWidth,
              // Ustunlar bosqichma-bosqich balandlashadi.
              height:
                  _minHeight +
                  (_maxHeight - _minHeight) * (i / (totalCount - 1)),
              decoration: BoxDecoration(
                color: i < filledCount
                    ? colors.onPrimaryContainer
                    : colors.outlineVariant,
                borderRadius: BorderRadius.circular(_barWidth),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
