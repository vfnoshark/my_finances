import 'package:flutter/material.dart';

/// Тёмная тема приложения фермы.
///
/// Использование:
/// MaterialApp(
///   theme: Light.theme,
///   darkTheme: Dark.theme,
///   themeMode: ThemeMode.system,
/// )
///
/// Для отдельных цветов и декораций доступны Dark.colors, Dark.radius,
/// Dark.spacing, Dark.cardDecoration и Dark.heroGradient.
abstract final class Dark {
  // Основная палитра — в духе макетов тёмного личного кабинета фермы.
  static const Color background = Color(0xFF10120F);
  static const Color surface = Color(0xFF1C2018);
  static const Color surfaceMuted = Color(0xFF262B20);
  static const Color olive = Color(0xFFB8CF7C);
  static const Color oliveDark = Color(0xFF94A85E);
  static const Color oliveSoft = Color(0xFF8A9A6C);
  static const Color sage = Color(0xFF3A4229);
  static const Color sand = Color(0xFF6F4827);
  static const Color sandDark = Color(0xFF4E331B);
  static const Color peach = Color(0xFFE6AE58);
  static const Color coral = Color(0xFFD97878);
  static const Color text = Color(0xFFF1F0E8);
  static const Color textMuted = Color(0xFF999B8E);
  static const Color outline = Color(0xFF303629);
  static const Color error = Color(0xFFE58585);

  /// Удобный набор цветов для вызова из виджетов.
  static const ColorScheme colors = ColorScheme(
    brightness: Brightness.dark,
    primary: olive,
    onPrimary: Color(0xFF171B12),
    secondary: sand,
    onSecondary: text,
    error: error,
    onError: background,
    surface: surface,
    onSurface: text,
    outline: outline,
  );

  /// Единые скругления для компонентов интерфейса.
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 20;
  static const double radiusXLarge = 28;
  static const BorderRadius radiusSm =
      BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius radiusMd =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius radiusLg =
      BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius radiusXl =
      BorderRadius.all(Radius.circular(radiusXLarge));

  /// Базовые интервалы отступов в пикселях.
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;

  /// Градиент для главных баннеров и сводок.
  /// В тёмной теме — глубокие зелёно-земляные тона.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A3322), Color(0xFF1C2018), Color(0xFF3A2A18)],
  );

  /// Градиент для сводки в карточке кормов.
  static const LinearGradient summaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6F4827), Color(0xFF4A5B2A)],
  );

  /// Тень для карточек и всплывающих поверхностей.
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 18,
      offset: Offset(0, 7),
    ),
  ];

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: radiusLg,
        border: Border.all(color: outline),
      );

  static BoxDecoration get oliveCardDecoration => BoxDecoration(
        color: olive,
        borderRadius: radiusLg,
        boxShadow: softShadow,
      );

  static BoxDecoration get sandCardDecoration => BoxDecoration(
        color: sand,
        borderRadius: radiusLg,
      );

  static BoxDecoration get heroDecoration => BoxDecoration(
        gradient: heroGradient,
        borderRadius: radiusXl,
      );

  static TextTheme get _textTheme {
    const base = TextStyle(
      fontFamily: 'Onest',
      color: text,
      height: 1.35,
    );

    return TextTheme(
      displayLarge: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      headlineLarge: base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineMedium: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.copyWith(fontSize: 16),
      bodyMedium: base.copyWith(fontSize: 14),
      bodySmall: base.copyWith(fontSize: 12, color: textMuted),
      labelLarge: base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData get theme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: outline,
      fontFamily: 'Onest',
    );

    return baseTheme.copyWith(
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Onest',
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: olive, size: 24),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: const BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: oliveSoft, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: olive,
          foregroundColor: const Color(0xFF171B12),
          disabledBackgroundColor: outline,
          disabledForegroundColor: textMuted,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'Onest',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: olive,
          foregroundColor: const Color(0xFF171B12),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'Onest',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: olive,
          textStyle: const TextStyle(
            fontFamily: 'Onest',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: olive,
          side: const BorderSide(color: outline),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: olive,
        foregroundColor: Color(0xFF171B12),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: sage,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Onest',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: olive,
            );
          }
          return const TextStyle(
            fontFamily: 'Onest',
            fontSize: 12,
            color: textMuted,
          );
        }),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: surfaceMuted,
        selectedColor: sage,
        disabledColor: outline,
        labelStyle: const TextStyle(color: text, fontSize: 12),
        secondaryLabelStyle: const TextStyle(
          color: olive,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          side: const BorderSide(color: outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusXl),
        titleTextStyle: _textTheme.titleLarge,
        contentTextStyle: _textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceMuted,
        contentTextStyle: const TextStyle(color: text, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: olive,
        linearTrackColor: sage,
        circularTrackColor: sage,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return olive;
          return surface;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF171B12)),
        side: const BorderSide(color: oliveSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF171B12);
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return olive;
          return outline;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}