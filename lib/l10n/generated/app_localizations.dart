import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Navo'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your music, offline'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'A friendly player for all the music on your device'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Clear, rich sound tuned for every listen'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Listen to the music you love with Navo'**
  String get onboardingTitle3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @tabSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get tabSuggested;

  /// No description provided for @tabSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get tabSongs;

  /// No description provided for @tabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get tabArtists;

  /// No description provided for @tabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get tabAlbums;

  /// No description provided for @tabFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get tabFolders;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @mostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayed;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No songs} =1{1 song} other{{count} songs}}'**
  String songsCount(int count);

  /// No description provided for @albumsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No albums} =1{1 album} other{{count} albums}}'**
  String albumsCount(int count);

  /// No description provided for @artistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No artists} =1{1 artist} other{{count} artists}}'**
  String artistsCount(int count);

  /// No description provided for @foldersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No folders} =1{1 folder} other{{count} folders}}'**
  String foldersCount(int count);

  /// No description provided for @playlistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No playlists} =1{1 playlist} other{{count} playlists}}'**
  String playlistsCount(int count);

  /// No description provided for @durationMins.
  ///
  /// In en, this message translates to:
  /// **'{time} mins'**
  String durationMins(String time);

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutesCount(int count);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @sortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// No description provided for @sortAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get sortAlbum;

  /// No description provided for @sortYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get sortYear;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get sortDateAdded;

  /// No description provided for @sortDateModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get sortDateModified;

  /// No description provided for @sortComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get sortComposer;

  /// No description provided for @sortSongCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Songs'**
  String get sortSongCount;

  /// No description provided for @sortAlbumCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Albums'**
  String get sortAlbumCount;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get playNext;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Playing Queue'**
  String get addToQueue;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// No description provided for @goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to Album'**
  String get goToAlbum;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to Artist'**
  String get goToArtist;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @setAsRingtone.
  ///
  /// In en, this message translates to:
  /// **'Set as Ringtone'**
  String get setAsRingtone;

  /// No description provided for @addToBlocklist.
  ///
  /// In en, this message translates to:
  /// **'Add to Blocklist'**
  String get addToBlocklist;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deleteFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from Device'**
  String get deleteFromDevice;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylist;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from Queue'**
  String get removeFromQueue;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @songDetails.
  ///
  /// In en, this message translates to:
  /// **'Song details'**
  String get songDetails;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get detailTitle;

  /// No description provided for @detailArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get detailArtist;

  /// No description provided for @detailAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get detailAlbum;

  /// No description provided for @detailComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get detailComposer;

  /// No description provided for @detailGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get detailGenre;

  /// No description provided for @detailYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get detailYear;

  /// No description provided for @detailDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detailDuration;

  /// No description provided for @detailFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get detailFormat;

  /// No description provided for @detailSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get detailSize;

  /// No description provided for @detailPath.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detailPath;

  /// No description provided for @detailDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get detailDateAdded;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @demoTrack.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoTrack;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found'**
  String get noLyrics;

  /// No description provided for @noLyricsHint.
  ///
  /// In en, this message translates to:
  /// **'Put an .lrc file with the same name next to the song, or embed lyrics in its tags.'**
  String get noLyricsHint;

  /// No description provided for @playingQueue.
  ///
  /// In en, this message translates to:
  /// **'Playing Queue'**
  String get playingQueue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty'**
  String get queueEmpty;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerEndOfTrack.
  ///
  /// In en, this message translates to:
  /// **'End of current song'**
  String get sleepTimerEndOfTrack;

  /// No description provided for @sleepTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off timer'**
  String get sleepTimerOff;

  /// No description provided for @sleepTimerRemaining.
  ///
  /// In en, this message translates to:
  /// **'Stops in {time}'**
  String sleepTimerRemaining(String time);

  /// No description provided for @sleepTimerSet.
  ///
  /// In en, this message translates to:
  /// **'Playback will stop in {minutes}'**
  String sleepTimerSet(String minutes);

  /// No description provided for @sleepTimerEndSet.
  ///
  /// In en, this message translates to:
  /// **'Playback will stop after this song'**
  String get sleepTimerEndSet;

  /// No description provided for @audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get audioOutput;

  /// No description provided for @audioOutputUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the output picker on this device'**
  String get audioOutputUnavailable;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @repeatOff.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get repeatOff;

  /// No description provided for @repeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat all'**
  String get repeatAll;

  /// No description provided for @repeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get repeatOne;

  /// No description provided for @shuffleOn.
  ///
  /// In en, this message translates to:
  /// **'Shuffle on'**
  String get shuffleOn;

  /// No description provided for @shuffleOff.
  ///
  /// In en, this message translates to:
  /// **'Shuffle off'**
  String get shuffleOff;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @rewind10.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds'**
  String get rewind10;

  /// No description provided for @forward10.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get forward10;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any song to keep it here.'**
  String get noFavoritesHint;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get removedFromFavorites;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get renamePlaylist;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed. The songs stay on your device.'**
  String deletePlaylistMessage(String name);

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylists;

  /// No description provided for @noPlaylistsHint.
  ///
  /// In en, this message translates to:
  /// **'Create a playlist to group the songs you love.'**
  String get noPlaylistsHint;

  /// No description provided for @emptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty'**
  String get emptyPlaylist;

  /// No description provided for @emptyPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Add songs from the song menu: ⋮ → Add to Playlist.'**
  String get emptyPlaylistHint;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to “{name}”'**
  String addedToPlaylist(String name);

  /// No description provided for @alreadyInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Already in “{name}”'**
  String alreadyInPlaylist(String name);

  /// No description provided for @playlistNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get playlistNameEmpty;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs, artists, albums'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{query}”'**
  String noResults(String query);

  /// No description provided for @searchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Find any song, artist or album on your device.'**
  String get searchEmptyHint;

  /// No description provided for @nothingPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing played yet'**
  String get nothingPlayedYet;

  /// No description provided for @nothingPlayedHint.
  ///
  /// In en, this message translates to:
  /// **'Songs you listen to will show up here.'**
  String get nothingPlayedHint;

  /// No description provided for @noArtists.
  ///
  /// In en, this message translates to:
  /// **'No artists found'**
  String get noArtists;

  /// No description provided for @noAlbums.
  ///
  /// In en, this message translates to:
  /// **'No albums found'**
  String get noAlbums;

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFolders;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access to your music'**
  String get permissionTitle;

  /// No description provided for @permissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Navo needs permission to find audio files on your device. The demo tracks work without it.'**
  String get permissionMessage;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Access was denied. You can enable it in the system settings.'**
  String get permissionDeniedMessage;

  /// No description provided for @allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get allowAccess;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @noSongsTitle.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsTitle;

  /// No description provided for @noSongsMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy some music to your device, or enjoy the demo tracks.'**
  String get noSongsMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to the playing queue'**
  String get addedToQueue;

  /// No description provided for @willPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Will play next'**
  String get willPlayNext;

  /// No description provided for @addedToBlocklist.
  ///
  /// In en, this message translates to:
  /// **'Hidden from your library'**
  String get addedToBlocklist;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @ringtoneSet.
  ///
  /// In en, this message translates to:
  /// **'Ringtone set'**
  String get ringtoneSet;

  /// No description provided for @ringtoneNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow Navo to modify system settings, then try again.'**
  String get ringtoneNeedsPermission;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the action'**
  String get actionFailed;

  /// No description provided for @songDeleted.
  ///
  /// In en, this message translates to:
  /// **'Song deleted'**
  String get songDeleted;

  /// No description provided for @deleteSongTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from device?'**
  String get deleteSongTitle;

  /// No description provided for @deleteSongMessage.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be permanently deleted from your device.'**
  String deleteSongMessage(String title);

  /// No description provided for @notAvailableForDemo.
  ///
  /// In en, this message translates to:
  /// **'Not available for demo tracks'**
  String get notAvailableForDemo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get sectionPlayback;

  /// No description provided for @sectionLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get sectionLibrary;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @artworkStyle.
  ///
  /// In en, this message translates to:
  /// **'Player artwork'**
  String get artworkStyle;

  /// No description provided for @artworkVinyl.
  ///
  /// In en, this message translates to:
  /// **'Vinyl (rotating)'**
  String get artworkVinyl;

  /// No description provided for @artworkSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get artworkSquare;

  /// No description provided for @showDemoTracks.
  ///
  /// In en, this message translates to:
  /// **'Show demo tracks'**
  String get showDemoTracks;

  /// No description provided for @blockedSongs.
  ///
  /// In en, this message translates to:
  /// **'Blocked songs'**
  String get blockedSongs;

  /// No description provided for @blockedSongsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No blocked songs'**
  String get blockedSongsEmpty;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @rescanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Rescan library'**
  String get rescanLibrary;

  /// No description provided for @libraryRescanned.
  ///
  /// In en, this message translates to:
  /// **'Library updated'**
  String get libraryRescanned;

  /// No description provided for @showOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Show introduction again'**
  String get showOnboarding;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @designedBy.
  ///
  /// In en, this message translates to:
  /// **'Designed and developed by Feruzbek Namozboyev'**
  String get designedBy;

  /// No description provided for @aboutBio.
  ///
  /// In en, this message translates to:
  /// **'Flutter developer'**
  String get aboutBio;

  /// No description provided for @contactTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get contactTelegram;

  /// No description provided for @madeWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Made with Flutter'**
  String get madeWithFlutter;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Feruzbek Namozboyev'**
  String copyright(int year);

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link'**
  String get linkOpenFailed;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @cannotPlayFile.
  ///
  /// In en, this message translates to:
  /// **'Can\'t play “{title}”. Skipping to the next song.'**
  String cannotPlayFile(String title);

  /// No description provided for @cannotPlayUnknown.
  ///
  /// In en, this message translates to:
  /// **'This file can\'t be played.'**
  String get cannotPlayUnknown;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get notificationChannelName;

  /// No description provided for @notificationsDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to control playback from the notification shade and lock screen.'**
  String get notificationsDeniedMessage;

  /// No description provided for @backgroundPlayback.
  ///
  /// In en, this message translates to:
  /// **'Background playback'**
  String get backgroundPlayback;

  /// No description provided for @backgroundPlaybackHint.
  ///
  /// In en, this message translates to:
  /// **'If music stops when the screen is off, allow Navo to run without battery restrictions.'**
  String get backgroundPlaybackHint;

  /// No description provided for @batterySettings.
  ///
  /// In en, this message translates to:
  /// **'Battery settings'**
  String get batterySettings;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @contactYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get contactYouTube;

  /// No description provided for @youtubeChannel.
  ///
  /// In en, this message translates to:
  /// **'Feruzbek Namozboyev channel'**
  String get youtubeChannel;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settingsSearchHint;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get resetAll;

  /// No description provided for @resetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get resetAllTitle;

  /// No description provided for @resetAllMessage.
  ///
  /// In en, this message translates to:
  /// **'Every setting goes back to its default. Your music, playlists and favorites are kept.'**
  String get resetAllMessage;

  /// No description provided for @resetGroup.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetGroup;

  /// No description provided for @resetGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset “{group}”?'**
  String resetGroupTitle(String group);

  /// No description provided for @resetGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings in this section go back to their defaults.'**
  String get resetGroupMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Settings restored to defaults'**
  String get settingsRestored;

  /// No description provided for @noSettingsFound.
  ///
  /// In en, this message translates to:
  /// **'No settings match “{query}”'**
  String noSettingsFound(String query);

  /// No description provided for @groupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get groupAppearance;

  /// No description provided for @groupPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get groupPlayer;

  /// No description provided for @groupPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get groupPlayback;

  /// No description provided for @groupAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio & Equalizer'**
  String get groupAudio;

  /// No description provided for @groupLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get groupLibrary;

  /// No description provided for @groupLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get groupLyrics;

  /// No description provided for @groupNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get groupNotifications;

  /// No description provided for @groupGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get groupGestures;

  /// No description provided for @groupStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage & Backup'**
  String get groupStorage;

  /// No description provided for @groupAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get groupAccessibility;

  /// No description provided for @groupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get groupPrivacy;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors, fonts, layout'**
  String get appearanceSubtitle;

  /// No description provided for @librarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo tracks, hidden songs, scanning'**
  String get librarySubtitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Oʻzbekcha, Русский, English'**
  String get languageSubtitle;

  /// No description provided for @accessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contrast, text size, motion'**
  String get accessibilitySubtitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline, no tracking'**
  String get privacySubtitle;

  /// No description provided for @playbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Crossfade, speed, behavior, sleep timer'**
  String get playbackSubtitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, author, licenses'**
  String get aboutSubtitle;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get sectionTheme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED black'**
  String get themeAmoled;

  /// No description provided for @themeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Dark theme on a schedule'**
  String get themeSchedule;

  /// No description provided for @themeScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Light during the day, dark at night'**
  String get themeScheduleHint;

  /// No description provided for @darkFrom.
  ///
  /// In en, this message translates to:
  /// **'Dark from'**
  String get darkFrom;

  /// No description provided for @darkUntil.
  ///
  /// In en, this message translates to:
  /// **'Dark until'**
  String get darkUntil;

  /// No description provided for @sectionColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get sectionColor;

  /// No description provided for @accentSource.
  ///
  /// In en, this message translates to:
  /// **'Color source'**
  String get accentSource;

  /// No description provided for @accentPreset.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get accentPreset;

  /// No description provided for @accentCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get accentCustom;

  /// No description provided for @accentMaterialYou.
  ///
  /// In en, this message translates to:
  /// **'Material You (wallpaper)'**
  String get accentMaterialYou;

  /// No description provided for @accentAdaptive.
  ///
  /// In en, this message translates to:
  /// **'From album art'**
  String get accentAdaptive;

  /// No description provided for @materialYouUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Needs Android 12 or newer; using the palette color.'**
  String get materialYouUnavailable;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @lightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get lightness;

  /// No description provided for @sectionText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get sectionText;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @boldText.
  ///
  /// In en, this message translates to:
  /// **'Bold text'**
  String get boldText;

  /// No description provided for @sectionLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get sectionLayout;

  /// No description provided for @corners.
  ///
  /// In en, this message translates to:
  /// **'Corners'**
  String get corners;

  /// No description provided for @cornersSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get cornersSharp;

  /// No description provided for @cornersMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cornersMedium;

  /// No description provided for @cornersRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get cornersRound;

  /// No description provided for @density.
  ///
  /// In en, this message translates to:
  /// **'List density'**
  String get density;

  /// No description provided for @densityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get densityCompact;

  /// No description provided for @densityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get densityComfortable;

  /// No description provided for @densitySpacious.
  ///
  /// In en, this message translates to:
  /// **'Spacious'**
  String get densitySpacious;

  /// No description provided for @artShape.
  ///
  /// In en, this message translates to:
  /// **'Artwork shape'**
  String get artShape;

  /// No description provided for @shapeRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get shapeRounded;

  /// No description provided for @shapeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get shapeCircle;

  /// No description provided for @artSize.
  ///
  /// In en, this message translates to:
  /// **'Artwork size'**
  String get artSize;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @showListArtwork.
  ///
  /// In en, this message translates to:
  /// **'Show artwork in lists'**
  String get showListArtwork;

  /// No description provided for @sectionPlayerLook.
  ///
  /// In en, this message translates to:
  /// **'Player screen'**
  String get sectionPlayerLook;

  /// No description provided for @playerStyle.
  ///
  /// In en, this message translates to:
  /// **'Player style'**
  String get playerStyle;

  /// No description provided for @styleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get styleClassic;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleBlurred.
  ///
  /// In en, this message translates to:
  /// **'Blurred artwork'**
  String get styleBlurred;

  /// No description provided for @blurStrength.
  ///
  /// In en, this message translates to:
  /// **'Blur strength'**
  String get blurStrength;

  /// No description provided for @animatedBackground.
  ///
  /// In en, this message translates to:
  /// **'Animated background'**
  String get animatedBackground;

  /// No description provided for @sectionNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get sectionNavigation;

  /// No description provided for @showNavLabels.
  ///
  /// In en, this message translates to:
  /// **'Show tab labels'**
  String get showNavLabels;

  /// No description provided for @navTabs.
  ///
  /// In en, this message translates to:
  /// **'Bottom tabs'**
  String get navTabs;

  /// No description provided for @navTabsHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder, untick to hide'**
  String get navTabsHint;

  /// No description provided for @startTab.
  ///
  /// In en, this message translates to:
  /// **'Start tab'**
  String get startTab;

  /// No description provided for @homeTabs.
  ///
  /// In en, this message translates to:
  /// **'Home tabs'**
  String get homeTabs;

  /// No description provided for @startHomeTab.
  ///
  /// In en, this message translates to:
  /// **'Default Home tab'**
  String get startHomeTab;

  /// No description provided for @miniPlayerStyle.
  ///
  /// In en, this message translates to:
  /// **'Mini player'**
  String get miniPlayerStyle;

  /// No description provided for @miniFloating.
  ///
  /// In en, this message translates to:
  /// **'Floating'**
  String get miniFloating;

  /// No description provided for @miniDocked.
  ///
  /// In en, this message translates to:
  /// **'Docked'**
  String get miniDocked;

  /// No description provided for @sectionMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get sectionMotion;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @animFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get animFull;

  /// No description provided for @animReduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get animReduced;

  /// No description provided for @animOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get animOff;

  /// No description provided for @systemReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'The system “remove animations” setting is on, so motion stays reduced.'**
  String get systemReduceMotion;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @highContrastHint.
  ///
  /// In en, this message translates to:
  /// **'Stronger text and outlines'**
  String get highContrastHint;

  /// No description provided for @privacyStatement.
  ///
  /// In en, this message translates to:
  /// **'Navo works fully offline. It has no ads, no analytics and no tracking. Your music, playlists and listening history stay on this device and are never sent anywhere.'**
  String get privacyStatement;

  /// No description provided for @saveSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Remember recent searches'**
  String get saveSearchHistory;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(int value);

  /// No description provided for @aboutNavo.
  ///
  /// In en, this message translates to:
  /// **'About Navo'**
  String get aboutNavo;

  /// No description provided for @playerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Style, background, seek bar'**
  String get playerSubtitle;

  /// No description provided for @audioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Equalizer, bass boost, loudness'**
  String get audioSubtitle;

  /// No description provided for @showRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'Show remaining time'**
  String get showRemainingTime;

  /// No description provided for @sectionTransitions.
  ///
  /// In en, this message translates to:
  /// **'Transitions'**
  String get sectionTransitions;

  /// No description provided for @crossfade.
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get crossfade;

  /// No description provided for @crossfadeHint.
  ///
  /// In en, this message translates to:
  /// **'Fades the end of a song out and the next one in'**
  String get crossfadeHint;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String secondsShort(int n);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @fadeOnPlayPause.
  ///
  /// In en, this message translates to:
  /// **'Fade on play and pause'**
  String get fadeOnPlayPause;

  /// No description provided for @skipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silence'**
  String get skipSilence;

  /// No description provided for @normalizeVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume normalization (ReplayGain)'**
  String get normalizeVolume;

  /// No description provided for @normalizeHint.
  ///
  /// In en, this message translates to:
  /// **'Uses ReplayGain tags when a file has them'**
  String get normalizeHint;

  /// No description provided for @pitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get pitch;

  /// No description provided for @resetValue.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetValue;

  /// No description provided for @sectionBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get sectionBehavior;

  /// No description provided for @resumeAfterCall.
  ///
  /// In en, this message translates to:
  /// **'Resume after a call'**
  String get resumeAfterCall;

  /// No description provided for @pauseOnDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Pause when headphones disconnect'**
  String get pauseOnDisconnect;

  /// No description provided for @resumeOnHeadset.
  ///
  /// In en, this message translates to:
  /// **'Resume when headphones connect'**
  String get resumeOnHeadset;

  /// No description provided for @rememberQueue.
  ///
  /// In en, this message translates to:
  /// **'Remember queue and position'**
  String get rememberQueue;

  /// No description provided for @autoPlayOnStart.
  ///
  /// In en, this message translates to:
  /// **'Play automatically on start'**
  String get autoPlayOnStart;

  /// No description provided for @addMode.
  ///
  /// In en, this message translates to:
  /// **'Default “add to queue”'**
  String get addMode;

  /// No description provided for @addToEnd.
  ///
  /// In en, this message translates to:
  /// **'Add to end of queue'**
  String get addToEnd;

  /// No description provided for @shuffleStyle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffleStyle;

  /// No description provided for @shuffleRandom.
  ///
  /// In en, this message translates to:
  /// **'Truly random'**
  String get shuffleRandom;

  /// No description provided for @shuffleAvoidRecent.
  ///
  /// In en, this message translates to:
  /// **'Avoid recently played'**
  String get shuffleAvoidRecent;

  /// No description provided for @sectionSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sectionSleep;

  /// No description provided for @sleepFadeOut.
  ///
  /// In en, this message translates to:
  /// **'Fade out before stopping'**
  String get sleepFadeOut;

  /// No description provided for @shakeToExtend.
  ///
  /// In en, this message translates to:
  /// **'Shake to add 10 minutes'**
  String get shakeToExtend;

  /// No description provided for @sleepExtended.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer extended by 10 minutes'**
  String get sleepExtended;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @eqEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable equalizer'**
  String get eqEnabled;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @eqNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get eqNormal;

  /// No description provided for @eqBass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get eqBass;

  /// No description provided for @eqTreble.
  ///
  /// In en, this message translates to:
  /// **'Treble'**
  String get eqTreble;

  /// No description provided for @eqRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get eqRock;

  /// No description provided for @eqPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get eqPop;

  /// No description provided for @eqJazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get eqJazz;

  /// No description provided for @eqClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get eqClassical;

  /// No description provided for @eqVocal.
  ///
  /// In en, this message translates to:
  /// **'Vocal'**
  String get eqVocal;

  /// No description provided for @eqCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eqCustom;

  /// No description provided for @savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save as preset'**
  String get savePreset;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetName;

  /// No description provided for @deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get deletePreset;

  /// No description provided for @bassBoost.
  ///
  /// In en, this message translates to:
  /// **'Bass boost'**
  String get bassBoost;

  /// No description provided for @loudnessBoost.
  ///
  /// In en, this message translates to:
  /// **'Loudness boost'**
  String get loudnessBoost;

  /// No description provided for @eqUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The equalizer isn’t available on this device.'**
  String get eqUnavailable;

  /// No description provided for @eqStartPlayback.
  ///
  /// In en, this message translates to:
  /// **'Start playing a song to adjust the bands.'**
  String get eqStartPlayback;

  /// No description provided for @hz.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hz(String value);

  /// No description provided for @khz.
  ///
  /// In en, this message translates to:
  /// **'{value} kHz'**
  String khz(String value);

  /// No description provided for @db.
  ///
  /// In en, this message translates to:
  /// **'{value} dB'**
  String db(String value);

  /// No description provided for @abRepeat.
  ///
  /// In en, this message translates to:
  /// **'A–B repeat'**
  String get abRepeat;

  /// No description provided for @abSetA.
  ///
  /// In en, this message translates to:
  /// **'Set point A'**
  String get abSetA;

  /// No description provided for @abSetB.
  ///
  /// In en, this message translates to:
  /// **'Set point B'**
  String get abSetB;

  /// No description provided for @abClear.
  ///
  /// In en, this message translates to:
  /// **'Turn off A–B repeat'**
  String get abClear;

  /// No description provided for @queueRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed “{title}”'**
  String queueRemoved(String title);

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear upcoming'**
  String get clearQueue;

  /// No description provided for @queueCleared.
  ///
  /// In en, this message translates to:
  /// **'Upcoming songs cleared'**
  String get queueCleared;

  /// No description provided for @saveQueueAsPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Save as playlist'**
  String get saveQueueAsPlaylist;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTags;

  /// No description provided for @changeArtwork.
  ///
  /// In en, this message translates to:
  /// **'Change artwork'**
  String get changeArtwork;

  /// No description provided for @removeArtwork.
  ///
  /// In en, this message translates to:
  /// **'Remove artwork'**
  String get removeArtwork;

  /// No description provided for @tagsSaved.
  ///
  /// In en, this message translates to:
  /// **'Tags saved'**
  String get tagsSaved;

  /// No description provided for @tagsNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This file can’t be edited'**
  String get tagsNotSupported;

  /// No description provided for @tagsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the tags'**
  String get tagsFailed;

  /// No description provided for @yearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year'**
  String get yearInvalid;

  /// No description provided for @smartPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Smart playlists'**
  String get smartPlaylists;

  /// No description provided for @myPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My playlists'**
  String get myPlaylists;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @neverPlayed.
  ///
  /// In en, this message translates to:
  /// **'Never Played'**
  String get neverPlayed;

  /// No description provided for @importM3u.
  ///
  /// In en, this message translates to:
  /// **'Import M3U playlist'**
  String get importM3u;

  /// No description provided for @exportM3u.
  ///
  /// In en, this message translates to:
  /// **'Export as M3U'**
  String get exportM3u;

  /// No description provided for @m3uImported.
  ///
  /// In en, this message translates to:
  /// **'Imported “{name}”: {songs}'**
  String m3uImported(String name, String songs);

  /// No description provided for @m3uNoMatches.
  ///
  /// In en, this message translates to:
  /// **'None of the playlist’s songs were found on this device'**
  String get m3uNoMatches;

  /// No description provided for @m3uExported.
  ///
  /// In en, this message translates to:
  /// **'Playlist exported'**
  String get m3uExported;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @deleteSongsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 song from device?} other{Delete {count} songs from device?}}'**
  String deleteSongsTitle(int count);

  /// No description provided for @deleteSongsMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected files will be permanently deleted from your device.'**
  String get deleteSongsMessage;

  /// No description provided for @songsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song deleted} other{{count} songs deleted}}'**
  String songsDeleted(int count);

  /// No description provided for @addedToFavoritesMany.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavoritesMany;

  /// No description provided for @queueAction.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueAction;

  /// No description provided for @sectionFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get sectionFolders;

  /// No description provided for @libraryFolders.
  ///
  /// In en, this message translates to:
  /// **'Library folders'**
  String get libraryFolders;

  /// No description provided for @libraryFoldersHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which folders appear in your library'**
  String get libraryFoldersHint;

  /// No description provided for @folderShown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get folderShown;

  /// No description provided for @folderHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get folderHidden;

  /// No description provided for @folderOnly.
  ///
  /// In en, this message translates to:
  /// **'Only these'**
  String get folderOnly;

  /// No description provided for @folderOnlyActive.
  ///
  /// In en, this message translates to:
  /// **'Only folders marked “Only these” are shown'**
  String get folderOnlyActive;

  /// No description provided for @resetFolders.
  ///
  /// In en, this message translates to:
  /// **'Show all folders'**
  String get resetFolders;

  /// No description provided for @foldersSummary.
  ///
  /// In en, this message translates to:
  /// **'{hidden} hidden'**
  String foldersSummary(int hidden);

  /// No description provided for @allFoldersShown.
  ///
  /// In en, this message translates to:
  /// **'All folders shown'**
  String get allFoldersShown;

  /// No description provided for @sectionFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get sectionFilters;

  /// No description provided for @minDuration.
  ///
  /// In en, this message translates to:
  /// **'Minimum song length'**
  String get minDuration;

  /// No description provided for @minSize.
  ///
  /// In en, this message translates to:
  /// **'Minimum file size'**
  String get minSize;

  /// No description provided for @kbValue.
  ///
  /// In en, this message translates to:
  /// **'{n} KB'**
  String kbValue(int n);

  /// No description provided for @hideShortSounds.
  ///
  /// In en, this message translates to:
  /// **'Hide ringtones and notification sounds'**
  String get hideShortSounds;

  /// No description provided for @sectionScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get sectionScanning;

  /// No description provided for @scanOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Scan for new music on launch'**
  String get scanOnLaunch;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning your music…'**
  String get scanning;

  /// No description provided for @scanFound.
  ///
  /// In en, this message translates to:
  /// **'Library updated: {songs}'**
  String scanFound(String songs);

  /// No description provided for @sectionGrouping.
  ///
  /// In en, this message translates to:
  /// **'Grouping'**
  String get sectionGrouping;

  /// No description provided for @splitArtists.
  ///
  /// In en, this message translates to:
  /// **'Split multiple artists'**
  String get splitArtists;

  /// No description provided for @splitArtistsHint.
  ///
  /// In en, this message translates to:
  /// **'Treat “A feat. B”, “A & B” and “A; B” as separate artists'**
  String get splitArtistsHint;

  /// No description provided for @groupByAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Group by album artist'**
  String get groupByAlbumArtist;

  /// No description provided for @lyricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text size, alignment, timing'**
  String get lyricsSubtitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification buttons, headset button'**
  String get notificationsSubtitle;

  /// No description provided for @lyricsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Lyrics text size'**
  String get lyricsFontSize;

  /// No description provided for @lyricsAlign.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get lyricsAlign;

  /// No description provided for @alignStart.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get alignStart;

  /// No description provided for @alignCenter.
  ///
  /// In en, this message translates to:
  /// **'Centered'**
  String get alignCenter;

  /// No description provided for @lyricsOffset.
  ///
  /// In en, this message translates to:
  /// **'Timing offset'**
  String get lyricsOffset;

  /// No description provided for @lyricsOffsetHint.
  ///
  /// In en, this message translates to:
  /// **'Use it when synced lyrics run ahead or behind'**
  String get lyricsOffsetHint;

  /// No description provided for @offsetSeconds.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String offsetSeconds(String value);

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on while lyrics are open'**
  String get keepScreenOn;

  /// No description provided for @autoScrollLyrics.
  ///
  /// In en, this message translates to:
  /// **'Follow the current line'**
  String get autoScrollLyrics;

  /// No description provided for @lyricsSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get lyricsSmaller;

  /// No description provided for @lyricsLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get lyricsLarger;

  /// No description provided for @lyricsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Show lyrics earlier'**
  String get lyricsEarlier;

  /// No description provided for @lyricsLater.
  ///
  /// In en, this message translates to:
  /// **'Show lyrics later'**
  String get lyricsLater;

  /// No description provided for @sectionNotification.
  ///
  /// In en, this message translates to:
  /// **'Media notification'**
  String get sectionNotification;

  /// No description provided for @notifArtwork.
  ///
  /// In en, this message translates to:
  /// **'Show album art'**
  String get notifArtwork;

  /// No description provided for @notifCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Show close button'**
  String get notifCloseButton;

  /// No description provided for @notifFavoriteButton.
  ///
  /// In en, this message translates to:
  /// **'Favorite button'**
  String get notifFavoriteButton;

  /// No description provided for @notifCompactSkip.
  ///
  /// In en, this message translates to:
  /// **'Previous and next in compact view'**
  String get notifCompactSkip;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Needed for controls in the notification shade on Android 13+'**
  String get notificationPermissionHint;

  /// No description provided for @sectionHeadset.
  ///
  /// In en, this message translates to:
  /// **'Headset button'**
  String get sectionHeadset;

  /// No description provided for @pressSingle.
  ///
  /// In en, this message translates to:
  /// **'Single press'**
  String get pressSingle;

  /// No description provided for @pressDouble.
  ///
  /// In en, this message translates to:
  /// **'Double press'**
  String get pressDouble;

  /// No description provided for @pressTriple.
  ///
  /// In en, this message translates to:
  /// **'Triple press'**
  String get pressTriple;

  /// No description provided for @actionPlayPause.
  ///
  /// In en, this message translates to:
  /// **'Play / pause'**
  String get actionPlayPause;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next song'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous song'**
  String get actionPrevious;

  /// No description provided for @actionNone.
  ///
  /// In en, this message translates to:
  /// **'Do nothing'**
  String get actionNone;

  /// No description provided for @sectionWidget.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get sectionWidget;

  /// No description provided for @widgetHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press your home screen, choose Widgets and add Navo.'**
  String get widgetHint;

  /// No description provided for @widgetNothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get widgetNothingPlaying;

  /// No description provided for @gesturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mini player swipe, haptics'**
  String get gesturesSubtitle;

  /// No description provided for @gestureMiniSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe mini player for next / previous'**
  String get gestureMiniSwipe;

  /// No description provided for @gestureDoubleTap.
  ///
  /// In en, this message translates to:
  /// **'Double-tap artwork to play / pause'**
  String get gestureDoubleTap;

  /// No description provided for @gestureSwipeArtwork.
  ///
  /// In en, this message translates to:
  /// **'Swipe artwork to change song'**
  String get gestureSwipeArtwork;

  /// No description provided for @gestureShake.
  ///
  /// In en, this message translates to:
  /// **'Shake to skip'**
  String get gestureShake;

  /// No description provided for @gestureShakeSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Shake sensitivity'**
  String get gestureShakeSensitivity;

  /// No description provided for @gestureVolumeSeek.
  ///
  /// In en, this message translates to:
  /// **'Volume buttons seek in the player'**
  String get gestureVolumeSeek;

  /// No description provided for @gestureVolumeSeekHint.
  ///
  /// In en, this message translates to:
  /// **'While the player is open: up = +10 s, down = −10 s'**
  String get gestureVolumeSeekHint;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptics;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Listening statistics'**
  String get stats;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device'**
  String get statsSubtitle;

  /// No description provided for @statsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total listening time'**
  String get statsTotal;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get statsLast7Days;

  /// No description provided for @statsTopSongs.
  ///
  /// In en, this message translates to:
  /// **'Top songs'**
  String get statsTopSongs;

  /// No description provided for @statsTopArtists.
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get statsTopArtists;

  /// No description provided for @statsTopAlbums.
  ///
  /// In en, this message translates to:
  /// **'Top albums'**
  String get statsTopAlbums;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No listening data yet'**
  String get statsEmpty;

  /// No description provided for @statsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Play some music and come back to see your stats.'**
  String get statsEmptyHint;

  /// No description provided for @statsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Statistics are turned off in Privacy settings.'**
  String get statsDisabled;

  /// No description provided for @collectStats.
  ///
  /// In en, this message translates to:
  /// **'Collect listening statistics'**
  String get collectStats;

  /// No description provided for @clearStats.
  ///
  /// In en, this message translates to:
  /// **'Clear statistics'**
  String get clearStats;

  /// No description provided for @clearStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear listening statistics?'**
  String get clearStatsTitle;

  /// No description provided for @clearStatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Listening time, top lists and play counts will be reset.'**
  String get clearStatsMessage;

  /// No description provided for @statsCleared.
  ///
  /// In en, this message translates to:
  /// **'Statistics cleared'**
  String get statsCleared;

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} min'**
  String hoursMinutes(int h, int m);

  /// No description provided for @minutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String minutesOnly(int m);

  /// No description provided for @dayMinutes.
  ///
  /// In en, this message translates to:
  /// **'{day}: {minutes}'**
  String dayMinutes(String day, String minutes);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedSettings;

  /// No description provided for @advancedSettingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more setting} other{{count} more settings}}'**
  String advancedSettingsCount(int count);

  /// No description provided for @storageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back up and restore settings, favorites, playlists'**
  String get storageSubtitle;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupExport;

  /// No description provided for @backupExportHint.
  ///
  /// In en, this message translates to:
  /// **'Settings, favorites, playlists and hidden songs to a file'**
  String get backupExportHint;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupImport;

  /// No description provided for @backupImportHint.
  ///
  /// In en, this message translates to:
  /// **'Replaces current settings, favorites and playlists'**
  String get backupImportHint;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Navo backup'**
  String get backupInvalid;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current settings, favorites and playlists will be replaced.'**
  String get restoreBackupMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
