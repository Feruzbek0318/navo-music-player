import 'package:flutter/widgets.dart';

import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/models.dart';
import '../data/sorting.dart';

/// Localised display strings for library objects.
extension TrackLabels on BuildContext {
  String artistOf(Track t) => t.artist ?? l10n.unknownArtist;
  String albumOf(Track t) => t.album ?? l10n.unknownAlbum;

  /// `Artist | 03:50 mins`
  String trackSubtitle(Track t) => '${artistOf(t)}  |  ${l10n.durationMins(formatDuration(t.duration))}';

  String collectionTitle(TrackCollection c) {
    if (c.name.isNotEmpty) return c.name;
    return switch (c.kind) {
      CollectionKind.artist => l10n.unknownArtist,
      CollectionKind.album => l10n.unknownAlbum,
      CollectionKind.folder => c.id == Track.demoFolderPath ? '${l10n.appName} ${l10n.demoTrack}' : l10n.unknown,
      CollectionKind.playlist => l10n.unknown,
    };
  }

  /// `1 album | 20 songs` for artists, `Artist | 2022` for albums,
  /// `100 songs` for folders.
  String collectionSubtitle(TrackCollection c) => switch (c.kind) {
    CollectionKind.artist => '${l10n.albumsCount(c.albumCount)}  |  ${l10n.songsCount(c.songCount)}',
    CollectionKind.album => [c.subtitle ?? l10n.unknownArtist, if (c.year != null) '${c.year}'].join('  |  '),
    CollectionKind.folder || CollectionKind.playlist => l10n.songsCount(c.songCount),
  };

  /// `1 album | 20 songs | 01:25:43 mins` for detail headers.
  String collectionStats(TrackCollection c) => [
    if (c.kind == CollectionKind.artist) l10n.albumsCount(c.albumCount),
    if (c.kind == CollectionKind.album && c.subtitle != null) c.subtitle!,
    l10n.songsCount(c.songCount),
    l10n.durationMins(formatDuration(c.totalDuration)),
  ].join('  |  ');
}

String sortLabel(AppLocalizations l10n, SortOption o) => switch (o) {
  SortOption.ascending => l10n.sortAscending,
  SortOption.descending => l10n.sortDescending,
  SortOption.artist => l10n.sortArtist,
  SortOption.album => l10n.sortAlbum,
  SortOption.year => l10n.sortYear,
  SortOption.dateAdded => l10n.sortDateAdded,
  SortOption.dateModified => l10n.sortDateModified,
  SortOption.composer => l10n.sortComposer,
  SortOption.songCount => l10n.sortSongCount,
  SortOption.albumCount => l10n.sortAlbumCount,
};
