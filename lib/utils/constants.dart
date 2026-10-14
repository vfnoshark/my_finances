import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppSizes {
  /// Максимальная ширина контента на широких экранах.
  /// На десктопе и планшете приложение не растягивается шире этого значения.
  static const double maxContentWidth = 480;

  /// Высота основных кнопок.
  static const double buttonHeight = 52;

  /// Размер иконок.
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
}

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  static const Color divider = Color(0xFFE0E0E0);
}