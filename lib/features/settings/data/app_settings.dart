import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum AppThemeMode { system, light, dark, amoled }

enum AccentMode { preset, custom, materialYou, adaptive }

enum AppFont { urbanist, manrope, nunito, montserrat }

enum CornerStyle { sharp, medium, round }

enum ListDensity { compact, comfortable, spacious }

enum ArtShape { square, rounded, circle }

enum ArtSize { small, medium, large }

enum PlayerStyle { classic, vinyl, minimal, blurred }

enum NavTab { home, favorites, playlists, settings }

enum HomeTab { suggested, songs, artists, albums, folders }

enum MiniPlayerStyle { floating, docked }

enum AnimationLevel { full, reduced, off }

enum AddMode { playNext, addToEnd }

enum ShuffleStyle { random, avoidRecent }

enum LyricsAlign { start, center }

enum HeadsetAction { playPause, next, previous, none }

// ---------------------------------------------------------------------------
// JSON helpers: every field falls back to its default when missing or invalid,
// so older and newer files load without throwing.
// ---------------------------------------------------------------------------

T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) =>
    raw is String ? values.asNameMap()[raw] ?? fallback : fallback;

bool _bool(Object? raw, bool fallback) => raw is bool ? raw : fallback;

int _int(Object? raw, int fallback) => raw is num ? raw.toInt() : fallback;

double _double(Object? raw, double fallback, {double? min, double? max}) {
  var v = raw is num ? raw.toDouble() : fallback;
  if (min != null && v < min) v = min;
  if (max != null && v > max) v = max;
  return v;
}

List<T> _enumList<T extends Enum>(List<T> values, Object? raw, List<T> fallback) {
  if (raw is! List) return fallback;
  final map = values.asNameMap();
  final out = <T>[];
  for (final e in raw) {
    final v = e is String ? map[e] : null;
    if (v != null && !out.contains(v)) out.add(v);
  }
  return out.isEmpty ? fallback : out;
}

List<String> _strings(Object? raw) => raw is List ? raw.whereType<String>().toList() : const [];

Map<String, Object?> _map(Object? raw) => raw is Map ? raw.map((k, v) => MapEntry('$k', v)) : const {};

/// Keeps every value of [all] exactly once, in the stored order first.
List<T> completeOrder<T>(List<T> stored, List<T> all) => [
  ...stored.where(all.contains),
  ...all.where((t) => !stored.contains(t)),
];

// ---------------------------------------------------------------------------
// Groups
// ---------------------------------------------------------------------------

@immutable
class AppearanceSettings {
  const AppearanceSettings({
    this.themeMode = AppThemeMode.dark,
    this.scheduleEnabled = false,
    this.darkFromMinutes = 20 * 60,
    this.darkToMinutes = 7 * 60,
    this.accentMode = AccentMode.preset,
    this.accentPreset = 0,
    this.customAccent = 0xFFFF9F1C,
    this.font = AppFont.urbanist,
    this.textScale = 1.0,
    this.boldText = false,
    this.corners = CornerStyle.medium,
    this.density = ListDensity.comfortable,
    this.artShape = ArtShape.rounded,
    this.artSize = ArtSize.medium,
    this.showListArtwork = true,
    this.playerStyle = PlayerStyle.vinyl,
    this.blurStrength = 0.6,
    this.animatedBackground = true,
    this.showNavLabels = true,
    this.navOrder = NavTab.values,
    this.hiddenNavTabs = const [],
    this.startTab = NavTab.home,
    this.homeTabOrder = HomeTab.values,
    this.startHomeTab = HomeTab.suggested,
    this.miniPlayerStyle = MiniPlayerStyle.floating,
    this.animations = AnimationLevel.full,
    this.showRemainingTime = false,
  });

  final AppThemeMode themeMode;

  /// When on, dark (or AMOLED) applies between [darkFromMinutes] and
  /// [darkToMinutes] (minutes after midnight) and light otherwise.
  final bool scheduleEnabled;
  final int darkFromMinutes;
  final int darkToMinutes;
  final AccentMode accentMode;
  final int accentPreset;
  final int customAccent;
  final AppFont font;
  final double textScale;
  final bool boldText;
  final CornerStyle corners;
  final ListDensity density;
  final ArtShape artShape;
  final ArtSize artSize;
  final bool showListArtwork;
  final PlayerStyle playerStyle;
  final double blurStrength;
  final bool animatedBackground;
  final bool showNavLabels;
  final List<NavTab> navOrder;
  final List<NavTab> hiddenNavTabs;
  final NavTab startTab;
  final List<HomeTab> homeTabOrder;
  final HomeTab startHomeTab;
  final MiniPlayerStyle miniPlayerStyle;
  final AnimationLevel animations;
  final bool showRemainingTime;

  /// Visible bottom-navigation tabs in order. Settings can never be hidden.
  List<NavTab> get visibleNavTabs => navOrder.where((t) => t == NavTab.settings || !hiddenNavTabs.contains(t)).toList();

  AppearanceSettings copyWith({
    AppThemeMode? themeMode,
    bool? scheduleEnabled,
    int? darkFromMinutes,
    int? darkToMinutes,
    AccentMode? accentMode,
    int? accentPreset,
    int? customAccent,
    AppFont? font,
    double? textScale,
    bool? boldText,
    CornerStyle? corners,
    ListDensity? density,
    ArtShape? artShape,
    ArtSize? artSize,
    bool? showListArtwork,
    PlayerStyle? playerStyle,
    double? blurStrength,
    bool? animatedBackground,
    bool? showNavLabels,
    List<NavTab>? navOrder,
    List<NavTab>? hiddenNavTabs,
    NavTab? startTab,
    List<HomeTab>? homeTabOrder,
    HomeTab? startHomeTab,
    MiniPlayerStyle? miniPlayerStyle,
    AnimationLevel? animations,
    bool? showRemainingTime,
  }) => AppearanceSettings(
    themeMode: themeMode ?? this.themeMode,
    scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
    darkFromMinutes: darkFromMinutes ?? this.darkFromMinutes,
    darkToMinutes: darkToMinutes ?? this.darkToMinutes,
    accentMode: accentMode ?? this.accentMode,
    accentPreset: accentPreset ?? this.accentPreset,
    customAccent: customAccent ?? this.customAccent,
    font: font ?? this.font,
    textScale: textScale ?? this.textScale,
    boldText: boldText ?? this.boldText,
    corners: corners ?? this.corners,
    density: density ?? this.density,
    artShape: artShape ?? this.artShape,
    artSize: artSize ?? this.artSize,
    showListArtwork: showListArtwork ?? this.showListArtwork,
    playerStyle: playerStyle ?? this.playerStyle,
    blurStrength: blurStrength ?? this.blurStrength,
    animatedBackground: animatedBackground ?? this.animatedBackground,
    showNavLabels: showNavLabels ?? this.showNavLabels,
    navOrder: navOrder ?? this.navOrder,
    hiddenNavTabs: hiddenNavTabs ?? this.hiddenNavTabs,
    startTab: startTab ?? this.startTab,
    homeTabOrder: homeTabOrder ?? this.homeTabOrder,
    startHomeTab: startHomeTab ?? this.startHomeTab,
    miniPlayerStyle: miniPlayerStyle ?? this.miniPlayerStyle,
    animations: animations ?? this.animations,
    showRemainingTime: showRemainingTime ?? this.showRemainingTime,
  );

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'scheduleEnabled': scheduleEnabled,
    'darkFromMinutes': darkFromMinutes,
    'darkToMinutes': darkToMinutes,
    'accentMode': accentMode.name,
    'accentPreset': accentPreset,
    'customAccent': customAccent,
    'font': font.name,
    'textScale': textScale,
    'boldText': boldText,
    'corners': corners.name,
    'density': density.name,
    'artShape': artShape.name,
    'artSize': artSize.name,
    'showListArtwork': showListArtwork,
    'playerStyle': playerStyle.name,
    'blurStrength': blurStrength,
    'animatedBackground': animatedBackground,
    'showNavLabels': showNavLabels,
    'navOrder': navOrder.map((e) => e.name).toList(),
    'hiddenNavTabs': hiddenNavTabs.map((e) => e.name).toList(),
    'startTab': startTab.name,
    'homeTabOrder': homeTabOrder.map((e) => e.name).toList(),
    'startHomeTab': startHomeTab.name,
    'miniPlayerStyle': miniPlayerStyle.name,
    'animations': animations.name,
    'showRemainingTime': showRemainingTime,
  };

  factory AppearanceSettings.fromJson(Map<String, Object?> j) {
    const d = AppearanceSettings();
    return AppearanceSettings(
      themeMode: _enum(AppThemeMode.values, j['themeMode'], d.themeMode),
      scheduleEnabled: _bool(j['scheduleEnabled'], d.scheduleEnabled),
      darkFromMinutes: _int(j['darkFromMinutes'], d.darkFromMinutes).clamp(0, 1439),
      darkToMinutes: _int(j['darkToMinutes'], d.darkToMinutes).clamp(0, 1439),
      accentMode: _enum(AccentMode.values, j['accentMode'], d.accentMode),
      accentPreset: _int(j['accentPreset'], d.accentPreset),
      customAccent: _int(j['customAccent'], d.customAccent),
      font: _enum(AppFont.values, j['font'], d.font),
      textScale: _double(j['textScale'], d.textScale, min: 0.8, max: 1.3),
      boldText: _bool(j['boldText'], d.boldText),
      corners: _enum(CornerStyle.values, j['corners'], d.corners),
      density: _enum(ListDensity.values, j['density'], d.density),
      artShape: _enum(ArtShape.values, j['artShape'], d.artShape),
      artSize: _enum(ArtSize.values, j['artSize'], d.artSize),
      showListArtwork: _bool(j['showListArtwork'], d.showListArtwork),
      playerStyle: _enum(PlayerStyle.values, j['playerStyle'], d.playerStyle),
      blurStrength: _double(j['blurStrength'], d.blurStrength, min: 0, max: 1),
      animatedBackground: _bool(j['animatedBackground'], d.animatedBackground),
      showNavLabels: _bool(j['showNavLabels'], d.showNavLabels),
      navOrder: completeOrder(_enumList(NavTab.values, j['navOrder'], d.navOrder), NavTab.values),
      hiddenNavTabs: _enumList(
        NavTab.values,
        j['hiddenNavTabs'],
        const <NavTab>[],
      ).where((t) => t != NavTab.settings).toList(),
      startTab: _enum(NavTab.values, j['startTab'], d.startTab),
      homeTabOrder: completeOrder(_enumList(HomeTab.values, j['homeTabOrder'], d.homeTabOrder), HomeTab.values),
      startHomeTab: _enum(HomeTab.values, j['startHomeTab'], d.startHomeTab),
      miniPlayerStyle: _enum(MiniPlayerStyle.values, j['miniPlayerStyle'], d.miniPlayerStyle),
      animations: _enum(AnimationLevel.values, j['animations'], d.animations),
      showRemainingTime: _bool(j['showRemainingTime'], d.showRemainingTime),
    );
  }
}

@immutable
class PlaybackSettings {
  const PlaybackSettings({
    this.gapless = true,
    this.crossfadeSeconds = 0,
    this.fadeOnPlayPause = true,
    this.normalizeVolume = false,
    this.skipSilence = false,
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.resumeOnHeadset = false,
    this.pauseOnDisconnect = true,
    this.resumeAfterCall = true,
    this.rememberQueue = true,
    this.autoPlayOnStart = false,
    this.addMode = AddMode.playNext,
    this.shuffleStyle = ShuffleStyle.avoidRecent,
    this.sleepFadeOut = true,
    this.shakeToExtendSleep = false,
  });

  final bool gapless;
  final int crossfadeSeconds;
  final bool fadeOnPlayPause;
  final bool normalizeVolume;
  final bool skipSilence;
  final double speed;
  final double pitch;
  final double volume;
  final bool resumeOnHeadset;
  final bool pauseOnDisconnect;
  final bool resumeAfterCall;
  final bool rememberQueue;
  final bool autoPlayOnStart;
  final AddMode addMode;
  final ShuffleStyle shuffleStyle;
  final bool sleepFadeOut;
  final bool shakeToExtendSleep;

  PlaybackSettings copyWith({
    bool? gapless,
    int? crossfadeSeconds,
    bool? fadeOnPlayPause,
    bool? normalizeVolume,
    bool? skipSilence,
    double? speed,
    double? pitch,
    double? volume,
    bool? resumeOnHeadset,
    bool? pauseOnDisconnect,
    bool? resumeAfterCall,
    bool? rememberQueue,
    bool? autoPlayOnStart,
    AddMode? addMode,
    ShuffleStyle? shuffleStyle,
    bool? sleepFadeOut,
    bool? shakeToExtendSleep,
  }) => PlaybackSettings(
    gapless: gapless ?? this.gapless,
    crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
    fadeOnPlayPause: fadeOnPlayPause ?? this.fadeOnPlayPause,
    normalizeVolume: normalizeVolume ?? this.normalizeVolume,
    skipSilence: skipSilence ?? this.skipSilence,
    speed: speed ?? this.speed,
    pitch: pitch ?? this.pitch,
    volume: volume ?? this.volume,
    resumeOnHeadset: resumeOnHeadset ?? this.resumeOnHeadset,
    pauseOnDisconnect: pauseOnDisconnect ?? this.pauseOnDisconnect,
    resumeAfterCall: resumeAfterCall ?? this.resumeAfterCall,
    rememberQueue: rememberQueue ?? this.rememberQueue,
    autoPlayOnStart: autoPlayOnStart ?? this.autoPlayOnStart,
    addMode: addMode ?? this.addMode,
    shuffleStyle: shuffleStyle ?? this.shuffleStyle,
    sleepFadeOut: sleepFadeOut ?? this.sleepFadeOut,
    shakeToExtendSleep: shakeToExtendSleep ?? this.shakeToExtendSleep,
  );

  Map<String, Object?> toJson() => {
    'gapless': gapless,
    'crossfadeSeconds': crossfadeSeconds,
    'fadeOnPlayPause': fadeOnPlayPause,
    'normalizeVolume': normalizeVolume,
    'skipSilence': skipSilence,
    'speed': speed,
    'pitch': pitch,
    'volume': volume,
    'resumeOnHeadset': resumeOnHeadset,
    'pauseOnDisconnect': pauseOnDisconnect,
    'resumeAfterCall': resumeAfterCall,
    'rememberQueue': rememberQueue,
    'autoPlayOnStart': autoPlayOnStart,
    'addMode': addMode.name,
    'shuffleStyle': shuffleStyle.name,
    'sleepFadeOut': sleepFadeOut,
    'shakeToExtendSleep': shakeToExtendSleep,
  };

  factory PlaybackSettings.fromJson(Map<String, Object?> j) {
    const d = PlaybackSettings();
    return PlaybackSettings(
      gapless: _bool(j['gapless'], d.gapless),
      crossfadeSeconds: _int(j['crossfadeSeconds'], d.crossfadeSeconds).clamp(0, 12),
      fadeOnPlayPause: _bool(j['fadeOnPlayPause'], d.fadeOnPlayPause),
      normalizeVolume: _bool(j['normalizeVolume'], d.normalizeVolume),
      skipSilence: _bool(j['skipSilence'], d.skipSilence),
      speed: _double(j['speed'], d.speed, min: 0.5, max: 2),
      pitch: _double(j['pitch'], d.pitch, min: 0.5, max: 2),
      volume: _double(j['volume'], d.volume, min: 0, max: 1),
      resumeOnHeadset: _bool(j['resumeOnHeadset'], d.resumeOnHeadset),
      pauseOnDisconnect: _bool(j['pauseOnDisconnect'], d.pauseOnDisconnect),
      resumeAfterCall: _bool(j['resumeAfterCall'], d.resumeAfterCall),
      rememberQueue: _bool(j['rememberQueue'], d.rememberQueue),
      autoPlayOnStart: _bool(j['autoPlayOnStart'], d.autoPlayOnStart),
      addMode: _enum(AddMode.values, j['addMode'], d.addMode),
      shuffleStyle: _enum(ShuffleStyle.values, j['shuffleStyle'], d.shuffleStyle),
      sleepFadeOut: _bool(j['sleepFadeOut'], d.sleepFadeOut),
      shakeToExtendSleep: _bool(j['shakeToExtendSleep'], d.shakeToExtendSleep),
    );
  }
}

@immutable
class AudioSettings {
  const AudioSettings({
    this.eqEnabled = false,
    this.eqPreset = 'normal',
    this.bandGains = const [],
    this.customPresets = const {},
    this.bassBoost = 0,
    this.loudness = 0,
  });

  final bool eqEnabled;

  /// A built-in preset id, a custom preset name, or `custom` for manual bands.
  final String eqPreset;

  /// Gain (dB) per device band; empty until the device reports its bands.
  final List<double> bandGains;
  final Map<String, List<double>> customPresets;

  /// 0..1, applied as extra gain on the lowest bands.
  final double bassBoost;

  /// 0..1, mapped to the Android loudness enhancer's target gain.
  final double loudness;

  AudioSettings copyWith({
    bool? eqEnabled,
    String? eqPreset,
    List<double>? bandGains,
    Map<String, List<double>>? customPresets,
    double? bassBoost,
    double? loudness,
  }) => AudioSettings(
    eqEnabled: eqEnabled ?? this.eqEnabled,
    eqPreset: eqPreset ?? this.eqPreset,
    bandGains: bandGains ?? this.bandGains,
    customPresets: customPresets ?? this.customPresets,
    bassBoost: bassBoost ?? this.bassBoost,
    loudness: loudness ?? this.loudness,
  );

  Map<String, Object?> toJson() => {
    'eqEnabled': eqEnabled,
    'eqPreset': eqPreset,
    'bandGains': bandGains,
    'customPresets': customPresets,
    'bassBoost': bassBoost,
    'loudness': loudness,
  };

  factory AudioSettings.fromJson(Map<String, Object?> j) {
    const d = AudioSettings();
    List<double> gains(Object? raw) =>
        raw is List ? raw.whereType<num>().map((e) => e.toDouble().clamp(-15.0, 15.0)).toList() : const [];
    return AudioSettings(
      eqEnabled: _bool(j['eqEnabled'], d.eqEnabled),
      eqPreset: j['eqPreset'] is String ? j['eqPreset']! as String : d.eqPreset,
      bandGains: gains(j['bandGains']),
      customPresets: {for (final e in _map(j['customPresets']).entries) e.key: gains(e.value)},
      bassBoost: _double(j['bassBoost'], d.bassBoost, min: 0, max: 1),
      loudness: _double(j['loudness'], d.loudness, min: 0, max: 1),
    );
  }
}

@immutable
class LibrarySettings {
  const LibrarySettings({
    this.includedFolders = const [],
    this.excludedFolders = const [],
    this.minDurationSeconds = 10,
    this.minSizeKb = 0,
    this.hideShortSounds = true,
    this.scanOnLaunch = true,
    this.splitArtists = false,
    this.groupByAlbumArtist = false,
    this.showDemoTracks = true,
  });

  /// Empty means "all folders".
  final List<String> includedFolders;
  final List<String> excludedFolders;
  final int minDurationSeconds;
  final int minSizeKb;
  final bool hideShortSounds;
  final bool scanOnLaunch;

  /// Split "A feat. B", "A & B", "A; B" into separate artists.
  final bool splitArtists;
  final bool groupByAlbumArtist;
  final bool showDemoTracks;

  LibrarySettings copyWith({
    List<String>? includedFolders,
    List<String>? excludedFolders,
    int? minDurationSeconds,
    int? minSizeKb,
    bool? hideShortSounds,
    bool? scanOnLaunch,
    bool? splitArtists,
    bool? groupByAlbumArtist,
    bool? showDemoTracks,
  }) => LibrarySettings(
    includedFolders: includedFolders ?? this.includedFolders,
    excludedFolders: excludedFolders ?? this.excludedFolders,
    minDurationSeconds: minDurationSeconds ?? this.minDurationSeconds,
    minSizeKb: minSizeKb ?? this.minSizeKb,
    hideShortSounds: hideShortSounds ?? this.hideShortSounds,
    scanOnLaunch: scanOnLaunch ?? this.scanOnLaunch,
    splitArtists: splitArtists ?? this.splitArtists,
    groupByAlbumArtist: groupByAlbumArtist ?? this.groupByAlbumArtist,
    showDemoTracks: showDemoTracks ?? this.showDemoTracks,
  );

  Map<String, Object?> toJson() => {
    'includedFolders': includedFolders,
    'excludedFolders': excludedFolders,
    'minDurationSeconds': minDurationSeconds,
    'minSizeKb': minSizeKb,
    'hideShortSounds': hideShortSounds,
    'scanOnLaunch': scanOnLaunch,
    'splitArtists': splitArtists,
    'groupByAlbumArtist': groupByAlbumArtist,
    'showDemoTracks': showDemoTracks,
  };

  factory LibrarySettings.fromJson(Map<String, Object?> j) {
    const d = LibrarySettings();
    return LibrarySettings(
      includedFolders: _strings(j['includedFolders']),
      excludedFolders: _strings(j['excludedFolders']),
      minDurationSeconds: _int(j['minDurationSeconds'], d.minDurationSeconds).clamp(0, 600),
      minSizeKb: _int(j['minSizeKb'], d.minSizeKb).clamp(0, 100000),
      hideShortSounds: _bool(j['hideShortSounds'], d.hideShortSounds),
      scanOnLaunch: _bool(j['scanOnLaunch'], d.scanOnLaunch),
      splitArtists: _bool(j['splitArtists'], d.splitArtists),
      groupByAlbumArtist: _bool(j['groupByAlbumArtist'], d.groupByAlbumArtist),
      showDemoTracks: _bool(j['showDemoTracks'], d.showDemoTracks),
    );
  }
}

@immutable
class LyricsSettings {
  const LyricsSettings({
    this.fontSize = 18,
    this.align = LyricsAlign.start,
    this.offsetMs = 0,
    this.keepScreenOn = false,
    this.autoScroll = true,
  });

  final double fontSize;
  final LyricsAlign align;

  /// Positive shows lines later, negative earlier.
  final int offsetMs;
  final bool keepScreenOn;
  final bool autoScroll;

  LyricsSettings copyWith({
    double? fontSize,
    LyricsAlign? align,
    int? offsetMs,
    bool? keepScreenOn,
    bool? autoScroll,
  }) => LyricsSettings(
    fontSize: fontSize ?? this.fontSize,
    align: align ?? this.align,
    offsetMs: offsetMs ?? this.offsetMs,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    autoScroll: autoScroll ?? this.autoScroll,
  );

  Map<String, Object?> toJson() => {
    'fontSize': fontSize,
    'align': align.name,
    'offsetMs': offsetMs,
    'keepScreenOn': keepScreenOn,
    'autoScroll': autoScroll,
  };

  factory LyricsSettings.fromJson(Map<String, Object?> j) {
    const d = LyricsSettings();
    return LyricsSettings(
      fontSize: _double(j['fontSize'], d.fontSize, min: 12, max: 32),
      align: _enum(LyricsAlign.values, j['align'], d.align),
      offsetMs: _int(j['offsetMs'], d.offsetMs).clamp(-10000, 10000),
      keepScreenOn: _bool(j['keepScreenOn'], d.keepScreenOn),
      autoScroll: _bool(j['autoScroll'], d.autoScroll),
    );
  }
}

@immutable
class NotificationSettings {
  const NotificationSettings({
    this.showArtwork = true,
    this.showCloseButton = true,
    this.showFavoriteButton = true,
    this.compactSkipButtons = true,
    this.singlePress = HeadsetAction.playPause,
    this.doublePress = HeadsetAction.next,
    this.triplePress = HeadsetAction.previous,
  });

  final bool showArtwork;
  final bool showCloseButton;

  /// Like / unlike the current track straight from the notification.
  final bool showFavoriteButton;

  /// Show previous/next in the collapsed notification, not just play/pause.
  final bool compactSkipButtons;
  final HeadsetAction singlePress;
  final HeadsetAction doublePress;
  final HeadsetAction triplePress;

  NotificationSettings copyWith({
    bool? showArtwork,
    bool? showCloseButton,
    bool? showFavoriteButton,
    bool? compactSkipButtons,
    HeadsetAction? singlePress,
    HeadsetAction? doublePress,
    HeadsetAction? triplePress,
  }) => NotificationSettings(
    showArtwork: showArtwork ?? this.showArtwork,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    showFavoriteButton: showFavoriteButton ?? this.showFavoriteButton,
    compactSkipButtons: compactSkipButtons ?? this.compactSkipButtons,
    singlePress: singlePress ?? this.singlePress,
    doublePress: doublePress ?? this.doublePress,
    triplePress: triplePress ?? this.triplePress,
  );

  Map<String, Object?> toJson() => {
    'showArtwork': showArtwork,
    'showCloseButton': showCloseButton,
    'showFavoriteButton': showFavoriteButton,
    'compactSkipButtons': compactSkipButtons,
    'singlePress': singlePress.name,
    'doublePress': doublePress.name,
    'triplePress': triplePress.name,
  };

  factory NotificationSettings.fromJson(Map<String, Object?> j) {
    const d = NotificationSettings();
    return NotificationSettings(
      showArtwork: _bool(j['showArtwork'], d.showArtwork),
      showCloseButton: _bool(j['showCloseButton'], d.showCloseButton),
      showFavoriteButton: _bool(j['showFavoriteButton'], d.showFavoriteButton),
      compactSkipButtons: _bool(j['compactSkipButtons'], d.compactSkipButtons),
      singlePress: _enum(HeadsetAction.values, j['singlePress'], d.singlePress),
      doublePress: _enum(HeadsetAction.values, j['doublePress'], d.doublePress),
      triplePress: _enum(HeadsetAction.values, j['triplePress'], d.triplePress),
    );
  }
}

@immutable
class GestureSettings {
  const GestureSettings({
    this.miniPlayerSwipe = true,
    this.doubleTapArtwork = true,
    this.swipeArtwork = true,
    this.shakeToSkip = false,
    this.shakeSensitivity = 0.5,
    this.volumeKeySeek = false,
    this.haptics = true,
  });

  final bool miniPlayerSwipe;
  final bool doubleTapArtwork;
  final bool swipeArtwork;
  final bool shakeToSkip;
  final double shakeSensitivity;
  final bool volumeKeySeek;
  final bool haptics;

  GestureSettings copyWith({
    bool? miniPlayerSwipe,
    bool? doubleTapArtwork,
    bool? swipeArtwork,
    bool? shakeToSkip,
    double? shakeSensitivity,
    bool? volumeKeySeek,
    bool? haptics,
  }) => GestureSettings(
    miniPlayerSwipe: miniPlayerSwipe ?? this.miniPlayerSwipe,
    doubleTapArtwork: doubleTapArtwork ?? this.doubleTapArtwork,
    swipeArtwork: swipeArtwork ?? this.swipeArtwork,
    shakeToSkip: shakeToSkip ?? this.shakeToSkip,
    shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
    volumeKeySeek: volumeKeySeek ?? this.volumeKeySeek,
    haptics: haptics ?? this.haptics,
  );

  Map<String, Object?> toJson() => {
    'miniPlayerSwipe': miniPlayerSwipe,
    'doubleTapArtwork': doubleTapArtwork,
    'swipeArtwork': swipeArtwork,
    'shakeToSkip': shakeToSkip,
    'shakeSensitivity': shakeSensitivity,
    'volumeKeySeek': volumeKeySeek,
    'haptics': haptics,
  };

  factory GestureSettings.fromJson(Map<String, Object?> j) {
    const d = GestureSettings();
    return GestureSettings(
      miniPlayerSwipe: _bool(j['miniPlayerSwipe'], d.miniPlayerSwipe),
      doubleTapArtwork: _bool(j['doubleTapArtwork'], d.doubleTapArtwork),
      swipeArtwork: _bool(j['swipeArtwork'], d.swipeArtwork),
      shakeToSkip: _bool(j['shakeToSkip'], d.shakeToSkip),
      shakeSensitivity: _double(j['shakeSensitivity'], d.shakeSensitivity, min: 0, max: 1),
      volumeKeySeek: _bool(j['volumeKeySeek'], d.volumeKeySeek),
      haptics: _bool(j['haptics'], d.haptics),
    );
  }
}

@immutable
class AccessibilitySettings {
  const AccessibilitySettings({this.highContrast = false});

  final bool highContrast;

  AccessibilitySettings copyWith({bool? highContrast}) =>
      AccessibilitySettings(highContrast: highContrast ?? this.highContrast);

  Map<String, Object?> toJson() => {'highContrast': highContrast};

  factory AccessibilitySettings.fromJson(Map<String, Object?> j) =>
      AccessibilitySettings(highContrast: _bool(j['highContrast'], false));
}

@immutable
class PrivacySettings {
  const PrivacySettings({this.collectStats = true, this.saveSearchHistory = true});

  /// Local listening statistics (never leave the device).
  final bool collectStats;
  final bool saveSearchHistory;

  PrivacySettings copyWith({bool? collectStats, bool? saveSearchHistory}) => PrivacySettings(
    collectStats: collectStats ?? this.collectStats,
    saveSearchHistory: saveSearchHistory ?? this.saveSearchHistory,
  );

  Map<String, Object?> toJson() => {'collectStats': collectStats, 'saveSearchHistory': saveSearchHistory};

  factory PrivacySettings.fromJson(Map<String, Object?> j) => PrivacySettings(
    collectStats: _bool(j['collectStats'], true),
    saveSearchHistory: _bool(j['saveSearchHistory'], true),
  );
}

// ---------------------------------------------------------------------------
// Root
// ---------------------------------------------------------------------------

@immutable
class AppSettings {
  const AppSettings({
    this.languageCode,
    this.appearance = const AppearanceSettings(),
    this.playback = const PlaybackSettings(),
    this.audio = const AudioSettings(),
    this.library = const LibrarySettings(),
    this.lyrics = const LyricsSettings(),
    this.notifications = const NotificationSettings(),
    this.gestures = const GestureSettings(),
    this.accessibility = const AccessibilitySettings(),
    this.privacy = const PrivacySettings(),
  });

  /// Bump when the stored shape changes and add a step to `migrateSettings`.
  static const schemaVersion = 1;

  /// `null` follows the device language.
  final String? languageCode;
  final AppearanceSettings appearance;
  final PlaybackSettings playback;
  final AudioSettings audio;
  final LibrarySettings library;
  final LyricsSettings lyrics;
  final NotificationSettings notifications;
  final GestureSettings gestures;
  final AccessibilitySettings accessibility;
  final PrivacySettings privacy;

  AppSettings copyWith({
    String? Function()? languageCode,
    AppearanceSettings? appearance,
    PlaybackSettings? playback,
    AudioSettings? audio,
    LibrarySettings? library,
    LyricsSettings? lyrics,
    NotificationSettings? notifications,
    GestureSettings? gestures,
    AccessibilitySettings? accessibility,
    PrivacySettings? privacy,
  }) => AppSettings(
    languageCode: languageCode != null ? languageCode() : this.languageCode,
    appearance: appearance ?? this.appearance,
    playback: playback ?? this.playback,
    audio: audio ?? this.audio,
    library: library ?? this.library,
    lyrics: lyrics ?? this.lyrics,
    notifications: notifications ?? this.notifications,
    gestures: gestures ?? this.gestures,
    accessibility: accessibility ?? this.accessibility,
    privacy: privacy ?? this.privacy,
  );

  Map<String, Object?> toJson() => {
    'version': schemaVersion,
    'languageCode': languageCode,
    'appearance': appearance.toJson(),
    'playback': playback.toJson(),
    'audio': audio.toJson(),
    'library': library.toJson(),
    'lyrics': lyrics.toJson(),
    'notifications': notifications.toJson(),
    'gestures': gestures.toJson(),
    'accessibility': accessibility.toJson(),
    'privacy': privacy.toJson(),
  };

  factory AppSettings.fromJson(Map<String, Object?> j) {
    final lang = j['languageCode'];
    return AppSettings(
      languageCode: lang is String && const {'uz', 'ru', 'en'}.contains(lang) ? lang : null,
      appearance: AppearanceSettings.fromJson(_map(j['appearance'])),
      playback: PlaybackSettings.fromJson(_map(j['playback'])),
      audio: AudioSettings.fromJson(_map(j['audio'])),
      library: LibrarySettings.fromJson(_map(j['library'])),
      lyrics: LyricsSettings.fromJson(_map(j['lyrics'])),
      notifications: NotificationSettings.fromJson(_map(j['notifications'])),
      gestures: GestureSettings.fromJson(_map(j['gestures'])),
      accessibility: AccessibilitySettings.fromJson(_map(j['accessibility'])),
      privacy: PrivacySettings.fromJson(_map(j['privacy'])),
    );
  }
}

/// Upgrades stored settings JSON to [AppSettings.schemaVersion].
///
/// [legacy] holds the individual keys written by app version 1.0 (before the
/// typed model existed); they're folded in when no versioned data is present.
Map<String, Object?> migrateSettings(Map<String, Object?>? stored, {Map<String, Object?> legacy = const {}}) {
  if (stored == null || stored.isEmpty) {
    // Version 0 → 1: individual keys from app 1.0.
    final style = legacy['artwork_style'];
    return {
      'version': 1,
      'languageCode': legacy['locale'],
      'appearance': {if (style == 'square') 'playerStyle': PlayerStyle.classic.name},
      'playback': {'speed': ?legacy['speed'], 'volume': ?legacy['volume']},
      'library': {'showDemoTracks': ?legacy['show_demo']},
    };
  }
  final version = stored['version'];
  var json = Map<String, Object?>.from(stored);
  if (version is! int || version < 1) json['version'] = 1;
  // Future steps go here, e.g. `if (v < 2) json = _v1ToV2(json);`
  return json;
}
