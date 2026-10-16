import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'features/settings/state/settings_providers.dart';
import 'features/settings/state/theme_providers.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

class NavoApp extends ConsumerStatefulWidget {
  const NavoApp({super.key});

  @override
  ConsumerState<NavoApp> createState() => _NavoAppState();
}

class _NavoAppState extends ConsumerState<NavoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(platformBrightnessProvider.notifier).set(WidgetsBinding.instance.platformDispatcher.platformBrightness);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't lose a just-changed setting if the app is killed in the background.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      ref.read(settingsProvider.notifier).flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(localeProvider);
    final locale = resolveLocale(selected, WidgetsBinding.instance.platformDispatcher.locales);
    final appearance = ref.watch(appearanceProvider);
    final resolved = ref.watch(resolvedThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final highContrast = ref.watch(accessibilitySettingsProvider.select((a) => a.highContrast));

    // System "remove animations" caps the level at reduced.
    final systemReduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final level = systemReduce && appearance.animations == AnimationLevel.full
        ? AnimationLevel.reduced
        : appearance.animations;
    AppDurations.factor = switch (level) {
      AnimationLevel.full => 1,
      AnimationLevel.reduced => 0.5,
      AnimationLevel.off => 0,
    };

    final theme = AppTheme.build(
      locale: locale,
      brightness: resolved.brightness,
      amoled: resolved.amoled,
      accent: accent,
      appearance: appearance,
      highContrast: highContrast,
    );

    return DynamicColorBuilder(
      builder: (light, dark) {
        // Report the wallpaper colour; it's only used in Material You mode.
        final wallpaper = dark?.primary;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(dynamicAccentProvider.notifier).set(wallpaper);
        });
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: rootNavigatorKey,
          scaffoldMessengerKey: rootMessengerKey,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: theme,
          themeAnimationDuration: AppDurations.medium,
          themeAnimationCurve: Curves.easeOut,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear((mq.textScaler.scale(14) / 14 * appearance.textScale).clamp(0.8, 2.0)),
                boldText: mq.boldText || appearance.boldText,
                disableAnimations: level == AnimationLevel.off || mq.disableAnimations,
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
