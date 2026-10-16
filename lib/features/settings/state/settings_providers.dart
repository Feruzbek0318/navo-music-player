import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/app_settings.dart';
import '../data/settings_repository.dart';

export '../data/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(localStoreProvider)),
);

/// The single source of truth for user preferences. Changes apply
/// immediately; persistence is debounced.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  void update(AppSettings Function(AppSettings s) change) {
    final next = change(state);
    if (identical(next, state)) return;
    state = next;
    ref.read(settingsRepositoryProvider).save(next);
  }

  void appearance(AppearanceSettings Function(AppearanceSettings a) f) =>
      update((s) => s.copyWith(appearance: f(s.appearance)));
  void playback(PlaybackSettings Function(PlaybackSettings p) f) => update((s) => s.copyWith(playback: f(s.playback)));
  void audio(AudioSettings Function(AudioSettings a) f) => update((s) => s.copyWith(audio: f(s.audio)));
  void library(LibrarySettings Function(LibrarySettings l) f) => update((s) => s.copyWith(library: f(s.library)));
  void lyrics(LyricsSettings Function(LyricsSettings l) f) => update((s) => s.copyWith(lyrics: f(s.lyrics)));
  void notifications(NotificationSettings Function(NotificationSettings n) f) =>
      update((s) => s.copyWith(notifications: f(s.notifications)));
  void gestures(GestureSettings Function(GestureSettings g) f) => update((s) => s.copyWith(gestures: f(s.gestures)));
  void accessibility(AccessibilitySettings Function(AccessibilitySettings a) f) =>
      update((s) => s.copyWith(accessibility: f(s.accessibility)));
  void privacy(PrivacySettings Function(PrivacySettings p) f) => update((s) => s.copyWith(privacy: f(s.privacy)));

  void setLanguage(String? code) => update((s) => s.copyWith(languageCode: () => code));

  /// Restores every setting (language included) to its default.
  void resetAll() => update((_) => const AppSettings());

  /// Writes pending changes now (app going to background).
  Future<void> flush() => ref.read(settingsRepositoryProvider).flush();

  /// Replaces everything (backup import).
  void replace(AppSettings s) => update((_) => s);
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// Narrow selectors so widgets rebuild only when their slice changes.
final appearanceProvider = Provider<AppearanceSettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.appearance)),
);
final playbackSettingsProvider = Provider<PlaybackSettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.playback)),
);
final audioSettingsProvider = Provider<AudioSettings>((ref) => ref.watch(settingsProvider.select((s) => s.audio)));
final librarySettingsProvider = Provider<LibrarySettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.library)),
);
final lyricsSettingsProvider = Provider<LyricsSettings>((ref) => ref.watch(settingsProvider.select((s) => s.lyrics)));
final notificationSettingsProvider = Provider<NotificationSettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.notifications)),
);
final gestureSettingsProvider = Provider<GestureSettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.gestures)),
);
final accessibilitySettingsProvider = Provider<AccessibilitySettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.accessibility)),
);
final privacySettingsProvider = Provider<PrivacySettings>(
  (ref) => ref.watch(settingsProvider.select((s) => s.privacy)),
);

/// User-selected locale; `null` means "follow the device".
final localeProvider = Provider<Locale?>((ref) {
  final code = ref.watch(settingsProvider.select((s) => s.languageCode));
  return code == null ? null : Locale(code);
});

final showDemoTracksProvider = Provider<bool>(
  (ref) => ref.watch(librarySettingsProvider.select((l) => l.showDemoTracks)),
);

/// Resolves the device locale against the supported ones, falling back to English.
Locale resolveLocale(Locale? selected, List<Locale>? deviceLocales) {
  const supported = AppLocalizations.supportedLocales;
  if (selected != null) return selected;
  for (final device in deviceLocales ?? const <Locale>[]) {
    for (final s in supported) {
      if (s.languageCode == device.languageCode) return s;
    }
  }
  return const Locale('en');
}

/// Onboarding is app state, not a preference, so it lives outside [AppSettings].
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(localStoreProvider).setting<bool>(StoreKeys.onboardingSeen) ?? false;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(localStoreProvider).putSetting(StoreKeys.onboardingSeen, value);
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);
