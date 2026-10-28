import 'package:flutter/material.dart';

/// Colour and type tokens from docs/04-ekrany-i-oprawa.md §4. Every colour in
/// the UI comes from here so the look can be re-tuned in one place.
abstract final class Palette {
  static const bgTop = Color(0xFFFFD36E);
  static const bgBottom = Color(0xFFFF8A5B);
  static const dial = Color(0xFFFFFFFF);
  static const outline = Color(0xFF2B2D42);
  static const perfect = Color(0xFFFFC300);
  static const perfectDeep = Color(0xFFFF6F00);
  static const great = Color(0xFF2EC4B6);
  static const good = Color(0xFF6C9BFF);
  static const miss = Color(0xFF8D99AE);

  /// Darker grey for miss labels drawn over the white dial.
  static const missText = Color(0xFF5C6378);
  static const accent = Color(0xFFFF3D7F);
  static const neonCyan = Color(0xFF00F5FF);
  static const neonMagenta = Color(0xFFFF00E5);
}

abstract final class Fonts {
  /// Headings, stopwatch digits and numbers.
  static const display = 'PaytoneOne';

  /// Body text.
  static const body = 'Nunito';
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: Fonts.body,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.accent,
      primary: Palette.accent,
      surface: Palette.dial,
      onSurface: Palette.outline,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Palette.outline,
      displayColor: Palette.outline,
    ),
  );
}

/// The warm gradient behind every screen.
const backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Palette.bgTop, Palette.bgBottom],
);
