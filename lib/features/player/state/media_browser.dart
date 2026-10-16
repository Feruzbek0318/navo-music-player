import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../library/data/models.dart';
import '../../library/data/sorting.dart';
import '../../library/state/library_providers.dart';
import '../../playlists/state/playlist_providers.dart';
import '../../settings/state/settings_providers.dart';
import '../data/navo_audio_handler.dart';

/// Library tree for Android Auto and other media browsers.
///
/// Ids: `cat:<name>` (browsable categories), `album:<id>`, `artist:<id>`,
/// `pl:<id>` (browsable collections) and `play:<context>|<trackKey>` for
/// playable songs, where the context says which list to queue.
class NavoMediaBrowser implements MediaBrowserSource {
  NavoMediaBrowser(this._ref);

  final Ref _ref;

  AppLocalizations get _l10n {
    final selected = _ref.read(localeProvider);
    return lookupAppLocalizations(resolveLocale(selected, WidgetsBinding.instance.platformDispatcher.locales));
  }

  Future<List<Track>> _library() => _ref.read(libraryTracksProvider.future);

  MediaItem _folder(String id, String title) => MediaItem(id: id, title: title, playable: false);

  MediaItem _song(String context, Track t) => MediaItem(
    id: 'play:$context|${t.key}',
    title: t.title,
    artist: t.artist,
    album: t.album,
    duration: t.duration,
    playable: true,
  );

  /// The list a context id refers to.
  Future<List<Track>> _contextTracks(String context) async {
    final lib = await _library();
    final parts = context.split(':');
    switch (parts.first) {
      case 'songs':
        return sortTracks(lib, SortOption.ascending);
      case 'favorites':
        await _ref.read(knownTracksProvider.future);
        return _ref.read(favoriteTracksProvider);
      case 'recent':
        await _ref.read(knownTracksProvider.future);
        return _ref.read(recentlyPlayedProvider);
      case 'album':
        final id = context.substring('album:'.length);
        return sortTracks(lib.where((t) => t.albumKey == id).toList(), SortOption.ascending);
      case 'artist':
        final id = context.substring('artist:'.length);
        final s = _ref.read(librarySettingsProvider);
        return [
          for (final c in Grouping.artists(lib, split: s.splitArtists, byAlbumArtist: s.groupByAlbumArtist))
            if (c.id == id) ...c.tracks,
        ];
      case 'pl':
        await _ref.read(knownTracksProvider.future);
        return [for (final (_, t) in _ref.read(playlistTracksProvider(context.substring(3)))) t];
    }
    return const [];
  }

  @override
  Future<List<MediaItem>> children(String parentId) async {
    final l = _l10n;
    switch (parentId) {
      case AudioService.browsableRootId:
        return [
          _folder('cat:songs', l.tabSongs),
          _folder('cat:favorites', l.favorites),
          _folder('cat:recent', l.recentlyPlayed),
          _folder('cat:playlists', l.playlists),
          _folder('cat:albums', l.tabAlbums),
          _folder('cat:artists', l.tabArtists),
        ];
      case AudioService.recentRootId:
        final recent = await _contextTracks('recent');
        return [for (final t in recent.take(1)) _song('recent', t)];
      case 'cat:songs':
      case 'cat:favorites':
      case 'cat:recent':
        final context = parentId.substring(4);
        return [for (final t in (await _contextTracks(context)).take(500)) _song(context, t)];
      case 'cat:playlists':
        return [for (final p in _ref.read(playlistsProvider)) _folder('pl:${p.id}', p.name)];
      case 'cat:albums':
        final lib = await _library();
        return [
          for (final a in sortCollections(Grouping.albums(lib), SortOption.ascending))
            _folder('album:${a.id}', a.name.isEmpty ? l.unknownAlbum : a.name),
        ];
      case 'cat:artists':
        final lib = await _library();
        final s = _ref.read(librarySettingsProvider);
        return [
          for (final a in sortCollections(
            Grouping.artists(lib, split: s.splitArtists, byAlbumArtist: s.groupByAlbumArtist),
            SortOption.ascending,
          ))
            _folder('artist:${a.id}', a.name.isEmpty ? l.unknownArtist : a.name),
        ];
    }
    if (parentId.startsWith('album:') || parentId.startsWith('artist:') || parentId.startsWith('pl:')) {
      return [for (final t in await _contextTracks(parentId)) _song(parentId, t)];
    }
    return const [];
  }

  @override
  Future<(List<Track>, int)?> resolve(String mediaId) async {
    if (!mediaId.startsWith('play:')) return null;
    final body = mediaId.substring(5);
    final bar = body.lastIndexOf('|');
    if (bar < 0) return null;
    final tracks = await _contextTracks(body.substring(0, bar));
    final key = body.substring(bar + 1);
    final index = tracks.indexWhere((t) => t.key == key);
    return index < 0 ? null : (tracks, index);
  }

  @override
  Future<List<MediaItem>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final lib = await _library();
    return [
      for (final t
          in lib.where((t) => t.title.toLowerCase().contains(q) || (t.artist ?? '').toLowerCase().contains(q)).take(50))
        _song('songs', t),
    ];
  }
}
