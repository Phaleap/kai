import 'package:flutter/material.dart';

/// Design tokens from the mockups canvas, one set of names for both themes.
class CoachColors extends ThemeExtension<CoachColors> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color onSurface;
  final Color muted;
  final Color outline;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color accentText;
  final Color success;
  final Color onSuccess;
  final Color gold;
  final Color cardBorder;

  const CoachColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.onSurface,
    required this.muted,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.success,
    required this.onSuccess,
    required this.gold,
    required this.cardBorder,
  });

  static const light = CoachColors(
    background: Color(0xFFF6F5F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDE9E3),
    onSurface: Color(0xFF141414),
    muted: Color(0xFF6B6864),
    outline: Color(0xFFE2DDD5),
    primary: Color(0xFF141414),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFC24520),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFFA63A19),
    success: Color(0xFF16A34A),
    onSuccess: Color(0xFFFFFFFF),
    gold: Color(0xFFD97706),
    cardBorder: Color(0xFFE9E5DE),
  );

  static const dark = CoachColors(
    background: Color(0xFF0D0E10),
    surface: Color(0xFF17181B),
    surfaceAlt: Color(0xFF23252A),
    onSurface: Color(0xFFF4F2EF),
    muted: Color(0xFFA09D97),
    outline: Color(0xFF2C2E35),
    primary: Color(0xFFF4F2EF),
    onPrimary: Color(0xFF111111),
    accent: Color(0xFFFF7A52),
    onAccent: Color(0xFF141414),
    accentText: Color(0xFFFF8A66),
    success: Color(0xFF22C55E),
    onSuccess: Color(0xFF0D1810),
    gold: Color(0xFFFBBF24),
    cardBorder: Color(0xFF272A32),
  );

  @override
  CoachColors copyWith() => this;

  @override
  CoachColors lerp(ThemeExtension<CoachColors>? other, double t) {
    if (other is! CoachColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CoachColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      onSurface: l(onSurface, other.onSurface),
      muted: l(muted, other.muted),
      outline: l(outline, other.outline),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentText: l(accentText, other.accentText),
      success: l(success, other.success),
      onSuccess: l(onSuccess, other.onSuccess),
      gold: l(gold, other.gold),
      cardBorder: l(cardBorder, other.cardBorder),
    );
  }
}

/// Radii and spacing from the tokens board.
class Radii {
  static const double card = 28;
  static const double bubble = 22;
  static const double small = 18;
  static const double pill = 999;
}

class Space {
  static const double gutter = 20;
  static const double cardPadding = 18;
  static const double cardGap = 12;
}

/// Short way to read the tokens: `context.c.accent`.
extension CoachThemeContext on BuildContext {
  CoachColors get c => Theme.of(this).extension<CoachColors>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark
      ? CoachColors.dark
      : CoachColors.light;
  final base = ThemeData(useMaterial3: true, brightness: brightness);
  final text = base.textTheme.apply(
    bodyColor: c.onSurface,
    displayColor: c.onSurface,
  );

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: c.accent,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          secondary: c.accent,
          onSecondary: c.onAccent,
          surface: c.surface,
          onSurface: c.onSurface,
          outline: c.outline,
        ),
    textTheme: text.copyWith(
      // displayNumber: weight and reps
      displayLarge: text.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        height: 1,
      ),
      // streakNumber
      displayMedium: text.displayMedium?.copyWith(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.3,
        height: 1,
      ),
      // title
      headlineLarge: text.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      // headline
      headlineMedium: text.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
      ),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      labelLarge: text.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: text.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      // overline: card labels
      labelSmall: text.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: c.muted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    extensions: [c],
  );
}
