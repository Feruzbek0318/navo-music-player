import 'models.dart';

enum LibrarySection { songs, albums, artists, folders }

enum SortOption { ascending, descending, artist, album, year, dateAdded, dateModified, composer, songCount, albumCount }

extension LibrarySectionSorts on LibrarySection {
  List<SortOption> get options => switch (this) {
    LibrarySection.songs => const [
      SortOption.ascending,
      SortOption.descending,
      SortOption.artist,
      SortOption.album,
      SortOption.year,
      SortOption.dateAdded,
      SortOption.dateModified,
      SortOption.composer,
    ],
    LibrarySection.albums => const [
      SortOption.ascending,
      SortOption.descending,
      SortOption.artist,
      SortOption.year,
      SortOption.dateAdded,
      SortOption.dateModified,
      SortOption.songCount,
    ],
    LibrarySection.artists => const [
      SortOption.ascending,
      SortOption.descending,
      SortOption.dateAdded,
      SortOption.dateModified,
      SortOption.songCount,
      SortOption.albumCount,
    ],
    LibrarySection.folders => const [
      SortOption.ascending,
      SortOption.descending,
      SortOption.dateAdded,
      SortOption.dateModified,
      SortOption.songCount,
    ],
  };
}

int _text(String? a, String? b) {
  // Unknown values sort last.
  if (a == null || a.isEmpty) return (b == null || b.isEmpty) ? 0 : 1;
  if (b == null || b.isEmpty) return -1;
  return a.toLowerCase().compareTo(b.toLowerCase());
}

int _dateDesc(DateTime? a, DateTime? b) {
  if (a == null) return b == null ? 0 : 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

int _intDesc(int? a, int? b) => (b ?? -1).compareTo(a ?? -1);

List<Track> sortTracks(List<Track> input, SortOption option) {
  final list = [...input];
  int byTitle(Track a, Track b) => _text(a.title, b.title);
  int Function(Track, Track) cmp = switch (option) {
    SortOption.ascending => byTitle,
    SortOption.descending => (a, b) => byTitle(b, a),
    SortOption.artist => (a, b) => _or(_text(a.artist, b.artist), byTitle(a, b)),
    SortOption.album => (a, b) => _or(_text(a.album, b.album), byTitle(a, b)),
    SortOption.year => (a, b) => _or(_intDesc(a.year, b.year), byTitle(a, b)),
    SortOption.dateAdded => (a, b) => _or(_dateDesc(a.dateAdded, b.dateAdded), byTitle(a, b)),
    SortOption.dateModified => (a, b) => _or(_dateDesc(a.dateModified, b.dateModified), byTitle(a, b)),
    SortOption.composer => (a, b) => _or(_text(a.composer, b.composer), byTitle(a, b)),
    SortOption.songCount || SortOption.albumCount => byTitle,
  };
  list.sort(cmp);
  return list;
}

List<TrackCollection> sortCollections(List<TrackCollection> input, SortOption option) {
  final list = [...input];
  int byName(TrackCollection a, TrackCollection b) => _text(a.name, b.name);
  int Function(TrackCollection, TrackCollection) cmp = switch (option) {
    SortOption.ascending => byName,
    SortOption.descending => (a, b) => byName(b, a),
    SortOption.artist => (a, b) => _or(_text(a.subtitle, b.subtitle), byName(a, b)),
    SortOption.year => (a, b) => _or(_intDesc(a.year, b.year), byName(a, b)),
    SortOption.dateAdded => (a, b) => _or(_dateDesc(a.latestAdded, b.latestAdded), byName(a, b)),
    SortOption.dateModified => (a, b) => _or(_dateDesc(a.latestModified, b.latestModified), byName(a, b)),
    SortOption.songCount => (a, b) => _or(b.songCount.compareTo(a.songCount), byName(a, b)),
    SortOption.albumCount => (a, b) => _or(b.albumCount.compareTo(a.albumCount), byName(a, b)),
    SortOption.album || SortOption.composer => byName,
  };
  list.sort(cmp);
  return list;
}

int _or(int first, int then) => first != 0 ? first : then;

/// Groups tracks into albums, artists and folders.
abstract final class Grouping {
  static List<TrackCollection> albums(List<Track> tracks) {
    final map = <String, List<Track>>{};
    for (final t in tracks) {
      map.putIfAbsent(t.albumKey, () => []).add(t);
    }
    return [
      for (final e in map.entries)
        TrackCollection(
          id: e.key,
          kind: CollectionKind.album,
          name: e.value.first.album ?? '',
          subtitle: _mostCommon(e.value.map((t) => t.albumArtist ?? t.artist)),
          tracks: e.value,
        ),
    ];
  }

  /// Group id for a track's (first) artist, matching [artists].
  static String artistIdFor(Track t, {bool split = false, bool byAlbumArtist = false}) {
    final names = _artistNames(t, split: split, byAlbumArtist: byAlbumArtist);
    return names.isEmpty ? '' : names.first.toLowerCase();
  }

  static List<String> _artistNames(Track t, {required bool split, required bool byAlbumArtist}) {
    final albumArtist = t.albumArtist;
    if (byAlbumArtist && albumArtist != null && albumArtist.isNotEmpty) return [albumArtist];
    return t.artistNames(split: split);
  }

  static List<TrackCollection> artists(List<Track> tracks, {bool split = false, bool byAlbumArtist = false}) {
    final map = <String, List<Track>>{};
    final names = <String, String>{};
    for (final t in tracks) {
      final list = _artistNames(t, split: split, byAlbumArtist: byAlbumArtist);
      for (final n in list.isEmpty ? const [''] : list) {
        final id = n.toLowerCase();
        names.putIfAbsent(id, () => n);
        map.putIfAbsent(id, () => []).add(t);
      }
    }
    return [
      for (final e in map.entries)
        TrackCollection(id: e.key, kind: CollectionKind.artist, name: names[e.key]!, tracks: e.value),
    ];
  }

  static List<TrackCollection> folders(List<Track> tracks) {
    final map = <String, List<Track>>{};
    for (final t in tracks) {
      map.putIfAbsent(t.folderPath, () => []).add(t);
    }
    return [
      for (final e in map.entries)
        TrackCollection(
          id: e.key,
          kind: CollectionKind.folder,
          name: e.key == Track.demoFolderPath ? '' : e.key.split('/').last,
          subtitle: e.key,
          tracks: e.value,
        ),
    ];
  }

  static String? _mostCommon(Iterable<String?> values) {
    final counts = <String, int>{};
    for (final v in values.whereType<String>()) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
