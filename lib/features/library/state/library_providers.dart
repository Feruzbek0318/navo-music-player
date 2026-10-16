import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/storage/local_store.dart';
import '../../settings/state/settings_providers.dart';
import '../data/demo_catalog.dart';
import '../data/library_cache.dart';
import '../data/library_filter.dart';
import '../data/models.dart';
import '../data/music_repository.dart';
import '../data/sorting.dart';
import '../data/user_data_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) => MusicRepository(ref.watch(deviceBridgeProvider)));

final userDataRepositoryProvider = Provider<UserDataRepository>(
  (ref) => UserDataRepository(ref.watch(localStoreProvider)),
);

// ---------------------------------------------------------------------------
// Permission & scanning
// ---------------------------------------------------------------------------

class PermissionNotifier extends AsyncNotifier<LibraryPermission> {
  @override
  Future<LibraryPermission> build() => ref.read(musicRepositoryProvider).permissionStatus();

  Future<void> request() async {
    final result = await ref.read(musicRepositoryProvider).requestPermission();
    state = AsyncData(result);
  }

  /// Re-checks after the user returns from the system settings.
  Future<void> recheck() async {
    final result = await ref.read(musicRepositoryProvider).permissionStatus();
    if (state.value != result) state = AsyncData(result);
  }
}

final libraryPermissionProvider = AsyncNotifierProvider<PermissionNotifier, LibraryPermission>(PermissionNotifier.new);

final libraryCacheProvider = Provider<LibraryCache>((ref) => LibraryCache(ref.watch(localStoreProvider)));

/// True while a media-store scan is running.
class ScanningNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool v) => state = v;
}

final scanningProvider = NotifierProvider<ScanningNotifier, bool>(ScanningNotifier.new);

/// Every song on the device (unfiltered; empty until permission is granted).
/// Shows the cached scan immediately, then rescans in the background when
/// "scan on launch" is on.
class DeviceLibraryNotifier extends AsyncNotifier<List<Track>> {
  Future<List<Track>>? _running;

  @override
  Future<List<Track>> build() async {
    final permission = await ref.watch(libraryPermissionProvider.future);
    if (permission != LibraryPermission.granted) return const [];
    final cached = await ref.read(libraryCacheProvider).load();
    if (cached != null) {
      if (ref.read(librarySettingsProvider).scanOnLaunch) Future.microtask(rescan);
      return cached;
    }
    return _scan();
  }

  Future<List<Track>> _scan() => _running ??= () async {
    ref.read(scanningProvider.notifier).set(true);
    try {
      final tracks = await ref.read(musicRepositoryProvider).deviceTracks();
      await ref.read(libraryCacheProvider).save(tracks);
      return tracks;
    } finally {
      ref.read(scanningProvider.notifier).set(false);
      _running = null;
    }
  }();

  /// Scans the media store again; returns the number of songs found.
  Future<int> rescan() async {
    final permission = await ref.read(musicRepositoryProvider).permissionStatus();
    if (permission != LibraryPermission.granted) {
      ref.invalidate(libraryPermissionProvider);
      return 0;
    }
    try {
      final tracks = await _scan();
      state = AsyncData(tracks);
      return tracks.length;
    } catch (e, st) {
      state = AsyncError(e, st);
      return 0;
    }
  }
}

final deviceTracksProvider = AsyncNotifierProvider<DeviceLibraryNotifier, List<Track>>(DeviceLibraryNotifier.new);

class BlocklistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(userDataRepositoryProvider).blocklist().toSet();

  Future<void> block(String key) => _save({...state, key});
  Future<void> unblock(String key) => _save({...state}..remove(key));

  Future<void> _save(Set<String> next) async {
    state = next;
    await ref.read(userDataRepositoryProvider).saveBlocklist(next.toList());
  }
}

final blocklistProvider = NotifierProvider<BlocklistNotifier, Set<String>>(BlocklistNotifier.new);

/// Every track that passes the library filters, including blocked ones
/// (used to resolve stored keys).
final knownTracksProvider = FutureProvider<List<Track>>((ref) async {
  final all = await ref.watch(deviceTracksProvider.future);
  final device = LibraryFilter.apply(all, ref.watch(librarySettingsProvider));
  final demo = ref.watch(showDemoTracksProvider) ? DemoCatalog.tracks : const <Track>[];
  return [...device, ...demo];
});

/// The visible library: device + demo tracks minus the blocklist.
final libraryTracksProvider = FutureProvider<List<Track>>((ref) async {
  final all = await ref.watch(knownTracksProvider.future);
  final blocked = ref.watch(blocklistProvider);
  return all.where((t) => !blocked.contains(t.key)).toList(growable: false);
});

final tracksByKeyProvider = Provider<Map<String, Track>>((ref) {
  final all = ref.watch(knownTracksProvider).value ?? const [];
  return {for (final t in all) t.key: t};
});

/// Forces a fresh media-store scan.
Future<int> rescanLibrary(WidgetRef ref) => ref.read(deviceTracksProvider.notifier).rescan();

// ---------------------------------------------------------------------------
// Sorting & grouping
// ---------------------------------------------------------------------------

class SortNotifier extends Notifier<SortOption> {
  SortNotifier(this.section);

  final LibrarySection section;

  @override
  SortOption build() => ref.read(userDataRepositoryProvider).sort(section);

  Future<void> set(SortOption option) async {
    state = option;
    await ref.read(userDataRepositoryProvider).saveSort(section, option);
  }
}

final sortProvider = NotifierProvider.family<SortNotifier, SortOption, LibrarySection>(SortNotifier.new);

final sortedSongsProvider = FutureProvider<List<Track>>((ref) async {
  final tracks = await ref.watch(libraryTracksProvider.future);
  return sortTracks(tracks, ref.watch(sortProvider(LibrarySection.songs)));
});

final albumsProvider = FutureProvider<List<TrackCollection>>((ref) async {
  final tracks = await ref.watch(libraryTracksProvider.future);
  return sortCollections(Grouping.albums(tracks), ref.watch(sortProvider(LibrarySection.albums)));
});

final artistsProvider = FutureProvider<List<TrackCollection>>((ref) async {
  final tracks = await ref.watch(libraryTracksProvider.future);
  final lib = ref.watch(librarySettingsProvider);
  return sortCollections(
    Grouping.artists(tracks, split: lib.splitArtists, byAlbumArtist: lib.groupByAlbumArtist),
    ref.watch(sortProvider(LibrarySection.artists)),
  );
});

final foldersProvider = FutureProvider<List<TrackCollection>>((ref) async {
  final tracks = await ref.watch(libraryTracksProvider.future);
  return sortCollections(Grouping.folders(tracks), ref.watch(sortProvider(LibrarySection.folders)));
});

/// Looks up a single collection by kind and id (detail pages).
final collectionProvider = Provider.family<TrackCollection?, (CollectionKind, String)>((ref, arg) {
  final (kind, id) = arg;
  final source = switch (kind) {
    CollectionKind.album => ref.watch(albumsProvider),
    CollectionKind.artist => ref.watch(artistsProvider),
    CollectionKind.folder => ref.watch(foldersProvider),
    CollectionKind.playlist => const AsyncData(<TrackCollection>[]),
  };
  final list = source.value ?? const [];
  for (final c in list) {
    if (c.id == id) {
      return TrackCollection(
        id: c.id,
        kind: c.kind,
        name: c.name,
        subtitle: c.subtitle,
        tracks: sortTracks(c.tracks, SortOption.ascending),
      );
    }
  }
  return null;
});

/// Artist page id for [t] under the current grouping settings.
String artistIdFor(WidgetRef ref, Track t) {
  final lib = ref.read(librarySettingsProvider);
  return Grouping.artistIdFor(t, split: lib.splitArtists, byAlbumArtist: lib.groupByAlbumArtist);
}

// ---------------------------------------------------------------------------
// Favourites & listening history
// ---------------------------------------------------------------------------

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(userDataRepositoryProvider).favorites();

  bool isFavorite(String key) => state.contains(key);

  /// Returns the new favourite state.
  Future<bool> toggle(String key) async {
    final adding = !state.contains(key);
    final next = adding ? [key, ...state] : (state.toList()..remove(key));
    state = next;
    await ref.read(userDataRepositoryProvider).saveFavorites(next);
    return adding;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(FavoritesNotifier.new);

final isFavoriteProvider = Provider.family<bool, String>((ref, key) => ref.watch(favoritesProvider).contains(key));

final favoriteTracksProvider = Provider<List<Track>>((ref) {
  final byKey = ref.watch(tracksByKeyProvider);
  final blocked = ref.watch(blocklistProvider);
  return [
    for (final k in ref.watch(favoritesProvider))
      if (byKey[k] != null && !blocked.contains(k)) byKey[k]!,
  ];
});

class HistoryState {
  const HistoryState({required this.recent, required this.counts});

  final List<String> recent;
  final Map<String, int> counts;
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    final repo = ref.read(userDataRepositoryProvider);
    return HistoryState(recent: repo.recentlyPlayed(), counts: repo.playCounts());
  }

  Future<void> record(String key) async {
    final recent = [key, ...state.recent.where((k) => k != key)].take(UserDataRepository.maxRecent).toList();
    final counts = {...state.counts, key: (state.counts[key] ?? 0) + 1};
    state = HistoryState(recent: recent, counts: counts);
    await ref.read(userDataRepositoryProvider).saveHistory(recent, counts);
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

final recentlyPlayedProvider = Provider<List<Track>>((ref) {
  final byKey = ref.watch(tracksByKeyProvider);
  final blocked = ref.watch(blocklistProvider);
  return [
    for (final k in ref.watch(historyProvider).recent)
      if (byKey[k] != null && !blocked.contains(k)) byKey[k]!,
  ];
});

final mostPlayedProvider = Provider<List<Track>>((ref) {
  final byKey = ref.watch(tracksByKeyProvider);
  final blocked = ref.watch(blocklistProvider);
  final entries =
      ref
          .watch(historyProvider)
          .counts
          .entries
          .where((e) => byKey.containsKey(e.key) && !blocked.contains(e.key))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  return [for (final e in entries.take(20)) byKey[e.key]!];
});

final playCountProvider = Provider.family<int, String>((ref, key) => ref.watch(historyProvider).counts[key] ?? 0);
