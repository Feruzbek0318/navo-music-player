import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../player/state/palette_provider.dart';
import '../../player/state/player_providers.dart';
import 'settings_providers.dart';

/// Current time, ticking once a minute (drives the dark-theme schedule).
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    final now = DateTime.now();
    await Future<void>.delayed(Duration(seconds: 60 - now.second));
    yield DateTime.now();
  }
});

/// Wallpaper colour from Android 12+ (Material You); `null` when unsupported.
class DynamicAccentNotifier extends Notifier<Color?> {
  @override
  Color? build() => null;

  void set(Color? c) {
    if (c != state) state = c;
  }
}

final dynamicAccentProvider = NotifierProvider<DynamicAccentNotifier, Color?>(DynamicAccentNotifier.new);

/// The device's light/dark preference, kept in sync by the app root.
class PlatformBrightnessNotifier extends Notifier<Brightness> {
  @override
  Brightness build() => WidgetsBinding.instance.platformDispatcher.platformBrightness;

  void set(Brightness b) {
    if (b != state) state = b;
  }
}

final platformBrightnessProvider = NotifierProvider<PlatformBrightnessNotifier, Brightness>(
  PlatformBrightnessNotifier.new,
);

/// Whether [now] falls in the dark window [from, to) (minutes after midnight),
/// handling windows that cross midnight.
bool isInDarkWindow(DateTime now, int from, int to) {
  final m = now.hour * 60 + now.minute;
  if (from == to) return true;
  return from < to ? m >= from && m < to : m >= from || m < to;
}

@immutable
class ResolvedTheme {
  const ResolvedTheme({required this.brightness, required this.amoled});

  final Brightness brightness;
  final bool amoled;
}

/// Light/dark/AMOLED after applying the mode, the system and the schedule.
final resolvedThemeProvider = Provider<ResolvedTheme>((ref) {
  final a = ref.watch(appearanceProvider);
  final amoled = a.themeMode == AppThemeMode.amoled;
  if (a.themeMode == AppThemeMode.light) {
    return const ResolvedTheme(brightness: Brightness.light, amoled: false);
  }
  if (a.scheduleEnabled) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final dark = isInDarkWindow(now, a.darkFromMinutes, a.darkToMinutes);
    return ResolvedTheme(brightness: dark ? Brightness.dark : Brightness.light, amoled: dark && amoled);
  }
  if (a.themeMode == AppThemeMode.system) {
    return ResolvedTheme(brightness: ref.watch(platformBrightnessProvider), amoled: false);
  }
  return ResolvedTheme(brightness: Brightness.dark, amoled: amoled);
});

/// The accent colour after applying the chosen source.
final accentColorProvider = Provider<Color>((ref) {
  final a = ref.watch(appearanceProvider);
  final preset = AppColors.accentPresets[a.accentPreset.clamp(0, AppColors.accentPresets.length - 1)];
  switch (a.accentMode) {
    case AccentMode.preset:
      return preset;
    case AccentMode.custom:
      return Color(a.customAccent);
    case AccentMode.materialYou:
      return ref.watch(dynamicAccentProvider) ?? preset;
    case AccentMode.adaptive:
      final track = ref.watch(currentTrackProvider);
      if (track == null) return preset;
      return ref.watch(paletteColorProvider(track)).value ?? preset;
  }
});
