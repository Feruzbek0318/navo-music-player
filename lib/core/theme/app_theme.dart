import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/settings/data/app_settings.dart';
import 'app_tokens.dart';
import 'navo_theme.dart';

/// Builds [ThemeData] from the user's appearance settings.
abstract final class AppTheme {
  static String _family(AppFont font) => switch (font) {
    AppFont.urbanist => 'Urbanist',
    AppFont.manrope => 'Manrope',
    AppFont.nunito => 'Nunito',
    AppFont.montserrat => 'Montserrat',
  };

  /// Urbanist has no Cyrillic glyphs, so Russian falls back to Manrope.
  static String fontFamilyFor(Locale locale, AppFont font) =>
      locale.languageCode == 'ru' && font == AppFont.urbanist ? 'Manrope' : _family(font);

  static ThemeData build({
    required Locale locale,
    required Brightness brightness,
    required bool amoled,
    required Color accent,
    required AppearanceSettings appearance,
    required bool highContrast,
  }) {
    final t = NavoTheme.build(
      brightness: brightness,
      amoled: amoled,
      accent: accent,
      highContrast: highContrast,
      appearance: appearance,
    );
    final family = fontFamilyFor(locale, appearance.font);
    final fallback = const ['Manrope', 'Urbanist'].where((f) => f != family).toList();
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.accent,
      onSecondary: t.onAccent,
      surface: t.background,
      onSurface: t.textPrimary,
      onSurfaceVariant: t.textSecondary,
      surfaceContainerLowest: t.background,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surface,
      surfaceContainerHigh: t.surfaceHigh,
      surfaceContainerHighest: t.surfaceHigh,
      outline: t.divider,
      outlineVariant: t.divider,
      error: t.danger,
      onError: Colors.white,
    );

    final text = _textTheme(family, fallback, t);
    final card = t.cardRadius;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [t],
      scaffoldBackgroundColor: t.background,
      canvasColor: t.background,
      fontFamily: family,
      fontFamilyFallback: fallback,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: DividerThemeData(color: t.divider, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: t.textPrimary, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: t.background,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.accent,
        unselectedLabelColor: t.textSecondary,
        labelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: t.accent, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
        dividerColor: t.divider,
        tabAlignment: TabAlignment.start,
        overlayColor: WidgetStatePropertyAll(t.accent.withValues(alpha: 0.08)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        modalBackgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: t.sheetRadius),
        showDragHandle: true,
        dragHandleColor: t.textTertiary,
        dragHandleSize: const Size(36, 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: t.radius(Radii.lg)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: t.textSecondary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: card),
        textStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? t.surfaceHigh : const Color(0xFF2A2D37),
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: t.accent,
        shape: RoundedRectangleBorder(borderRadius: card),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        hintStyle: text.bodyMedium?.copyWith(color: t.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
        border: OutlineInputBorder(
          borderRadius: card,
          borderSide: BorderSide(color: t.accent.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: card,
          borderSide: BorderSide(color: t.accent.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: card,
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.surfaceHigh,
        thumbColor: t.accent,
        overlayColor: t.accent.withValues(alpha: 0.16),
        valueIndicatorColor: t.accent,
        valueIndicatorTextStyle: text.labelMedium?.copyWith(color: t.onAccent),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onAccent : t.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.accent : t.surfaceHigh),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.transparent : t.divider,
        ),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStatePropertyAll(t.accent)),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.accent : null),
        checkColor: WidgetStatePropertyAll(t.onAccent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        selectedColor: t.accent.withValues(alpha: 0.2),
        side: BorderSide(color: t.divider),
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: t.radius(Radii.pill)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: t.accent, textStyle: text.labelLarge),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.onAccent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textPrimary,
        textColor: t.textPrimary,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        contentPadding: Insets.pagePadding,
        minVerticalPadding: 4 + 4 * t.densityScale,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.accent),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: appearance.animations == AnimationLevel.off
              ? const _NoTransitionsBuilder()
              : const FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(String family, List<String> fallback, NavoTheme t) {
    TextStyle s(double size, FontWeight weight, {Color? color, double? height}) => TextStyle(
      fontFamily: family,
      fontFamilyFallback: fallback,
      fontSize: size,
      fontWeight: weight,
      color: color ?? t.textPrimary,
      height: height,
      letterSpacing: 0,
    );

    return TextTheme(
      displaySmall: s(30, FontWeight.w700, height: 1.25),
      headlineMedium: s(26, FontWeight.w700, height: 1.3),
      headlineSmall: s(24, FontWeight.w700, height: 1.3),
      titleLarge: s(20, FontWeight.w700),
      titleMedium: s(17, FontWeight.w700),
      titleSmall: s(15, FontWeight.w600),
      bodyLarge: s(16, FontWeight.w600),
      bodyMedium: s(14, FontWeight.w500),
      bodySmall: s(12, FontWeight.w500, color: t.textSecondary),
      labelLarge: s(15, FontWeight.w600),
      labelMedium: s(13, FontWeight.w600),
      labelSmall: s(11, FontWeight.w500, color: t.textSecondary),
    );
  }

  /// Default dark theme (tests and previews).
  static ThemeData dark(Locale locale) => build(
    locale: locale,
    brightness: Brightness.dark,
    amoled: false,
    accent: const Color(0xFFFF9F1C),
    appearance: const AppearanceSettings(),
    highContrast: false,
  );
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
