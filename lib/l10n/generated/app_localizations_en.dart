// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Navo';

  @override
  String get appTagline => 'Your music, offline';

  @override
  String get onboardingTitle1 =>
      'A friendly player for all the music on your device';

  @override
  String get onboardingTitle2 => 'Clear, rich sound tuned for every listen';

  @override
  String get onboardingTitle3 => 'Listen to the music you love with Navo';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get tabSuggested => 'Suggested';

  @override
  String get tabSongs => 'Songs';

  @override
  String get tabArtists => 'Artists';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabFolders => 'Folders';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get seeAll => 'See All';

  @override
  String get songs => 'Songs';

  @override
  String get search => 'Search';

  @override
  String songsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString songs',
      one: '1 song',
      zero: 'No songs',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString albums',
      one: '1 album',
      zero: 'No albums',
    );
    return '$_temp0';
  }

  @override
  String artistsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString artists',
      one: '1 artist',
      zero: 'No artists',
    );
    return '$_temp0';
  }

  @override
  String foldersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString folders',
      one: '1 folder',
      zero: 'No folders',
    );
    return '$_temp0';
  }

  @override
  String playlistsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString playlists',
      one: '1 playlist',
      zero: 'No playlists',
    );
    return '$_temp0';
  }

  @override
  String durationMins(String time) {
    return '$time mins';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortYear => 'Year';

  @override
  String get sortDateAdded => 'Date Added';

  @override
  String get sortDateModified => 'Date Modified';

  @override
  String get sortComposer => 'Composer';

  @override
  String get sortSongCount => 'Number of Songs';

  @override
  String get sortAlbumCount => 'Number of Albums';

  @override
  String get play => 'Play';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get playNext => 'Play Next';

  @override
  String get addToQueue => 'Add to Playing Queue';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get goToAlbum => 'Go to Album';

  @override
  String get goToArtist => 'Go to Artist';

  @override
  String get details => 'Details';

  @override
  String get setAsRingtone => 'Set as Ringtone';

  @override
  String get addToBlocklist => 'Add to Blocklist';

  @override
  String get share => 'Share';

  @override
  String get deleteFromDevice => 'Delete from Device';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String get removeFromQueue => 'Remove from Queue';

  @override
  String get more => 'More';

  @override
  String get songDetails => 'Song details';

  @override
  String get detailTitle => 'Title';

  @override
  String get detailArtist => 'Artist';

  @override
  String get detailAlbum => 'Album';

  @override
  String get detailComposer => 'Composer';

  @override
  String get detailGenre => 'Genre';

  @override
  String get detailYear => 'Year';

  @override
  String get detailDuration => 'Duration';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailSize => 'Size';

  @override
  String get detailPath => 'Location';

  @override
  String get detailDateAdded => 'Date added';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get demoTrack => 'Demo';

  @override
  String get close => 'Close';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get noLyrics => 'No lyrics found';

  @override
  String get noLyricsHint =>
      'Put an .lrc file with the same name next to the song, or embed lyrics in its tags.';

  @override
  String get playingQueue => 'Playing Queue';

  @override
  String get queueEmpty => 'The queue is empty';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepTimerEndOfTrack => 'End of current song';

  @override
  String get sleepTimerOff => 'Turn off timer';

  @override
  String sleepTimerRemaining(String time) {
    return 'Stops in $time';
  }

  @override
  String sleepTimerSet(String minutes) {
    return 'Playback will stop in $minutes';
  }

  @override
  String get sleepTimerEndSet => 'Playback will stop after this song';

  @override
  String get audioOutput => 'Audio output';

  @override
  String get audioOutputUnavailable =>
      'Couldn\'t open the output picker on this device';

  @override
  String get volume => 'Volume';

  @override
  String get repeatOff => 'Repeat off';

  @override
  String get repeatAll => 'Repeat all';

  @override
  String get repeatOne => 'Repeat one';

  @override
  String get shuffleOn => 'Shuffle on';

  @override
  String get shuffleOff => 'Shuffle off';

  @override
  String get previous => 'Previous';

  @override
  String get pause => 'Pause';

  @override
  String get rewind10 => 'Back 10 seconds';

  @override
  String get forward10 => 'Forward 10 seconds';

  @override
  String get back => 'Back';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoritesHint => 'Tap the heart on any song to keep it here.';

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get removedFromFavorites => 'Removed from Favorites';

  @override
  String get playlists => 'Playlists';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get renamePlaylist => 'Rename playlist';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistMessage(String name) {
    return '“$name” will be removed. The songs stay on your device.';
  }

  @override
  String get noPlaylists => 'No playlists yet';

  @override
  String get noPlaylistsHint =>
      'Create a playlist to group the songs you love.';

  @override
  String get emptyPlaylist => 'This playlist is empty';

  @override
  String get emptyPlaylistHint =>
      'Add songs from the song menu: ⋮ → Add to Playlist.';

  @override
  String addedToPlaylist(String name) {
    return 'Added to “$name”';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Already in “$name”';
  }

  @override
  String get playlistNameEmpty => 'Enter a name';

  @override
  String get searchHint => 'Search songs, artists, albums';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearAll => 'Clear All';

  @override
  String noResults(String query) {
    return 'Nothing found for “$query”';
  }

  @override
  String get searchEmptyHint =>
      'Find any song, artist or album on your device.';

  @override
  String get nothingPlayedYet => 'Nothing played yet';

  @override
  String get nothingPlayedHint => 'Songs you listen to will show up here.';

  @override
  String get noArtists => 'No artists found';

  @override
  String get noAlbums => 'No albums found';

  @override
  String get noFolders => 'No folders found';

  @override
  String get permissionTitle => 'Allow access to your music';

  @override
  String get permissionMessage =>
      'Navo needs permission to find audio files on your device. The demo tracks work without it.';

  @override
  String get permissionDeniedMessage =>
      'Access was denied. You can enable it in the system settings.';

  @override
  String get allowAccess => 'Allow access';

  @override
  String get openSettings => 'Open settings';

  @override
  String get noSongsTitle => 'No songs found';

  @override
  String get noSongsMessage =>
      'Copy some music to your device, or enjoy the demo tracks.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get retry => 'Try again';

  @override
  String get addedToQueue => 'Added to the playing queue';

  @override
  String get willPlayNext => 'Will play next';

  @override
  String get addedToBlocklist => 'Hidden from your library';

  @override
  String get undo => 'Undo';

  @override
  String get ringtoneSet => 'Ringtone set';

  @override
  String get ringtoneNeedsPermission =>
      'Allow Navo to modify system settings, then try again.';

  @override
  String get actionFailed => 'Couldn\'t complete the action';

  @override
  String get songDeleted => 'Song deleted';

  @override
  String get deleteSongTitle => 'Delete from device?';

  @override
  String deleteSongMessage(String title) {
    return '“$title” will be permanently deleted from your device.';
  }

  @override
  String get notAvailableForDemo => 'Not available for demo tracks';

  @override
  String get settings => 'Settings';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionPlayback => 'Playback';

  @override
  String get sectionLibrary => 'Library';

  @override
  String get sectionAbout => 'About';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get artworkStyle => 'Player artwork';

  @override
  String get artworkVinyl => 'Vinyl (rotating)';

  @override
  String get artworkSquare => 'Square';

  @override
  String get showDemoTracks => 'Show demo tracks';

  @override
  String get blockedSongs => 'Blocked songs';

  @override
  String get blockedSongsEmpty => 'No blocked songs';

  @override
  String get unblock => 'Unblock';

  @override
  String get rescanLibrary => 'Rescan library';

  @override
  String get libraryRescanned => 'Library updated';

  @override
  String get showOnboarding => 'Show introduction again';

  @override
  String get about => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get designedBy => 'Designed and developed by Feruzbek Namozboyev';

  @override
  String get aboutBio => 'Flutter developer';

  @override
  String get contactTelegram => 'Telegram';

  @override
  String get madeWithFlutter => 'Made with Flutter';

  @override
  String copyright(int year) {
    return '© $year Feruzbek Namozboyev';
  }

  @override
  String get linkOpenFailed => 'Couldn\'t open the link';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String cannotPlayFile(String title) {
    return 'Can\'t play “$title”. Skipping to the next song.';
  }

  @override
  String get cannotPlayUnknown => 'This file can\'t be played.';

  @override
  String get notificationChannelName => 'Playback';

  @override
  String get notificationsDeniedMessage =>
      'Allow notifications to control playback from the notification shade and lock screen.';

  @override
  String get backgroundPlayback => 'Background playback';

  @override
  String get backgroundPlaybackHint =>
      'If music stops when the screen is off, allow Navo to run without battery restrictions.';

  @override
  String get batterySettings => 'Battery settings';

  @override
  String get later => 'Later';

  @override
  String get contactYouTube => 'YouTube';

  @override
  String get youtubeChannel => 'Feruzbek Namozboyev channel';

  @override
  String get settingsSearchHint => 'Search settings';

  @override
  String get resetAll => 'Reset all settings';

  @override
  String get resetAllTitle => 'Reset all settings?';

  @override
  String get resetAllMessage =>
      'Every setting goes back to its default. Your music, playlists and favorites are kept.';

  @override
  String get resetGroup => 'Reset to defaults';

  @override
  String resetGroupTitle(String group) {
    return 'Reset “$group”?';
  }

  @override
  String get resetGroupMessage =>
      'Settings in this section go back to their defaults.';

  @override
  String get reset => 'Reset';

  @override
  String get settingsRestored => 'Settings restored to defaults';

  @override
  String noSettingsFound(String query) {
    return 'No settings match “$query”';
  }

  @override
  String get groupAppearance => 'Appearance';

  @override
  String get groupPlayer => 'Player';

  @override
  String get groupPlayback => 'Playback';

  @override
  String get groupAudio => 'Audio & Equalizer';

  @override
  String get groupLibrary => 'Library';

  @override
  String get groupLyrics => 'Lyrics';

  @override
  String get groupNotifications => 'Notifications';

  @override
  String get groupGestures => 'Gestures';

  @override
  String get groupStorage => 'Storage & Backup';

  @override
  String get groupAccessibility => 'Accessibility';

  @override
  String get groupPrivacy => 'Privacy';

  @override
  String get appearanceSubtitle => 'Theme, colors, fonts, layout';

  @override
  String get librarySubtitle => 'Demo tracks, hidden songs, scanning';

  @override
  String get languageSubtitle => 'Oʻzbekcha, Русский, English';

  @override
  String get accessibilitySubtitle => 'Contrast, text size, motion';

  @override
  String get privacySubtitle => 'Offline, no tracking';

  @override
  String get playbackSubtitle => 'Crossfade, speed, behavior, sleep timer';

  @override
  String get aboutSubtitle => 'Version, author, licenses';

  @override
  String get sectionTheme => 'Theme';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAmoled => 'AMOLED black';

  @override
  String get themeSchedule => 'Dark theme on a schedule';

  @override
  String get themeScheduleHint => 'Light during the day, dark at night';

  @override
  String get darkFrom => 'Dark from';

  @override
  String get darkUntil => 'Dark until';

  @override
  String get sectionColor => 'Accent color';

  @override
  String get accentSource => 'Color source';

  @override
  String get accentPreset => 'Palette';

  @override
  String get accentCustom => 'Custom';

  @override
  String get accentMaterialYou => 'Material You (wallpaper)';

  @override
  String get accentAdaptive => 'From album art';

  @override
  String get materialYouUnavailable =>
      'Needs Android 12 or newer; using the palette color.';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get lightness => 'Brightness';

  @override
  String get sectionText => 'Text';

  @override
  String get font => 'Font';

  @override
  String get textSize => 'Text size';

  @override
  String get boldText => 'Bold text';

  @override
  String get sectionLayout => 'Layout';

  @override
  String get corners => 'Corners';

  @override
  String get cornersSharp => 'Sharp';

  @override
  String get cornersMedium => 'Medium';

  @override
  String get cornersRound => 'Round';

  @override
  String get density => 'List density';

  @override
  String get densityCompact => 'Compact';

  @override
  String get densityComfortable => 'Comfortable';

  @override
  String get densitySpacious => 'Spacious';

  @override
  String get artShape => 'Artwork shape';

  @override
  String get shapeRounded => 'Rounded';

  @override
  String get shapeCircle => 'Circle';

  @override
  String get artSize => 'Artwork size';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get showListArtwork => 'Show artwork in lists';

  @override
  String get sectionPlayerLook => 'Player screen';

  @override
  String get playerStyle => 'Player style';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleBlurred => 'Blurred artwork';

  @override
  String get blurStrength => 'Blur strength';

  @override
  String get animatedBackground => 'Animated background';

  @override
  String get sectionNavigation => 'Navigation';

  @override
  String get showNavLabels => 'Show tab labels';

  @override
  String get navTabs => 'Bottom tabs';

  @override
  String get navTabsHint => 'Drag to reorder, untick to hide';

  @override
  String get startTab => 'Start tab';

  @override
  String get homeTabs => 'Home tabs';

  @override
  String get startHomeTab => 'Default Home tab';

  @override
  String get miniPlayerStyle => 'Mini player';

  @override
  String get miniFloating => 'Floating';

  @override
  String get miniDocked => 'Docked';

  @override
  String get sectionMotion => 'Motion';

  @override
  String get animations => 'Animations';

  @override
  String get animFull => 'Full';

  @override
  String get animReduced => 'Reduced';

  @override
  String get animOff => 'Off';

  @override
  String get systemReduceMotion =>
      'The system “remove animations” setting is on, so motion stays reduced.';

  @override
  String get preview => 'Preview';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastHint => 'Stronger text and outlines';

  @override
  String get privacyStatement =>
      'Navo works fully offline. It has no ads, no analytics and no tracking. Your music, playlists and listening history stay on this device and are never sent anywhere.';

  @override
  String get saveSearchHistory => 'Remember recent searches';

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get aboutNavo => 'About Navo';

  @override
  String get playerSubtitle => 'Style, background, seek bar';

  @override
  String get audioSubtitle => 'Equalizer, bass boost, loudness';

  @override
  String get showRemainingTime => 'Show remaining time';

  @override
  String get sectionTransitions => 'Transitions';

  @override
  String get crossfade => 'Crossfade';

  @override
  String get crossfadeHint => 'Fades the end of a song out and the next one in';

  @override
  String secondsShort(int n) {
    return '$n s';
  }

  @override
  String get off => 'Off';

  @override
  String get fadeOnPlayPause => 'Fade on play and pause';

  @override
  String get skipSilence => 'Skip silence';

  @override
  String get normalizeVolume => 'Volume normalization (ReplayGain)';

  @override
  String get normalizeHint => 'Uses ReplayGain tags when a file has them';

  @override
  String get pitch => 'Pitch';

  @override
  String get resetValue => 'Reset';

  @override
  String get sectionBehavior => 'Behavior';

  @override
  String get resumeAfterCall => 'Resume after a call';

  @override
  String get pauseOnDisconnect => 'Pause when headphones disconnect';

  @override
  String get resumeOnHeadset => 'Resume when headphones connect';

  @override
  String get rememberQueue => 'Remember queue and position';

  @override
  String get autoPlayOnStart => 'Play automatically on start';

  @override
  String get addMode => 'Default “add to queue”';

  @override
  String get addToEnd => 'Add to end of queue';

  @override
  String get shuffleStyle => 'Shuffle';

  @override
  String get shuffleRandom => 'Truly random';

  @override
  String get shuffleAvoidRecent => 'Avoid recently played';

  @override
  String get sectionSleep => 'Sleep timer';

  @override
  String get sleepFadeOut => 'Fade out before stopping';

  @override
  String get shakeToExtend => 'Shake to add 10 minutes';

  @override
  String get sleepExtended => 'Sleep timer extended by 10 minutes';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get eqEnabled => 'Enable equalizer';

  @override
  String get presets => 'Presets';

  @override
  String get eqNormal => 'Normal';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqTreble => 'Treble';

  @override
  String get eqRock => 'Rock';

  @override
  String get eqPop => 'Pop';

  @override
  String get eqJazz => 'Jazz';

  @override
  String get eqClassical => 'Classical';

  @override
  String get eqVocal => 'Vocal';

  @override
  String get eqCustom => 'Custom';

  @override
  String get savePreset => 'Save as preset';

  @override
  String get presetName => 'Preset name';

  @override
  String get deletePreset => 'Delete preset';

  @override
  String get bassBoost => 'Bass boost';

  @override
  String get loudnessBoost => 'Loudness boost';

  @override
  String get eqUnavailable => 'The equalizer isn’t available on this device.';

  @override
  String get eqStartPlayback => 'Start playing a song to adjust the bands.';

  @override
  String hz(String value) {
    return '$value Hz';
  }

  @override
  String khz(String value) {
    return '$value kHz';
  }

  @override
  String db(String value) {
    return '$value dB';
  }

  @override
  String get abRepeat => 'A–B repeat';

  @override
  String get abSetA => 'Set point A';

  @override
  String get abSetB => 'Set point B';

  @override
  String get abClear => 'Turn off A–B repeat';

  @override
  String queueRemoved(String title) {
    return 'Removed “$title”';
  }

  @override
  String get clearQueue => 'Clear upcoming';

  @override
  String get queueCleared => 'Upcoming songs cleared';

  @override
  String get saveQueueAsPlaylist => 'Save as playlist';

  @override
  String get editTags => 'Edit tags';

  @override
  String get changeArtwork => 'Change artwork';

  @override
  String get removeArtwork => 'Remove artwork';

  @override
  String get tagsSaved => 'Tags saved';

  @override
  String get tagsNotSupported => 'This file can’t be edited';

  @override
  String get tagsFailed => 'Couldn’t save the tags';

  @override
  String get yearInvalid => 'Enter a valid year';

  @override
  String get smartPlaylists => 'Smart playlists';

  @override
  String get myPlaylists => 'My playlists';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get neverPlayed => 'Never Played';

  @override
  String get importM3u => 'Import M3U playlist';

  @override
  String get exportM3u => 'Export as M3U';

  @override
  String m3uImported(String name, String songs) {
    return 'Imported “$name”: $songs';
  }

  @override
  String get m3uNoMatches =>
      'None of the playlist’s songs were found on this device';

  @override
  String get m3uExported => 'Playlist exported';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String deleteSongsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count songs from device?',
      one: 'Delete 1 song from device?',
    );
    return '$_temp0';
  }

  @override
  String get deleteSongsMessage =>
      'The selected files will be permanently deleted from your device.';

  @override
  String songsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs deleted',
      one: '1 song deleted',
    );
    return '$_temp0';
  }

  @override
  String get addedToFavoritesMany => 'Added to Favorites';

  @override
  String get queueAction => 'Queue';

  @override
  String get sectionFolders => 'Folders';

  @override
  String get libraryFolders => 'Library folders';

  @override
  String get libraryFoldersHint =>
      'Choose which folders appear in your library';

  @override
  String get folderShown => 'Shown';

  @override
  String get folderHidden => 'Hidden';

  @override
  String get folderOnly => 'Only these';

  @override
  String get folderOnlyActive => 'Only folders marked “Only these” are shown';

  @override
  String get resetFolders => 'Show all folders';

  @override
  String foldersSummary(int hidden) {
    return '$hidden hidden';
  }

  @override
  String get allFoldersShown => 'All folders shown';

  @override
  String get sectionFilters => 'Filters';

  @override
  String get minDuration => 'Minimum song length';

  @override
  String get minSize => 'Minimum file size';

  @override
  String kbValue(int n) {
    return '$n KB';
  }

  @override
  String get hideShortSounds => 'Hide ringtones and notification sounds';

  @override
  String get sectionScanning => 'Scanning';

  @override
  String get scanOnLaunch => 'Scan for new music on launch';

  @override
  String get scanning => 'Scanning your music…';

  @override
  String scanFound(String songs) {
    return 'Library updated: $songs';
  }

  @override
  String get sectionGrouping => 'Grouping';

  @override
  String get splitArtists => 'Split multiple artists';

  @override
  String get splitArtistsHint =>
      'Treat “A feat. B”, “A & B” and “A; B” as separate artists';

  @override
  String get groupByAlbumArtist => 'Group by album artist';

  @override
  String get lyricsSubtitle => 'Text size, alignment, timing';

  @override
  String get notificationsSubtitle => 'Notification buttons, headset button';

  @override
  String get lyricsFontSize => 'Lyrics text size';

  @override
  String get lyricsAlign => 'Alignment';

  @override
  String get alignStart => 'Left';

  @override
  String get alignCenter => 'Centered';

  @override
  String get lyricsOffset => 'Timing offset';

  @override
  String get lyricsOffsetHint =>
      'Use it when synced lyrics run ahead or behind';

  @override
  String offsetSeconds(String value) {
    return '$value s';
  }

  @override
  String get keepScreenOn => 'Keep screen on while lyrics are open';

  @override
  String get autoScrollLyrics => 'Follow the current line';

  @override
  String get lyricsSmaller => 'Smaller text';

  @override
  String get lyricsLarger => 'Larger text';

  @override
  String get lyricsEarlier => 'Show lyrics earlier';

  @override
  String get lyricsLater => 'Show lyrics later';

  @override
  String get sectionNotification => 'Media notification';

  @override
  String get notifArtwork => 'Show album art';

  @override
  String get notifCloseButton => 'Show close button';

  @override
  String get notifFavoriteButton => 'Favorite button';

  @override
  String get notifCompactSkip => 'Previous and next in compact view';

  @override
  String get notificationPermission => 'Notification permission';

  @override
  String get notificationPermissionHint =>
      'Needed for controls in the notification shade on Android 13+';

  @override
  String get sectionHeadset => 'Headset button';

  @override
  String get pressSingle => 'Single press';

  @override
  String get pressDouble => 'Double press';

  @override
  String get pressTriple => 'Triple press';

  @override
  String get actionPlayPause => 'Play / pause';

  @override
  String get actionNext => 'Next song';

  @override
  String get actionPrevious => 'Previous song';

  @override
  String get actionNone => 'Do nothing';

  @override
  String get sectionWidget => 'Home screen widget';

  @override
  String get widgetHint =>
      'Long-press your home screen, choose Widgets and add Navo.';

  @override
  String get widgetNothingPlaying => 'Nothing playing';

  @override
  String get gesturesSubtitle => 'Mini player swipe, haptics';

  @override
  String get gestureMiniSwipe => 'Swipe mini player for next / previous';

  @override
  String get gestureDoubleTap => 'Double-tap artwork to play / pause';

  @override
  String get gestureSwipeArtwork => 'Swipe artwork to change song';

  @override
  String get gestureShake => 'Shake to skip';

  @override
  String get gestureShakeSensitivity => 'Shake sensitivity';

  @override
  String get gestureVolumeSeek => 'Volume buttons seek in the player';

  @override
  String get gestureVolumeSeekHint =>
      'While the player is open: up = +10 s, down = −10 s';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get stats => 'Listening statistics';

  @override
  String get statsSubtitle => 'Stored only on this device';

  @override
  String get statsTotal => 'Total listening time';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsLast7Days => 'Last 7 days';

  @override
  String get statsTopSongs => 'Top songs';

  @override
  String get statsTopArtists => 'Top artists';

  @override
  String get statsTopAlbums => 'Top albums';

  @override
  String get statsEmpty => 'No listening data yet';

  @override
  String get statsEmptyHint =>
      'Play some music and come back to see your stats.';

  @override
  String get statsDisabled => 'Statistics are turned off in Privacy settings.';

  @override
  String get collectStats => 'Collect listening statistics';

  @override
  String get clearStats => 'Clear statistics';

  @override
  String get clearStatsTitle => 'Clear listening statistics?';

  @override
  String get clearStatsMessage =>
      'Listening time, top lists and play counts will be reset.';

  @override
  String get statsCleared => 'Statistics cleared';

  @override
  String hoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String minutesOnly(int m) {
    return '$m min';
  }

  @override
  String dayMinutes(String day, String minutes) {
    return '$day: $minutes';
  }

  @override
  String get filterAll => 'All';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get advancedSettings => 'Advanced';

  @override
  String advancedSettingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more settings',
      one: '1 more setting',
    );
    return '$_temp0';
  }

  @override
  String get storageSubtitle =>
      'Back up and restore settings, favorites, playlists';

  @override
  String get backupExport => 'Create backup';

  @override
  String get backupExportHint =>
      'Settings, favorites, playlists and hidden songs to a file';

  @override
  String get backupImport => 'Restore from backup';

  @override
  String get backupImportHint =>
      'Replaces current settings, favorites and playlists';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupInvalid => 'This file is not a Navo backup';

  @override
  String get restoreBackupTitle => 'Restore backup?';

  @override
  String get restoreBackupMessage =>
      'Your current settings, favorites and playlists will be replaced.';
}
