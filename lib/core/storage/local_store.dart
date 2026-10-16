import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Thin wrapper around the Hive boxes used for local persistence.
///
/// Values are stored as primitives, lists and maps, so no type adapters are
/// needed.
class LocalStore {
  LocalStore._(this._settings, this._library);

  final Box<dynamic> _settings;
  final Box<dynamic> _library;

  static Future<LocalStore> open() async {
    await Hive.initFlutter('navo');
    return _openBoxes();
  }

  /// Opens the boxes in [directory] (tests).
  @visibleForTesting
  static Future<LocalStore> openAt(String directory) async {
    Hive.init(directory);
    return _openBoxes();
  }

  static Future<LocalStore> _openBoxes() async {
    final settings = await Hive.openBox<dynamic>('settings');
    final library = await Hive.openBox<dynamic>('library');
    return LocalStore._(settings, library);
  }

  T? setting<T>(String key) => _settings.get(key) as T?;
  Future<void> putSetting(String key, Object? value) =>
      value == null ? _settings.delete(key) : _settings.put(key, value);

  List<String> stringList(String key) => (_library.get(key) as List?)?.cast<String>() ?? const [];
  Future<void> putStringList(String key, List<String> value) => _library.put(key, value);

  Map<String, int> intMap(String key) =>
      (_library.get(key) as Map?)?.map((k, v) => MapEntry(k as String, v as int)) ?? const {};
  Future<void> putIntMap(String key, Map<String, int> value) => _library.put(key, value);

  String? libraryString(String key) => _library.get(key) as String?;
  Future<void> putLibraryString(String key, String value) => _library.put(key, value);

  List<Map<String, dynamic>> mapList(String key) =>
      (_library.get(key) as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? const [];
  Future<void> putMapList(String key, List<Map<String, dynamic>> value) => _library.put(key, value);
}

abstract final class StoreKeys {
  // settings box
  static const onboardingSeen = 'onboarding_seen';
  static const sortPrefix = 'sort_';
  static const batteryHintShown = 'battery_hint_shown';

  // library box
  static const favorites = 'favorites';
  static const blocklist = 'blocklist';
  static const recentlyPlayed = 'recently_played';
  static const playCounts = 'play_counts';
  static const recentSearches = 'recent_searches';
  static const playlists = 'playlists';
  static const queueKeys = 'queue_keys';
  static const queueState = 'queue_state';
  static const listeningLog = 'listening_log';
  static const scanCache = 'scan_cache';
}

/// Overridden in `main()` once the boxes are open.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider must be overridden'),
);
