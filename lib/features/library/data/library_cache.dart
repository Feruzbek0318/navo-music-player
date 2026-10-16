import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import 'models.dart';

/// Keeps the last media-store scan so the library shows instantly on launch.
/// (De)serialisation runs in a background isolate for large libraries.
class LibraryCache {
  LibraryCache(this._store);

  final LocalStore _store;

  static const version = 1;

  Future<List<Track>?> load() async {
    final raw = _store.libraryString(StoreKeys.scanCache);
    if (raw == null) return null;
    try {
      return await compute(decode, raw);
    } catch (e) {
      debugPrint('Library cache unreadable: $e');
      return null;
    }
  }

  Future<void> save(List<Track> tracks) async {
    final maps = [for (final t in tracks) t.toJson()];
    final raw = await compute(_encode, maps);
    await _store.putLibraryString(StoreKeys.scanCache, raw);
  }

  @visibleForTesting
  static List<Track>? decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map || json['v'] != version) return null;
    return [for (final m in json['tracks'] as List) Track.fromJson((m as Map).cast<String, Object?>())];
  }

  static String _encode(List<Map<String, Object?>> maps) => jsonEncode({'v': version, 'tracks': maps});

  @visibleForTesting
  static String encodeForTest(List<Track> tracks) => _encode([for (final t in tracks) t.toJson()]);
}
