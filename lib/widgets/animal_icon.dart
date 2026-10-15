import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';

class AnimalIcon extends StatelessWidget {
  final AnimalType type;
  final double size;

  const AnimalIcon({super.key, required this.type, this.size = 40});

  String get _svg {
    switch (type) {
      case AnimalType.cattle:
        return '''<svg viewBox="0 0 64 64"><path fill="#B77C45" d="M12 23 7 16l3-5 8 7 8-5 17 4 10 11 1 17-7 8H22L15 34Z"/><path fill="#D5A06A" d="m7 16-4-5 2-4 7 6M18 18l-1-8 4-3 3 7"/><path fill="#4E5B32" d="M43 47h4v8h-4zM23 47h4v8h-4z"/></svg>''';
      case AnimalType.poultry:
        return '''<svg viewBox="0 0 64 64"><path fill="#C77743" d="M17 20 11 15l2-6 7 6 6-3 10 9 10 2 2 13-9 13H25L15 39Z"/><path fill="#E7B06A" d="m11 15-4-4 2-5 6 4M21 16l1-8 5 2 1 7"/><path fill="#E7B06A" d="m47 26 9 4-9 4z"/></svg>''';
      case AnimalType.goat:
        return '''<svg viewBox="0 0 64 64"><path fill="#D8C08F" d="M15 20 7 12l2-6 12 11 9-3 9 8 9 12 2 15H24L15 36Z"/><path fill="#F1DEB0" d="M31 17 40 4l7 1-8 12M19 17 15 5l4-3 7 15"/><path fill="#D8C08F" d="m47 35 10 4-7 5"/></svg>''';
      case AnimalType.pig:
        return '''<svg viewBox="0 0 64 64"><path fill="#E6A493" d="m10 18 7-5 13 5 16 1 8 10-4 15-11 7H23L14 39 8 29Z"/><path fill="#F3C0B1" d="m10 18-4-8 12 5 2 5M47 26l10 4-7 5"/><path fill="#D98778" d="M23 48v7h5v-7M43 47v8h5v-8"/></svg>''';
      case AnimalType.sheep:
        return '''<svg viewBox="0 0 64 64"><path fill="#F3E9D1" d="M13 24a9 9 0 0 1 11-10 10 10 0 0 1 17 1 10 10 0 0 1 11 12 9 9 0 0 1 1 13l-8 10H22L14 41a10 10 0 0 1-1-17Z"/><path fill="#FFF8E8" d="M12 22 7 18l3-7 8 3 4 7"/><path fill="#F3E9D1" d="M22 48v7h5v-7M43 48v7h5v-7"/></svg>''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: size, height: size);
  }
}