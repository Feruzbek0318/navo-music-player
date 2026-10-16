import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../library/state/library_providers.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../player/state/playback_setup.dart';
import '../../player/ui/equalizer_screen.dart';
import '../state/backup_service.dart';
import '../state/settings_providers.dart';
import '../state/theme_providers.dart';
import 'about_screen.dart';
import 'blocked_songs_screen.dart';
import 'library_folders_screen.dart';
import 'settings_items.dart';
import 'settings_labels.dart';
import 'widgets/setting_tile.dart';
import 'widgets/appearance_widgets.dart';

/// Every settings group and item. Adding a setting = add a field to
/// [AppSettings] and one item here (see README "How to add a setting").
final settingsGroups = <SettingsGroup>[
  SettingsGroup(
    id: SettingsGroupId.appearance,
    icon: Icons.palette_outlined,
    title: (l) => l.groupAppearance,
    subtitle: (l) => l.appearanceSubtitle,
    reset: (s) => s.copyWith(appearance: const AppearanceSettings()),
    items: _appearanceItems,
  ),
  SettingsGroup(
    id: SettingsGroupId.player,
    icon: Icons.album_outlined,
    title: (l) => l.groupPlayer,
    subtitle: (l) => l.playerSubtitle,
    reset: (s) => s.copyWith(
      appearance: s.appearance.copyWith(
        playerStyle: const AppearanceSettings().playerStyle,
        blurStrength: const AppearanceSettings().blurStrength,
        animatedBackground: true,
        showRemainingTime: false,
      ),
    ),
    items: [_playerStyle, _blurStrength, _animatedBackground, _showRemaining],
  ),
  SettingsGroup(
    id: SettingsGroupId.playback,
    icon: Icons.play_circle_outline_rounded,
    title: (l) => l.groupPlayback,
    subtitle: (l) => l.playbackSubtitle,
    reset: (s) => s.copyWith(playback: const PlaybackSettings()),
    items: _playbackItems,
  ),
  SettingsGroup(
    id: SettingsGroupId.audio,
    icon: Icons.graphic_eq_rounded,
    title: (l) => l.groupAudio,
    subtitle: (l) => l.audioSubtitle,
    reset: (s) => s.copyWith(audio: AudioSettings(customPresets: s.audio.customPresets)),
    items: [
      ActionItem(
        title: (l) => l.equalizer,
        icon: Icons.equalizer_rounded,
        value: (l, s, _) => s.audio.eqEnabled ? eqPresetLabel(l, s.audio.eqPreset) : l.off,
        onTap: (context, ref) => context.pushPage<void>((_) => const EqualizerScreen()),
      ),
      SliderItem(
        title: (l) => l.bassBoost,
        icon: Icons.speaker_rounded,
        min: 0,
        max: 1,
        divisions: 20,
        read: (s) => s.audio.bassBoost,
        write: (s, v) => s.copyWith(audio: s.audio.copyWith(bassBoost: v)),
        format: (l, v) => v == 0 ? l.off : percent(l, v),
      ),
      SliderItem(
        title: (l) => l.loudnessBoost,
        advanced: true,
        icon: Icons.volume_up_rounded,
        min: 0,
        max: 1,
        divisions: 20,
        read: (s) => s.audio.loudness,
        write: (s, v) => s.copyWith(audio: s.audio.copyWith(loudness: v)),
        format: (l, v) => v == 0 ? l.off : percent(l, v),
      ),
      SwitchItem(
        title: (l) => l.normalizeVolume,
        advanced: true,
        subtitle: (l) => l.normalizeHint,
        icon: Icons.tune_rounded,
        read: (s) => s.playback.normalizeVolume,
        write: (s, v) => s.copyWith(playback: s.playback.copyWith(normalizeVolume: v)),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.lyrics,
    icon: Icons.lyrics_outlined,
    title: (l) => l.groupLyrics,
    subtitle: (l) => l.lyricsSubtitle,
    reset: (s) => s.copyWith(lyrics: const LyricsSettings()),
    items: [
      SliderItem(
        title: (l) => l.lyricsFontSize,
        icon: Icons.format_size_rounded,
        min: 12,
        max: 32,
        divisions: 10,
        read: (s) => s.lyrics.fontSize,
        write: (s, v) => s.copyWith(lyrics: s.lyrics.copyWith(fontSize: v)),
        format: (l, v) => v.round().toString(),
      ),
      ChoiceItem<LyricsAlign>(
        title: (l) => l.lyricsAlign,
        icon: Icons.format_align_center_rounded,
        options: LyricsAlign.values,
        label: (l, a) => a == LyricsAlign.start ? l.alignStart : l.alignCenter,
        read: (s) => s.lyrics.align,
        write: (s, v) => s.copyWith(lyrics: s.lyrics.copyWith(align: v)),
      ),
      SliderItem(
        title: (l) => l.lyricsOffset,
        advanced: true,
        subtitle: (l) => l.lyricsOffsetHint,
        icon: Icons.av_timer_rounded,
        min: -5,
        max: 5,
        divisions: 20,
        read: (s) => s.lyrics.offsetMs / 1000,
        write: (s, v) => s.copyWith(lyrics: s.lyrics.copyWith(offsetMs: (v * 1000).round())),
        format: (l, v) => l.offsetSeconds('${v > 0 ? '+' : ''}${v.toStringAsFixed(1)}'),
      ),
      SwitchItem(
        title: (l) => l.autoScrollLyrics,
        icon: Icons.swipe_vertical_rounded,
        read: (s) => s.lyrics.autoScroll,
        write: (s, v) => s.copyWith(lyrics: s.lyrics.copyWith(autoScroll: v)),
      ),
      SwitchItem(
        title: (l) => l.keepScreenOn,
        icon: Icons.light_mode_outlined,
        read: (s) => s.lyrics.keepScreenOn,
        write: (s, v) => s.copyWith(lyrics: s.lyrics.copyWith(keepScreenOn: v)),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.notifications,
    icon: Icons.notifications_outlined,
    title: (l) => l.groupNotifications,
    subtitle: (l) => l.notificationsSubtitle,
    reset: (s) => s.copyWith(notifications: const NotificationSettings()),
    items: [
      HeaderItem(title: (l) => l.sectionNotification),
      ActionItem(
        title: (l) => l.notificationPermission,
        subtitle: (l) => l.notificationPermissionHint,
        icon: Icons.notifications_active_outlined,
        visible: (s, ref) => ref.read(deviceBridgeProvider).isAndroid,
        onTap: (context, ref) async {
          final status = await Permission.notification.request();
          if (!status.isGranted) await openAppSettings();
        },
      ),
      SwitchItem(
        title: (l) => l.notifArtwork,
        icon: Icons.image_outlined,
        read: (s) => s.notifications.showArtwork,
        write: (s, v) => s.copyWith(notifications: s.notifications.copyWith(showArtwork: v)),
      ),
      SwitchItem(
        title: (l) => l.notifCloseButton,
        icon: Icons.close_rounded,
        read: (s) => s.notifications.showCloseButton,
        write: (s, v) => s.copyWith(notifications: s.notifications.copyWith(showCloseButton: v)),
      ),
      SwitchItem(
        title: (l) => l.notifFavoriteButton,
        icon: Icons.favorite_border_rounded,
        read: (s) => s.notifications.showFavoriteButton,
        write: (s, v) => s.copyWith(notifications: s.notifications.copyWith(showFavoriteButton: v)),
      ),
      SwitchItem(
        title: (l) => l.notifCompactSkip,
        advanced: true,
        icon: Icons.skip_next_outlined,
        read: (s) => s.notifications.compactSkipButtons,
        write: (s, v) => s.copyWith(notifications: s.notifications.copyWith(compactSkipButtons: v)),
      ),
      HeaderItem(title: (l) => l.sectionHeadset),
      for (final (press, title) in [
        (1, (AppLocalizations l) => l.pressSingle),
        (2, (AppLocalizations l) => l.pressDouble),
        (3, (AppLocalizations l) => l.pressTriple),
      ])
        ChoiceItem<HeadsetAction>(
          title: title,
          advanced: true,
          icon: Icons.headset_rounded,
          options: HeadsetAction.values,
          label: headsetActionLabel,
          read: (s) => switch (press) {
            1 => s.notifications.singlePress,
            2 => s.notifications.doublePress,
            _ => s.notifications.triplePress,
          },
          write: (s, v) => s.copyWith(
            notifications: switch (press) {
              1 => s.notifications.copyWith(singlePress: v),
              2 => s.notifications.copyWith(doublePress: v),
              _ => s.notifications.copyWith(triplePress: v),
            },
          ),
        ),
      HeaderItem(title: (l) => l.sectionWidget),
      CustomItem(
        title: (l) => l.sectionWidget,
        keywords: (l) => l.widgetHint,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, Insets.md),
          child: Text(context.l10n.widgetHint, style: context.text.bodySmall),
        ),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.library,
    icon: Icons.library_music_outlined,
    title: (l) => l.groupLibrary,
    subtitle: (l) => l.librarySubtitle,
    reset: (s) => s.copyWith(library: const LibrarySettings()),
    items: _libraryItems,
  ),
  SettingsGroup(
    id: SettingsGroupId.gestures,
    icon: Icons.swipe_rounded,
    title: (l) => l.groupGestures,
    subtitle: (l) => l.gesturesSubtitle,
    reset: (s) => s.copyWith(gestures: const GestureSettings()),
    items: [
      SwitchItem(
        title: (l) => l.gestureMiniSwipe,
        icon: Icons.swipe_rounded,
        read: (s) => s.gestures.miniPlayerSwipe,
        write: (s, v) => s.copyWith(gestures: s.gestures.copyWith(miniPlayerSwipe: v)),
      ),
      SwitchItem(
        title: (l) => l.haptics,
        icon: Icons.vibration_rounded,
        read: (s) => s.gestures.haptics,
        write: (s, v) => s.copyWith(gestures: s.gestures.copyWith(haptics: v)),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.storage,
    icon: Icons.backup_outlined,
    title: (l) => l.groupStorage,
    subtitle: (l) => l.storageSubtitle,
    items: [
      ActionItem(
        title: (l) => l.backupExport,
        subtitle: (l) => l.backupExportHint,
        icon: Icons.upload_file_rounded,
        onTap: (context, ref) async {
          final l10n = context.l10n;
          final saved = await ref.read(backupServiceProvider).export();
          if (saved && context.mounted) context.showSnack(l10n.backupSaved);
        },
      ),
      ActionItem(
        title: (l) => l.backupImport,
        subtitle: (l) => l.backupImportHint,
        icon: Icons.settings_backup_restore_rounded,
        onTap: (context, ref) async {
          final l10n = context.l10n;
          final ok = await confirmReset(context, title: l10n.restoreBackupTitle, message: l10n.restoreBackupMessage);
          if (!ok) return;
          final result = await ref.read(backupServiceProvider).import();
          if (!context.mounted) return;
          switch (result) {
            case RestoreResult.restored:
              context.showSnack(l10n.backupRestored);
            case RestoreResult.invalid:
              context.showSnack(l10n.backupInvalid);
            case RestoreResult.cancelled:
              break;
          }
        },
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.language,
    icon: Icons.translate_rounded,
    title: (l) => l.language,
    subtitle: (l) => l.languageSubtitle,
    reset: (s) => s.copyWith(languageCode: () => null),
    items: [
      ChoiceItem<String?>(
        title: (l) => l.language,
        icon: Icons.translate_rounded,
        options: const [null, 'uz', 'ru', 'en'],
        label: languageLabel,
        read: (s) => s.languageCode,
        write: (s, v) => s.copyWith(languageCode: () => v),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.accessibility,
    icon: Icons.accessibility_new_rounded,
    title: (l) => l.groupAccessibility,
    subtitle: (l) => l.accessibilitySubtitle,
    reset: (s) => s.copyWith(
      accessibility: const AccessibilitySettings(),
      appearance: s.appearance.copyWith(textScale: 1, boldText: false, animations: AnimationLevel.full),
    ),
    items: [
      SwitchItem(
        title: (l) => l.highContrast,
        subtitle: (l) => l.highContrastHint,
        icon: Icons.contrast_rounded,
        read: (s) => s.accessibility.highContrast,
        write: (s, v) => s.copyWith(accessibility: s.accessibility.copyWith(highContrast: v)),
      ),
      _textScale,
      _boldText,
      _animations,
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.privacy,
    icon: Icons.shield_outlined,
    title: (l) => l.groupPrivacy,
    subtitle: (l) => l.privacySubtitle,
    reset: (s) => s.copyWith(privacy: const PrivacySettings()),
    items: [
      CustomItem(title: (l) => l.groupPrivacy, builder: (context) => const _PrivacyStatement()),
      SwitchItem(
        title: (l) => l.saveSearchHistory,
        icon: Icons.history_rounded,
        read: (s) => s.privacy.saveSearchHistory,
        write: (s, v) => s.copyWith(privacy: s.privacy.copyWith(saveSearchHistory: v)),
      ),
    ],
  ),
  SettingsGroup(
    id: SettingsGroupId.about,
    icon: Icons.info_outline_rounded,
    title: (l) => l.about,
    subtitle: (l) => l.aboutSubtitle,
    items: [
      ActionItem(
        title: (l) => l.aboutNavo,
        icon: Icons.info_outline_rounded,
        onTap: (context, ref) => context.pushPage<void>((_) => const AboutScreen()),
      ),
      ActionItem(
        title: (l) => l.showOnboarding,
        icon: Icons.slideshow_rounded,
        onTap: (context, ref) => Navigator.of(
          context,
          rootNavigator: true,
        ).push(FadeThroughRoute<void>(builder: (_) => const OnboardingScreen())),
      ),
    ],
  ),
];

SettingsGroup groupById(SettingsGroupId id) => settingsGroups.firstWhere((g) => g.id == id);

// ---------------------------------------------------------------------------
// Appearance
// ---------------------------------------------------------------------------

AppSettings _a(AppSettings s, AppearanceSettings Function(AppearanceSettings a) f) =>
    s.copyWith(appearance: f(s.appearance));

final _textScale = SliderItem(
  title: (l) => l.textSize,
  icon: Icons.format_size_rounded,
  min: 0.8,
  max: 1.3,
  divisions: 10,
  read: (s) => s.appearance.textScale,
  write: (s, v) => _a(s, (a) => a.copyWith(textScale: double.parse(v.toStringAsFixed(2)))),
  format: percent,
);

final _boldText = SwitchItem(
  title: (l) => l.boldText,
  icon: Icons.format_bold_rounded,
  read: (s) => s.appearance.boldText,
  write: (s, v) => _a(s, (a) => a.copyWith(boldText: v)),
);

final _animations = ChoiceItem<AnimationLevel>(
  title: (l) => l.animations,
  subtitle: (l) => l.systemReduceMotion,
  icon: Icons.animation_rounded,
  options: AnimationLevel.values,
  label: animationLabel,
  read: (s) => s.appearance.animations,
  write: (s, v) => _a(s, (a) => a.copyWith(animations: v)),
);

final _playerStyle = ChoiceItem<PlayerStyle>(
  title: (l) => l.playerStyle,
  icon: Icons.album_outlined,
  options: PlayerStyle.values,
  label: playerStyleLabel,
  read: (s) => s.appearance.playerStyle,
  write: (s, v) => _a(s, (a) => a.copyWith(playerStyle: v)),
);

final _blurStrength = SliderItem(
  title: (l) => l.blurStrength,
  icon: Icons.blur_on_rounded,
  visible: (s, _) => s.appearance.playerStyle == PlayerStyle.blurred,
  min: 0,
  max: 1,
  divisions: 10,
  read: (s) => s.appearance.blurStrength,
  write: (s, v) => _a(s, (a) => a.copyWith(blurStrength: v)),
  format: percent,
);

final _animatedBackground = SwitchItem(
  title: (l) => l.animatedBackground,
  icon: Icons.gradient_rounded,
  visible: (s, _) => s.appearance.playerStyle != PlayerStyle.minimal,
  read: (s) => s.appearance.animatedBackground,
  write: (s, v) => _a(s, (a) => a.copyWith(animatedBackground: v)),
);

final _showRemaining = SwitchItem(
  title: (l) => l.showRemainingTime,
  icon: Icons.timelapse_rounded,
  read: (s) => s.appearance.showRemainingTime,
  write: (s, v) => _a(s, (a) => a.copyWith(showRemainingTime: v)),
);

AppSettings _l(AppSettings s, LibrarySettings Function(LibrarySettings l) f) => s.copyWith(library: f(s.library));

final _libraryItems = <SettingItem>[
  HeaderItem(title: (l) => l.sectionFolders),
  ActionItem(
    title: (l) => l.libraryFolders,
    subtitle: (l) => l.libraryFoldersHint,
    icon: Icons.folder_outlined,
    value: (l, s, _) {
      final hidden = s.library.excludedFolders.length;
      if (s.library.includedFolders.isNotEmpty) return l.folderOnlyActive;
      return hidden == 0 ? l.allFoldersShown : l.foldersSummary(hidden);
    },
    onTap: (context, ref) => context.pushPage<void>((_) => const LibraryFoldersScreen()),
  ),
  HeaderItem(title: (l) => l.sectionFilters),
  SliderItem(
    title: (l) => l.minDuration,
    icon: Icons.timer_outlined,
    min: 0,
    max: 120,
    divisions: 24,
    read: (s) => s.library.minDurationSeconds.toDouble(),
    write: (s, v) => _l(s, (x) => x.copyWith(minDurationSeconds: v.round())),
    format: (l, v) => v == 0 ? l.off : l.secondsShort(v.round()),
  ),
  SliderItem(
    title: (l) => l.minSize,
    advanced: true,
    icon: Icons.sd_storage_outlined,
    min: 0,
    max: 2000,
    divisions: 20,
    read: (s) => s.library.minSizeKb.toDouble(),
    write: (s, v) => _l(s, (x) => x.copyWith(minSizeKb: v.round())),
    format: (l, v) => v == 0 ? l.off : l.kbValue(v.round()),
  ),
  SwitchItem(
    title: (l) => l.hideShortSounds,
    icon: Icons.notifications_off_outlined,
    read: (s) => s.library.hideShortSounds,
    write: (s, v) => _l(s, (x) => x.copyWith(hideShortSounds: v)),
  ),
  SwitchItem(
    title: (l) => l.showDemoTracks,
    advanced: true,
    icon: Icons.auto_awesome_rounded,
    read: (s) => s.library.showDemoTracks,
    write: (s, v) => _l(s, (x) => x.copyWith(showDemoTracks: v)),
  ),
  ActionItem(
    title: (l) => l.blockedSongs,
    icon: Icons.block_rounded,
    value: (l, s, ref) {
      final n = ref.watch(blocklistProvider).length;
      return n == 0 ? l.blockedSongsEmpty : l.songsCount(n);
    },
    onTap: (context, ref) => context.pushPage<void>((_) => const BlockedSongsScreen()),
  ),
  HeaderItem(title: (l) => l.sectionGrouping),
  SwitchItem(
    title: (l) => l.splitArtists,
    advanced: true,
    subtitle: (l) => l.splitArtistsHint,
    icon: Icons.call_split_rounded,
    read: (s) => s.library.splitArtists,
    write: (s, v) => _l(s, (x) => x.copyWith(splitArtists: v)),
  ),
  SwitchItem(
    title: (l) => l.groupByAlbumArtist,
    advanced: true,
    icon: Icons.people_alt_outlined,
    read: (s) => s.library.groupByAlbumArtist,
    write: (s, v) => _l(s, (x) => x.copyWith(groupByAlbumArtist: v)),
  ),
  HeaderItem(title: (l) => l.sectionScanning),
  SwitchItem(
    title: (l) => l.scanOnLaunch,
    icon: Icons.manage_search_rounded,
    read: (s) => s.library.scanOnLaunch,
    write: (s, v) => _l(s, (x) => x.copyWith(scanOnLaunch: v)),
  ),
  ActionItem(
    title: (l) => l.rescanLibrary,
    icon: Icons.refresh_rounded,
    value: (l, s, ref) => ref.watch(scanningProvider) ? l.scanning : null,
    onTap: (context, ref) async {
      final l10n = context.l10n;
      context.showSnack(l10n.scanning);
      final n = await rescanLibrary(ref);
      if (context.mounted) context.showSnack(l10n.scanFound(l10n.songsCount(n)));
    },
  ),
];

AppSettings _p(AppSettings s, PlaybackSettings Function(PlaybackSettings p) f) => s.copyWith(playback: f(s.playback));

final _playbackItems = <SettingItem>[
  HeaderItem(title: (l) => l.sectionTransitions),
  SliderItem(
    title: (l) => l.crossfade,
    subtitle: (l) => l.crossfadeHint,
    icon: Icons.swap_horiz_rounded,
    min: 0,
    max: 12,
    divisions: 12,
    read: (s) => s.playback.crossfadeSeconds.toDouble(),
    write: (s, v) => _p(s, (p) => p.copyWith(crossfadeSeconds: v.round())),
    format: (l, v) => v == 0 ? l.off : l.secondsShort(v.round()),
  ),
  SwitchItem(
    title: (l) => l.fadeOnPlayPause,
    advanced: true,
    icon: Icons.blur_linear_rounded,
    read: (s) => s.playback.fadeOnPlayPause,
    write: (s, v) => _p(s, (p) => p.copyWith(fadeOnPlayPause: v)),
  ),
  SwitchItem(
    title: (l) => l.skipSilence,
    advanced: true,
    icon: Icons.fast_forward_rounded,
    visible: (s, ref) => ref.read(deviceBridgeProvider).isAndroid,
    read: (s) => s.playback.skipSilence,
    write: (s, v) => _p(s, (p) => p.copyWith(skipSilence: v)),
  ),
  HeaderItem(title: (l) => l.playbackSpeed),
  SliderItem(
    title: (l) => l.playbackSpeed,
    advanced: true,
    icon: Icons.speed_rounded,
    min: 0.5,
    max: 2,
    divisions: 30,
    read: (s) => s.playback.speed,
    write: (s, v) => _p(s, (p) => p.copyWith(speed: double.parse(v.toStringAsFixed(2)))),
    format: (l, v) => '${v.toStringAsFixed(2)}×',
  ),
  SliderItem(
    title: (l) => l.pitch,
    advanced: true,
    icon: Icons.graphic_eq_rounded,
    min: 0.5,
    max: 2,
    divisions: 30,
    read: (s) => s.playback.pitch,
    write: (s, v) => _p(s, (p) => p.copyWith(pitch: double.parse(v.toStringAsFixed(2)))),
    format: (l, v) => '${v.toStringAsFixed(2)}×',
  ),
  HeaderItem(title: (l) => l.sectionBehavior),
  SwitchItem(
    title: (l) => l.resumeAfterCall,
    icon: Icons.call_end_rounded,
    read: (s) => s.playback.resumeAfterCall,
    write: (s, v) => _p(s, (p) => p.copyWith(resumeAfterCall: v)),
  ),
  SwitchItem(
    title: (l) => l.pauseOnDisconnect,
    icon: Icons.headset_off_rounded,
    read: (s) => s.playback.pauseOnDisconnect,
    write: (s, v) => _p(s, (p) => p.copyWith(pauseOnDisconnect: v)),
  ),
  SwitchItem(
    title: (l) => l.resumeOnHeadset,
    advanced: true,
    icon: Icons.headphones_rounded,
    read: (s) => s.playback.resumeOnHeadset,
    write: (s, v) => _p(s, (p) => p.copyWith(resumeOnHeadset: v)),
  ),
  SwitchItem(
    title: (l) => l.rememberQueue,
    icon: Icons.restore_rounded,
    read: (s) => s.playback.rememberQueue,
    write: (s, v) => _p(s, (p) => p.copyWith(rememberQueue: v)),
  ),
  SwitchItem(
    title: (l) => l.autoPlayOnStart,
    advanced: true,
    icon: Icons.play_arrow_rounded,
    visible: (s, _) => s.playback.rememberQueue,
    read: (s) => s.playback.autoPlayOnStart,
    write: (s, v) => _p(s, (p) => p.copyWith(autoPlayOnStart: v)),
  ),
  ChoiceItem<AddMode>(
    title: (l) => l.addMode,
    advanced: true,
    icon: Icons.queue_music_rounded,
    options: AddMode.values,
    label: (l, m) => m == AddMode.playNext ? l.playNext : l.addToEnd,
    read: (s) => s.playback.addMode,
    write: (s, v) => _p(s, (p) => p.copyWith(addMode: v)),
  ),
  ChoiceItem<ShuffleStyle>(
    title: (l) => l.shuffleStyle,
    advanced: true,
    icon: Icons.shuffle_rounded,
    options: ShuffleStyle.values,
    label: (l, m) => m == ShuffleStyle.random ? l.shuffleRandom : l.shuffleAvoidRecent,
    read: (s) => s.playback.shuffleStyle,
    write: (s, v) => _p(s, (p) => p.copyWith(shuffleStyle: v)),
  ),
  ActionItem(
    title: (l) => l.backgroundPlayback,
    subtitle: (l) => l.backgroundPlaybackHint,
    icon: Icons.battery_saver_rounded,
    visible: (s, ref) => ref.read(deviceBridgeProvider).isAndroid,
    onTap: (context, ref) => ref.read(playbackSetupProvider).openBatterySettings(),
  ),
  HeaderItem(title: (l) => l.sectionSleep),
  SwitchItem(
    title: (l) => l.sleepFadeOut,
    icon: Icons.bedtime_outlined,
    read: (s) => s.playback.sleepFadeOut,
    write: (s, v) => _p(s, (p) => p.copyWith(sleepFadeOut: v)),
  ),
  SwitchItem(
    title: (l) => l.shakeToExtend,
    advanced: true,
    icon: Icons.vibration_rounded,
    read: (s) => s.playback.shakeToExtendSleep,
    write: (s, v) => _p(s, (p) => p.copyWith(shakeToExtendSleep: v)),
  ),
];

final _appearanceItems = <SettingItem>[
  CustomItem(title: (l) => l.preview, builder: (context) => const AppearancePreview()),
  HeaderItem(title: (l) => l.sectionTheme),
  ChoiceItem<AppThemeMode>(
    title: (l) => l.themeMode,
    icon: Icons.dark_mode_outlined,
    keywords: (l) => '${l.themeLight} ${l.themeDark} ${l.themeAmoled}',
    options: AppThemeMode.values,
    label: themeModeLabel,
    read: (s) => s.appearance.themeMode,
    write: (s, v) => _a(s, (a) => a.copyWith(themeMode: v)),
  ),
  SwitchItem(
    title: (l) => l.themeSchedule,
    advanced: true,
    subtitle: (l) => l.themeScheduleHint,
    icon: Icons.schedule_rounded,
    visible: (s, _) => s.appearance.themeMode != AppThemeMode.light,
    read: (s) => s.appearance.scheduleEnabled,
    write: (s, v) => _a(s, (a) => a.copyWith(scheduleEnabled: v)),
  ),
  for (final from in [true, false])
    ActionItem(
      title: (l) => from ? l.darkFrom : l.darkUntil,
      advanced: true,
      icon: from ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
      visible: (s, _) => s.appearance.scheduleEnabled && s.appearance.themeMode != AppThemeMode.light,
      value: (l, s, _) => clockLabel(from ? s.appearance.darkFromMinutes : s.appearance.darkToMinutes),
      onTap: (context, ref) => pickScheduleTime(context, ref, from: from),
    ),
  HeaderItem(title: (l) => l.sectionColor),
  ChoiceItem<AccentMode>(
    title: (l) => l.accentSource,
    icon: Icons.color_lens_outlined,
    options: AccentMode.values,
    label: accentModeLabel,
    enabled: (m, ref) => m != AccentMode.materialYou || ref.read(dynamicAccentProvider) != null,
    read: (s) => s.appearance.accentMode,
    write: (s, v) => _a(s, (a) => a.copyWith(accentMode: v)),
  ),
  CustomItem(
    title: (l) => l.accentPreset,
    visible: (s, _) => s.appearance.accentMode == AccentMode.preset,
    builder: (context) => const AccentPresetPicker(),
  ),
  CustomItem(
    title: (l) => l.accentCustom,
    visible: (s, _) => s.appearance.accentMode == AccentMode.custom,
    builder: (context) => const CustomAccentPicker(),
  ),
  HeaderItem(title: (l) => l.sectionText),
  ChoiceItem<AppFont>(
    title: (l) => l.font,
    icon: Icons.font_download_outlined,
    options: AppFont.values,
    label: fontLabel,
    read: (s) => s.appearance.font,
    write: (s, v) => _a(s, (a) => a.copyWith(font: v)),
  ),
  _textScale,
  _boldText,
  HeaderItem(title: (l) => l.sectionLayout),
  ChoiceItem<CornerStyle>(
    title: (l) => l.corners,
    advanced: true,
    icon: Icons.rounded_corner_rounded,
    options: CornerStyle.values,
    label: cornersLabel,
    read: (s) => s.appearance.corners,
    write: (s, v) => _a(s, (a) => a.copyWith(corners: v)),
  ),
  ChoiceItem<ListDensity>(
    title: (l) => l.density,
    advanced: true,
    icon: Icons.density_medium_rounded,
    options: ListDensity.values,
    label: densityLabel,
    read: (s) => s.appearance.density,
    write: (s, v) => _a(s, (a) => a.copyWith(density: v)),
  ),
  SwitchItem(
    title: (l) => l.showListArtwork,
    icon: Icons.image_outlined,
    read: (s) => s.appearance.showListArtwork,
    write: (s, v) => _a(s, (a) => a.copyWith(showListArtwork: v)),
  ),
  ChoiceItem<ArtShape>(
    title: (l) => l.artShape,
    advanced: true,
    icon: Icons.crop_square_rounded,
    visible: (s, _) => s.appearance.showListArtwork,
    options: ArtShape.values,
    label: artShapeLabel,
    read: (s) => s.appearance.artShape,
    write: (s, v) => _a(s, (a) => a.copyWith(artShape: v)),
  ),
  ChoiceItem<ArtSize>(
    title: (l) => l.artSize,
    advanced: true,
    icon: Icons.photo_size_select_large_rounded,
    visible: (s, _) => s.appearance.showListArtwork,
    options: ArtSize.values,
    label: artSizeLabel,
    read: (s) => s.appearance.artSize,
    write: (s, v) => _a(s, (a) => a.copyWith(artSize: v)),
  ),
  HeaderItem(title: (l) => l.sectionPlayerLook),
  _playerStyle,
  _blurStrength,
  _animatedBackground,
  HeaderItem(title: (l) => l.sectionNavigation),
  SwitchItem(
    title: (l) => l.showNavLabels,
    advanced: true,
    icon: Icons.label_outline_rounded,
    read: (s) => s.appearance.showNavLabels,
    write: (s, v) => _a(s, (a) => a.copyWith(showNavLabels: v)),
  ),
  ActionItem(
    title: (l) => l.navTabs,
    advanced: true,
    subtitle: (l) => l.navTabsHint,
    icon: Icons.view_week_outlined,
    value: (l, s, _) => s.appearance.visibleNavTabs.map((t) => navTabLabel(l, t)).join(' · '),
    onTap: (context, ref) => showTabOrderSheet(context, homeTabs: false),
  ),
  ChoiceItem<NavTab>(
    title: (l) => l.startTab,
    advanced: true,
    icon: Icons.start_rounded,
    options: NavTab.values,
    label: navTabLabel,
    enabled: (t, ref) => ref.read(appearanceProvider).visibleNavTabs.contains(t),
    read: (s) => s.appearance.startTab,
    write: (s, v) => _a(s, (a) => a.copyWith(startTab: v)),
  ),
  ActionItem(
    title: (l) => l.homeTabs,
    advanced: true,
    icon: Icons.tab_outlined,
    value: (l, s, _) => s.appearance.homeTabOrder.map((t) => homeTabLabel(l, t)).join(' · '),
    onTap: (context, ref) => showTabOrderSheet(context, homeTabs: true),
  ),
  ChoiceItem<HomeTab>(
    title: (l) => l.startHomeTab,
    advanced: true,
    icon: Icons.home_outlined,
    options: HomeTab.values,
    label: homeTabLabel,
    read: (s) => s.appearance.startHomeTab,
    write: (s, v) => _a(s, (a) => a.copyWith(startHomeTab: v)),
  ),
  ChoiceItem<MiniPlayerStyle>(
    title: (l) => l.miniPlayerStyle,
    advanced: true,
    icon: Icons.picture_in_picture_alt_outlined,
    options: MiniPlayerStyle.values,
    label: miniPlayerLabel,
    read: (s) => s.appearance.miniPlayerStyle,
    write: (s, v) => _a(s, (a) => a.copyWith(miniPlayerStyle: v)),
  ),
  HeaderItem(title: (l) => l.sectionMotion),
  _animations,
];

Future<void> pickScheduleTime(BuildContext context, WidgetRef ref, {required bool from}) async {
  final a = ref.read(appearanceProvider);
  final minutes = from ? a.darkFromMinutes : a.darkToMinutes;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  if (picked == null) return;
  final m = picked.hour * 60 + picked.minute;
  ref
      .read(settingsProvider.notifier)
      .appearance((x) => from ? x.copyWith(darkFromMinutes: m) : x.copyWith(darkToMinutes: m));
}

class _PrivacyStatement extends StatelessWidget {
  const _PrivacyStatement();

  @override
  Widget build(BuildContext context) {
    final navo = context.navo;
    return Container(
      margin: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, Insets.sm),
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(color: navo.surface, borderRadius: navo.radius(Radii.lg)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: navo.accent),
          const SizedBox(width: Insets.md),
          Expanded(child: Text(context.l10n.privacyStatement, style: context.text.bodyMedium?.copyWith(height: 1.45))),
        ],
      ),
    );
  }
}
