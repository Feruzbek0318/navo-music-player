import 'package:flutter/foundation.dart';

/// A playable song, either from the device's media store or a bundled demo.
@immutable
class Track {
  const Track({
    required this.key,
    required this.title,
    required this.uri,
    required this.duration,
    this.mediaId,
    this.artist,
    this.album,
    this.albumId,
    this.path,
    this.composer,
    this.genre,
    this.year,
    this.dateAdded,
    this.dateModified,
    this.size = 0,
    this.extension = '',
    this.assetArtwork,
    this.assetLyrics,
    this.albumArtist,
    this.isSystemSound = false,
  });

  /// Stable identifier used for persistence: `d:<mediaId>` or `demo:<name>`.
  final String key;
  final int? mediaId;
  final String title;
  final String? artist;
  final String? album;
  final int? albumId;

  /// `content://…` for device songs, `asset:///…` for demo tracks.
  final String uri;

  /// Absolute file path (device songs only).
  final String? path;
  final Duration duration;
  final String? composer;
  final String? genre;
  final int? year;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final int size;
  final String extension;

  /// Asset paths for demo content.
  final String? assetArtwork;
  final String? assetLyrics;
  final String? albumArtist;

  /// Ringtone, notification or alarm sound (hidden by default).
  final bool isSystemSound;

  /// Individual artist names, splitting "A feat. B", "A ft. B", "A & B",
  /// "A; B" and "A x B". Commas and slashes are kept ("AC/DC").
  List<String> artistNames({required bool split}) {
    final a = artist?.trim();
    if (a == null || a.isEmpty) return const [];
    if (!split) return [a];
    return a
        .split(RegExp(r'\s*;\s*|\s+(?:&|x|feat\.?|ft\.?|featuring)\s+', caseSensitive: false))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, Object?> toJson() => {
    'key': key,
    'mediaId': mediaId,
    'title': title,
    'artist': artist,
    'album': album,
    'albumId': albumId,
    'albumArtist': albumArtist,
    'uri': uri,
    'path': path,
    'durationMs': duration.inMilliseconds,
    'composer': composer,
    'genre': genre,
    'year': year,
    'added': dateAdded?.millisecondsSinceEpoch,
    'modified': dateModified?.millisecondsSinceEpoch,
    'size': size,
    'ext': extension,
    'system': isSystemSound,
  };

  static Track fromJson(Map<String, Object?> j) {
    DateTime? date(Object? v) => v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;
    return Track(
      key: j['key']! as String,
      mediaId: j['mediaId'] as int?,
      title: j['title']! as String,
      artist: j['artist'] as String?,
      album: j['album'] as String?,
      albumId: j['albumId'] as int?,
      albumArtist: j['albumArtist'] as String?,
      uri: j['uri']! as String,
      path: j['path'] as String?,
      duration: Duration(milliseconds: (j['durationMs'] as int?) ?? 0),
      composer: j['composer'] as String?,
      genre: j['genre'] as String?,
      year: j['year'] as int?,
      dateAdded: date(j['added']),
      dateModified: date(j['modified']),
      size: (j['size'] as int?) ?? 0,
      extension: (j['ext'] as String?) ?? '',
      isSystemSound: (j['system'] as bool?) ?? false,
    );
  }

  bool get isDemo => key.startsWith('demo:');

  String get artistKey => (artist ?? '').trim().toLowerCase();
  String get albumKey => albumId != null ? 'id:$albumId' : 'name:${(album ?? '').trim().toLowerCase()}';

  /// Folder the file lives in; demo tracks share a virtual folder.
  String get folderPath {
    final p = path;
    if (p == null) return demoFolderPath;
    final i = p.lastIndexOf('/');
    return i <= 0 ? '/' : p.substring(0, i);
  }

  static const demoFolderPath = 'navo://demo';

  @override
  bool operator ==(Object other) => other is Track && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// A group of tracks: an album, an artist or a folder.
@immutable
class TrackCollection {
  const TrackCollection({
    required this.id,
    required this.kind,
    required this.name,
    required this.tracks,
    this.subtitle,
  });

  final String id;
  final CollectionKind kind;
  final String name;

  /// Album artist, or the parent path for folders.
  final String? subtitle;
  final List<Track> tracks;

  Track get cover => tracks.first;
  int get songCount => tracks.length;
  Duration get totalDuration => tracks.fold(Duration.zero, (a, t) => a + t.duration);
  int get albumCount => tracks.map((t) => t.albumKey).toSet().length;
  int? get year => tracks.map((t) => t.year).whereType<int>().fold<int?>(null, (a, b) => a == null || b > a ? b : a);
  DateTime? get latestAdded => _latest(tracks.map((t) => t.dateAdded));
  DateTime? get latestModified => _latest(tracks.map((t) => t.dateModified));

  static DateTime? _latest(Iterable<DateTime?> dates) =>
      dates.whereType<DateTime>().fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

  @override
  bool operator ==(Object other) => other is TrackCollection && other.id == id && other.kind == kind;

  @override
  int get hashCode => Object.hash(id, kind);
}

enum CollectionKind { album, artist, folder, playlist }
