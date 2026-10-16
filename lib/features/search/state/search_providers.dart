import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../library/data/models.dart';
import '../../library/data/user_data_repository.dart';
import '../../library/state/library_providers.dart';

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(userDataRepositoryProvider).recentSearches();

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.length < 2) return;
    final next = [
      q,
      ...state.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(UserDataRepository.maxSearches).toList();
    await _save(next);
  }

  Future<void> remove(String query) => _save(state.where((s) => s != query).toList());
  Future<void> clear() => _save(const []);

  Future<void> _save(List<String> next) async {
    state = next;
    await ref.read(userDataRepositoryProvider).saveRecentSearches(next);
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String q) => state = q;
}

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

@immutable
class SearchResults {
  const SearchResults({required this.songs, required this.artists, required this.albums});

  static const empty = SearchResults(songs: [], artists: [], albums: []);

  final List<Track> songs;
  final List<TrackCollection> artists;
  final List<TrackCollection> albums;

  bool get isEmpty => songs.isEmpty && artists.isEmpty && albums.isEmpty;
}

/// Case- and accent-insensitive matching on titles, artists and albums.
final searchResultsProvider = Provider.autoDispose<SearchResults>((ref) {
  final q = normalizeForSearch(ref.watch(searchQueryProvider));
  if (q.isEmpty) return SearchResults.empty;
  bool hit(String? s) => s != null && normalizeForSearch(s).contains(q);

  final songs = ref.watch(sortedSongsProvider).value ?? const [];
  final artists = ref.watch(artistsProvider).value ?? const [];
  final albums = ref.watch(albumsProvider).value ?? const [];
  return SearchResults(
    songs: songs.where((t) => hit(t.title) || hit(t.artist) || hit(t.album)).take(50).toList(),
    artists: artists.where((a) => hit(a.name)).take(10).toList(),
    albums: albums.where((a) => hit(a.name) || hit(a.subtitle)).take(10).toList(),
  );
});

/// Lower-cases and folds Uzbek apostrophe variants so "o'zbek" == "oʻzbek".
String normalizeForSearch(String s) => s.toLowerCase().replaceAll(RegExp('[ʻʼ‘’`´]'), "'").replaceAll('ё', 'е').trim();
