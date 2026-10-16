import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../../library/data/models.dart';
import '../../library/state/library_providers.dart';
import '../data/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>(
  (ref) => PlaylistRepository(ref.watch(localStoreProvider)),
);

class PlaylistsNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() => ref.read(playlistRepositoryProvider).load();

  Future<void> _commit(List<Playlist> next) async {
    state = next;
    await ref.read(playlistRepositoryProvider).save(next);
  }

  Future<Playlist> create(String name, {List<String> trackKeys = const []}) async {
    final p = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: name.trim(),
      trackKeys: trackKeys,
      createdAt: DateTime.now(),
    );
    await _commit([...state, p]);
    return p;
  }

  Future<void> rename(String id, String name) =>
      _commit([for (final p in state) p.id == id ? p.copyWith(name: name.trim()) : p]);

  Future<void> delete(String id) => _commit(state.where((p) => p.id != id).toList());

  Future<void> reorder(int from, int to) {
    final next = [...state];
    final p = next.removeAt(from);
    next.insert(to, p);
    return _commit(next);
  }

  /// Adds [keys] that aren't already present; returns how many were added.
  Future<int> addTracks(String id, List<String> keys) async {
    var added = 0;
    await _commit([
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            trackKeys: () {
              final existing = p.trackKeys.toSet();
              final fresh = keys.where(existing.add).toList();
              added = fresh.length;
              return [...p.trackKeys, ...fresh];
            }(),
          )
        else
          p,
    ]);
    return added;
  }

  Future<void> removeTrackAt(String id, int index) => _commit([
    for (final p in state) p.id == id ? p.copyWith(trackKeys: [...p.trackKeys]..removeAt(index)) : p,
  ]);

  Future<void> moveTrack(String id, int from, int to) => _commit([
    for (final p in state)
      if (p.id == id)
        p.copyWith(
          trackKeys: () {
            final keys = [...p.trackKeys];
            final k = keys.removeAt(from);
            keys.insert(to, k);
            return keys;
          }(),
        )
      else
        p,
  ]);

  /// Drops a deleted track from every playlist.
  Future<void> forgetTrack(String key) =>
      _commit([for (final p in state) p.copyWith(trackKeys: p.trackKeys.where((k) => k != key).toList())]);
}

final playlistsProvider = NotifierProvider<PlaylistsNotifier, List<Playlist>>(PlaylistsNotifier.new);

final playlistProvider = Provider.family<Playlist?, String>((ref, id) {
  for (final p in ref.watch(playlistsProvider)) {
    if (p.id == id) return p;
  }
  return null;
});

/// Resolved tracks for a playlist, keeping their index in the stored list so
/// removal and reordering stay correct even if some songs are missing.
final playlistTracksProvider = Provider.family<List<(int, Track)>, String>((ref, id) {
  final playlist = ref.watch(playlistProvider(id));
  if (playlist == null) return const [];
  final byKey = ref.watch(tracksByKeyProvider);
  final blocked = ref.watch(blocklistProvider);
  return [
    for (var i = 0; i < playlist.trackKeys.length; i++)
      if (byKey[playlist.trackKeys[i]] case final t? when !blocked.contains(t.key)) (i, t),
  ];
});
