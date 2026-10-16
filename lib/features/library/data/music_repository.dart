import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/platform/device_bridge.dart';
import 'models.dart';

enum LibraryPermission { granted, denied, permanentlyDenied }

/// Reads songs and artwork from the device media store.
class MusicRepository {
  MusicRepository(this._bridge);

  final DeviceBridge _bridge;
  final _query = OnAudioQuery();
  final _artCache = _LruCache<String, Uint8List?>(160);
  final _artFiles = <String, Uri>{};

  static bool get supportsDeviceLibrary => Platform.isAndroid || Platform.isIOS;

  /// Desktop builds read the user's Music folder instead of a media store.
  static bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<Permission> _permission() async {
    if (Platform.isIOS) return Permission.mediaLibrary;
    return await _bridge.androidSdkInt() >= 33 ? Permission.audio : Permission.storage;
  }

  Future<LibraryPermission> permissionStatus() async {
    if (isDesktop) return LibraryPermission.granted;
    if (!supportsDeviceLibrary) return LibraryPermission.denied;
    return _map(await (await _permission()).status);
  }

  Future<LibraryPermission> requestPermission() async {
    if (isDesktop) return LibraryPermission.granted;
    if (!supportsDeviceLibrary) return LibraryPermission.denied;
    return _map(await (await _permission()).request());
  }

  LibraryPermission _map(PermissionStatus s) => switch (s) {
    PermissionStatus.granted || PermissionStatus.limited => LibraryPermission.granted,
    PermissionStatus.permanentlyDenied || PermissionStatus.restricted => LibraryPermission.permanentlyDenied,
    _ => LibraryPermission.denied,
  };

  Future<List<Track>> deviceTracks() async {
    if (isDesktop) {
      final home = Platform.environment[Platform.isWindows ? 'USERPROFILE' : 'HOME'];
      if (home == null) return const [];
      final dir = '$home${Platform.pathSeparator}Music';
      return Isolate.run(() => _scanFolder(dir));
    }
    final songs = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    // Filtering (duration, folders, system sounds) happens in [LibraryFilter]
    // so it can follow the user's settings without rescanning.
    return songs.map(_toTrack).toList(growable: false);
  }

  Track _toTrack(SongModel s) {
    DateTime? seconds(int? v) => v == null || v == 0 ? null : DateTime.fromMillisecondsSinceEpoch(v * 1000);
    final year = s.getMap['year'];
    return Track(
      key: 'd:${s.id}',
      mediaId: s.id,
      title: s.title.trim().isEmpty ? s.displayNameWOExt : s.title,
      artist: _clean(s.artist),
      album: _clean(s.album),
      albumId: s.albumId,
      uri: s.uri ?? Uri.file(s.data).toString(),
      path: s.data,
      duration: Duration(milliseconds: s.duration ?? 0),
      composer: _clean(s.composer),
      genre: _clean(s.genre),
      year: year is int && year > 0 ? year : null,
      dateAdded: seconds(s.dateAdded),
      dateModified: seconds(s.dateModified),
      size: s.size,
      extension: s.fileExtension,
      albumArtist: _clean(s.getMap['album_artist'] as String?),
      isSystemSound: s.isNotification == true || s.isAlarm == true || s.isRingtone == true || s.isMusic == false,
    );
  }

  static String? _clean(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty || t == '<unknown>' ? null : t;
  }

  /// Embedded artwork bytes for a device song (cached).
  Future<Uint8List?> artwork(Track track, {int size = 400}) async {
    if (isDesktop && track.path != null) return _fileArtwork(track);
    final id = track.mediaId;
    if (id == null || !supportsDeviceLibrary) return null;
    final cacheKey = '${track.key}@$size';
    if (_artCache.containsKey(cacheKey)) return _artCache[cacheKey];
    try {
      final bytes = await _query.queryArtwork(
        id,
        ArtworkType.AUDIO,
        size: size,
        quality: 90,
        format: ArtworkFormat.JPEG,
      );
      final result = bytes == null || bytes.isEmpty ? null : bytes;
      _artCache[cacheKey] = result;
      return result;
    } catch (_) {
      _artCache[cacheKey] = null;
      return null;
    }
  }

  /// Embedded picture of a desktop file (cached; size is ignored).
  Future<Uint8List?> _fileArtwork(Track track) async {
    if (_artCache.containsKey(track.key)) return _artCache[track.key];
    final path = track.path!;
    Uint8List? bytes;
    try {
      bytes = await Isolate.run(() {
        final pictures = readMetadata(File(path), getImage: true).pictures;
        return pictures.isEmpty ? null : pictures.first.bytes;
      });
    } catch (_) {}
    return _artCache[track.key] = bytes;
  }

  /// Forgets cached artwork for [track] (after its tags were edited).
  Future<void> evictArtwork(Track track) async {
    _artCache.removeWhere((k) => k.startsWith('${track.key}@'));
    final file = _artFiles.remove(track.key);
    if (file != null) {
      try {
        await File.fromUri(file).delete();
      } catch (_) {}
    }
  }

  /// A `file://` URI for the artwork, needed by the media notification.
  Future<Uri?> artworkFileUri(Track track) async {
    final cached = _artFiles[track.key];
    // The system may clear the cache directory at any time.
    if (cached != null && await File.fromUri(cached).exists()) return cached;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/art_${track.key.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')}.jpg');
      if (!await file.exists()) {
        final Uint8List? bytes;
        if (track.assetArtwork != null) {
          bytes = (await rootBundle.load(track.assetArtwork!)).buffer.asUint8List();
        } else {
          bytes = await artwork(track, size: 512);
        }
        if (bytes == null) return null;
        await file.writeAsBytes(bytes, flush: true);
      }
      return _artFiles[track.key] = file.uri;
    } catch (e) {
      debugPrint('artworkFileUri failed: $e');
      return null;
    }
  }

  /// A readable file for sharing; demo assets are copied to a temp file.
  Future<String?> shareablePath(Track track) async {
    if (!track.isDemo) return track.path;
    final dir = await getTemporaryDirectory();
    final name = track.uri.split('/').last;
    final file = File('${dir.path}/$name');
    if (!await file.exists()) {
      final data = await rootBundle.load(track.uri.replaceFirst('asset:///', ''));
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }
    return file.path;
  }
}

const _audioExtensions = {'mp3', 'm4a', 'aac', 'flac', 'ogg', 'opus', 'wav'};

/// Reads tags of every audio file under [root]. Runs in a background isolate.
List<Track> _scanFolder(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) return const [];
  final tracks = <Track>[];
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0) continue;
    final ext = name.substring(dot + 1).toLowerCase();
    if (!_audioExtensions.contains(ext)) continue;
    final fallbackTitle = name.substring(0, dot);
    try {
      final stat = entity.statSync();
      AudioMetadata? m;
      try {
        m = readMetadata(entity);
      } catch (_) {}
      final title = m?.title?.trim();
      tracks.add(
        Track(
          key: 'f:${entity.path}',
          title: title == null || title.isEmpty ? fallbackTitle : title,
          artist: MusicRepository._clean(m?.artist),
          album: MusicRepository._clean(m?.album),
          albumArtist: MusicRepository._clean(m?.albumArtist),
          genre: m == null || m.genres.isEmpty ? null : m.genres.first,
          year: m?.year?.year,
          uri: entity.uri.toString(),
          path: entity.path,
          duration: m?.duration ?? Duration.zero,
          dateAdded: stat.changed,
          dateModified: stat.modified,
          size: stat.size,
          extension: ext,
        ),
      );
    } catch (_) {}
  }
  tracks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return tracks;
}

class _LruCache<K, V> {
  _LruCache(this.capacity);

  final int capacity;
  final _map = <K, V>{};

  bool containsKey(K key) => _map.containsKey(key);

  void removeWhere(bool Function(K key) test) => _map.removeWhere((k, _) => test(k));

  V? operator [](K key) {
    if (!_map.containsKey(key)) return null;
    final v = _map.remove(key) as V;
    _map[key] = v;
    return v;
  }

  void operator []=(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    if (_map.length > capacity) _map.remove(_map.keys.first);
  }
}
