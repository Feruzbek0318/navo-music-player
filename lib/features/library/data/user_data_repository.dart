import '../../../core/storage/local_store.dart';
import 'sorting.dart';

/// Persists per-user library data: favourites, blocklist, listening history,
/// recent searches and sort choices.
class UserDataRepository {
  UserDataRepository(this._store);

  final LocalStore _store;

  static const maxRecent = 50;
  static const maxSearches = 12;

  List<String> favorites() => _store.stringList(StoreKeys.favorites);
  Future<void> saveFavorites(List<String> keys) => _store.putStringList(StoreKeys.favorites, keys);

  List<String> blocklist() => _store.stringList(StoreKeys.blocklist);
  Future<void> saveBlocklist(List<String> keys) => _store.putStringList(StoreKeys.blocklist, keys);

  List<String> recentlyPlayed() => _store.stringList(StoreKeys.recentlyPlayed);
  Map<String, int> playCounts() => _store.intMap(StoreKeys.playCounts);
  Future<void> saveHistory(List<String> recent, Map<String, int> counts) async {
    await _store.putStringList(StoreKeys.recentlyPlayed, recent);
    await _store.putIntMap(StoreKeys.playCounts, counts);
  }

  List<String> recentSearches() => _store.stringList(StoreKeys.recentSearches);
  Future<void> saveRecentSearches(List<String> v) => _store.putStringList(StoreKeys.recentSearches, v);

  /// Saved playing queue: keys, current index and position (ms).
  (List<String>, int, int) savedQueue() {
    final state = _store.intMap(StoreKeys.queueState);
    return (_store.stringList(StoreKeys.queueKeys), state['index'] ?? 0, state['position'] ?? 0);
  }

  Future<void> saveQueue(List<String> keys, int index, int positionMs) async {
    await _store.putStringList(StoreKeys.queueKeys, keys);
    await _store.putIntMap(StoreKeys.queueState, {'index': index, 'position': positionMs});
  }

  SortOption sort(LibrarySection section) {
    final name = _store.setting<String>('${StoreKeys.sortPrefix}${section.name}');
    final option = SortOption.values.asNameMap()[name];
    return option != null && section.options.contains(option) ? option : SortOption.ascending;
  }

  Future<void> saveSort(LibrarySection section, SortOption option) =>
      _store.putSetting('${StoreKeys.sortPrefix}${section.name}', option.name);
}
