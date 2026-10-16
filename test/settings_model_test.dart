import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:feruzbek/features/settings/state/theme_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('migrateSettings', () {
    test('fresh install gets version 1 defaults', () {
      final s = AppSettings.fromJson(migrateSettings(null));
      expect(s.languageCode, isNull);
      expect(s.appearance.playerStyle, PlayerStyle.vinyl);
      expect(s.library.showDemoTracks, isTrue);
    });

    test('folds app 1.0 keys into the typed model', () {
      final json = migrateSettings(
        null,
        legacy: {'locale': 'ru', 'artwork_style': 'square', 'show_demo': false, 'speed': 1.5, 'volume': 0.4},
      );
      expect(json['version'], 1);
      final s = AppSettings.fromJson(json);
      expect(s.languageCode, 'ru');
      expect(s.appearance.playerStyle, PlayerStyle.classic);
      expect(s.library.showDemoTracks, isFalse);
      expect(s.playback.speed, 1.5);
      expect(s.playback.volume, 0.4);
    });

    test('keeps a current document as is', () {
      final stored = const AppSettings(languageCode: 'uz').toJson();
      expect(AppSettings.fromJson(migrateSettings(stored)).languageCode, 'uz');
    });

    test('upgrades a document without a version', () {
      expect(migrateSettings({'languageCode': 'en'})['version'], 1);
    });
  });

  group('AppSettings JSON', () {
    test('round-trips every group', () {
      const s = AppSettings(
        languageCode: 'ru',
        appearance: AppearanceSettings(
          themeMode: AppThemeMode.amoled,
          accentMode: AccentMode.custom,
          customAccent: 0xFF123456,
          font: AppFont.nunito,
          textScale: 1.2,
          corners: CornerStyle.round,
          navOrder: [NavTab.settings, NavTab.home, NavTab.favorites, NavTab.playlists],
          hiddenNavTabs: [NavTab.favorites],
          homeTabOrder: [HomeTab.songs, HomeTab.suggested, HomeTab.artists, HomeTab.albums, HomeTab.folders],
        ),
        playback: PlaybackSettings(crossfadeSeconds: 6, speed: 1.25),
        audio: AudioSettings(
          eqEnabled: true,
          bandGains: [1, -2, 3],
          customPresets: {
            'Mine': [0, 1],
          },
        ),
        library: LibrarySettings(excludedFolders: ['/sdcard/Ringtones'], minDurationSeconds: 30),
        lyrics: LyricsSettings(fontSize: 22, offsetMs: -500),
        notifications: NotificationSettings(doublePress: HeadsetAction.previous),
        gestures: GestureSettings(shakeToSkip: true),
        accessibility: AccessibilitySettings(highContrast: true),
        privacy: PrivacySettings(collectStats: false),
      );
      final back = AppSettings.fromJson(s.toJson());
      expect(back.toJson(), s.toJson());
    });

    test('invalid values fall back to defaults or get clamped', () {
      final s = AppSettings.fromJson({
        'languageCode': 'de',
        'appearance': {
          'themeMode': 'neon',
          'textScale': 9,
          'navOrder': ['home', 'bogus', 'home'],
          'hiddenNavTabs': ['settings', 'favorites'],
        },
        'playback': {'crossfadeSeconds': 99, 'speed': 'fast'},
        'audio': 'not a map',
      });
      expect(s.languageCode, isNull);
      expect(s.appearance.themeMode, AppThemeMode.dark);
      expect(s.appearance.textScale, 1.3);
      // Missing tabs are appended; duplicates dropped; settings can't be hidden.
      expect(s.appearance.navOrder, [NavTab.home, NavTab.favorites, NavTab.playlists, NavTab.settings]);
      expect(s.appearance.hiddenNavTabs, [NavTab.favorites]);
      expect(s.appearance.visibleNavTabs, isNot(contains(NavTab.favorites)));
      expect(s.playback.crossfadeSeconds, 12);
      expect(s.playback.speed, 1.0);
      expect(s.audio.eqEnabled, isFalse);
    });
  });

  group('dark schedule', () {
    DateTime at(int h, int m) => DateTime(2026, 1, 1, h, m);

    test('window crossing midnight', () {
      expect(isInDarkWindow(at(21, 0), 20 * 60, 7 * 60), isTrue);
      expect(isInDarkWindow(at(3, 0), 20 * 60, 7 * 60), isTrue);
      expect(isInDarkWindow(at(7, 0), 20 * 60, 7 * 60), isFalse);
      expect(isInDarkWindow(at(12, 0), 20 * 60, 7 * 60), isFalse);
    });

    test('window within one day', () {
      expect(isInDarkWindow(at(13, 0), 12 * 60, 14 * 60), isTrue);
      expect(isInDarkWindow(at(15, 0), 12 * 60, 14 * 60), isFalse);
    });
  });
}
