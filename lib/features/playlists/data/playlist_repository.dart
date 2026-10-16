import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';

@immutable
class Playlist {
  const Playlist({required this.id, required this.name, required this.trackKeys, required this.createdAt});

  final String id;
  final String name;
  final List<String> trackKeys;
  final DateTime createdAt;

  Playlist copyWith({String? name, List<String>? trackKeys}) =>
      Playlist(id: id, name: name ?? this.name, trackKeys: trackKeys ?? this.trackKeys, createdAt: createdAt);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'tracks': trackKeys,
    'created': createdAt.millisecondsSinceEpoch,
  };

  static Playlist fromMap(Map<String, dynamic> m) => Playlist(
    id: m['id'] as String,
    name: m['name'] as String,
    trackKeys: (m['tracks'] as List).cast<String>(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['created'] as int),
  );
}

class PlaylistRepository {
  PlaylistRepository(this._store);

  final LocalStore _store;

  List<Playlist> load() => _store.mapList(StoreKeys.playlists).map(Playlist.fromMap).toList();

  Future<void> save(List<Playlist> playlists) =>
      _store.putMapList(StoreKeys.playlists, playlists.map((p) => p.toMap()).toList());
}
