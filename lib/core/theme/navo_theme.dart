import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/settings/data/app_settings.dart';
import 'app_tokens.dart';

/// Theme-dependent design tokens: colours, corner radii, list density and
/// artwork options. Read with `context.navo`.
@immutable
class NavoTheme extends ThemeExtension<NavoTheme> {
  const NavoTheme({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.divider,
    required this.accent,
    required this.accentDark,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.danger,
    required this.scrim,
    required this.radiusScale,
    required this.densityScale,
    required this.artShape,
    required this.listArtSize,
    required this.showListArtwork,
    required this.animations,
    required this.highContrast,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color divider;
  final Color accent;
  final Color accentDark;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color danger;
  final Color scrim;

  /// Multiplies every corner radius (sharp 0.3, medium 1, round 1.6).
  final double radiusScale;

  /// Multiplies vertical padding in lists (compact 0.6 … spacious 1.5).
  final double densityScale;
  final ArtShape artShape;
  final double listArtSize;
  final bool showListArtwork;
  final AnimationLevel animations;
  final bool highContrast;

  bool get isDark => brightness == Brightness.dark;
  bool get animationsOff => animations == AnimationLevel.off;

  double r(double base) => base * radiusScale;
  BorderRadius radius(double base) => BorderRadius.circular(r(base));
  BorderRadius get cardRadius => radius(Radii.md);
  BorderRadius get tileRadius => radius(Radii.sm);
  BorderRadius get sheetRadius => BorderRadius.vertical(top: Radius.circular(r(Radii.xl)));

  /// Base radius for list artwork (0 for square; circles are clipped separately).
  double get listArtRadius => artShape == ArtShape.square ? 0 : Radii.sm;
  bool get listArtCircle => artShape == ArtShape.circle;

  /// Vertical padding for list rows.
  double get rowPadding => Insets.sm * densityScale;

  List<BoxShadow> accentGlow({double strength = 1}) => [
    BoxShadow(
      color: accent.withValues(alpha: (isDark ? 0.45 : 0.3) * strength),
      blurRadius: 18 * strength,
      offset: const Offset(0, 6),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Palettes
  // ---------------------------------------------------------------------------

  static NavoTheme build({
    required Brightness brightness,
    required bool amoled,
    required Color accent,
    required bool highContrast,
    required AppearanceSettings appearance,
  }) {
    final dark = brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(accent);
    // Keep the accent readable on the chosen background.
    final usable = dark
        ? hsl.withLightness(hsl.lightness.clamp(0.45, 0.72)).toColor()
        : hsl.withLightness(hsl.lightness.clamp(0.32, 0.5)).toColor();
    final usableHsl = HSLColor.fromColor(usable);
    final onAccent = usable.computeLuminance() > 0.55 ? const Color(0xFF16171D) : Colors.white;

    final Color bg, surface, surfaceHigh, divider, t1, t2, t3;
    if (dark && amoled) {
      bg = Colors.black;
      surface = const Color(0xFF0F0F12);
      surfaceHigh = const Color(0xFF1B1B20);
      divider = const Color(0xFF26262C);
    } else if (dark) {
      bg = const Color(0xFF1F2129);
      surface = const Color(0xFF2A2D37);
      surfaceHigh = const Color(0xFF33363F);
      divider = const Color(0xFF353842);
    } else {
      bg = const Color(0xFFF6F6F9);
      surface = Colors.white;
      surfaceHigh = const Color(0xFFECECF2);
      divider = const Color(0xFFE0E1E8);
    }
    if (dark) {
      t1 = Colors.white;
      t2 = highContrast ? const Color(0xFFE2E4EA) : const Color(0xFF9AA0AB);
      t3 = highContrast ? const Color(0xFFC4C7D0) : const Color(0xFF6C717C);
    } else {
      t1 = const Color(0xFF15161B);
      t2 = highContrast ? const Color(0xFF2C2F38) : const Color(0xFF5B606D);
      t3 = highContrast ? const Color(0xFF454956) : const Color(0xFF8B909D);
    }

    final artSize = switch (appearance.artSize) {
      ArtSize.small => 44.0,
      ArtSize.medium => Sizes.songArtwork,
      ArtSize.large => 64.0,
    };

    return NavoTheme(
      brightness: brightness,
      background: bg,
      surface: surface,
      surfaceHigh: surfaceHigh,
      divider: highContrast ? t3 : divider,
      accent: usable,
      accentDark: usableHsl.withLightness(math.max(0, usableHsl.lightness - 0.12)).toColor(),
      onAccent: onAccent,
      textPrimary: t1,
      textSecondary: t2,
      textTertiary: t3,
      danger: dark ? const Color(0xFFFF5A5F) : const Color(0xFFD63031),
      scrim: dark ? const Color(0x99000000) : const Color(0x66000000),
      radiusScale: switch (appearance.corners) {
        CornerStyle.sharp => 0.3,
        CornerStyle.medium => 1,
        CornerStyle.round => 1.6,
      },
      densityScale: switch (appearance.density) {
        ListDensity.compact => 0.6,
        ListDensity.comfortable => 1,
        ListDensity.spacious => 1.5,
      },
      artShape: appearance.artShape,
      listArtSize: artSize,
      showListArtwork: appearance.showListArtwork,
      animations: appearance.animations,
      highContrast: highContrast,
    );
  }

  /// Default dark theme tokens (tests and previews).
  static final fallback = build(
    brightness: Brightness.dark,
    amoled: false,
    accent: const Color(0xFFFF9F1C),
    highContrast: false,
    appearance: const AppearanceSettings(),
  );

  @override
  NavoTheme copyWith({Color? accent}) => accent == null
      ? this
      : NavoTheme(
          brightness: brightness,
          background: background,
          surface: surface,
          surfaceHigh: surfaceHigh,
          divider: divider,
          accent: accent,
          accentDark: accentDark,
          onAccent: onAccent,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          textTertiary: textTertiary,
          danger: danger,
          scrim: scrim,
          radiusScale: radiusScale,
          densityScale: densityScale,
          artShape: artShape,
          listArtSize: listArtSize,
          showListArtwork: showListArtwork,
          animations: animations,
          highContrast: highContrast,
        );

  @override
  NavoTheme lerp(NavoTheme? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => a + (b - a) * t;
    final near = t < 0.5 ? this : other;
    return NavoTheme(
      brightness: near.brightness,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      divider: c(divider, other.divider),
      accent: c(accent, other.accent),
      accentDark: c(accentDark, other.accentDark),
      onAccent: c(onAccent, other.onAccent),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      danger: c(danger, other.danger),
      scrim: c(scrim, other.scrim),
      radiusScale: d(radiusScale, other.radiusScale),
      densityScale: d(densityScale, other.densityScale),
      artShape: near.artShape,
      listArtSize: d(listArtSize, other.listArtSize),
      showListArtwork: near.showListArtwork,
      animations: near.animations,
      highContrast: near.highContrast,
    );
  }
}

extension NavoThemeContext on BuildContext {
  NavoTheme get navo => Theme.of(this).extension<NavoTheme>() ?? NavoTheme.fallback;
}
