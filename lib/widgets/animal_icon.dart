import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';

class AnimalIcon extends StatelessWidget {
  final AnimalType type;
  final double size;

  const AnimalIcon({super.key, required this.type, this.size = 40});

  /// Путь к SVG-файлу для каждого типа животного.
  String get _asset {
    switch (type) {
      case AnimalType.cattle:
        return 'assets/svgs/cow.svg';
      case AnimalType.sheep:
        return 'assets/svgs/sheep.svg';
      case AnimalType.goat:
        return 'assets/svgs/goat.svg';
      case AnimalType.pig:
        return 'assets/svgs/pig.svg';
      case AnimalType.poultry:
        return 'assets/svgs/chicken.svg';
    }
  }

 @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final icon = SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // В тёмной теме накладываем чёрный слой на 25% прозрачности.
    // Это затемняет только непрозрачные части SVG, не трогая прозрачные.
    if (!isDark) return icon;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.25),
        BlendMode.srcATop,
      ),
      child: icon,
    );
  }
}