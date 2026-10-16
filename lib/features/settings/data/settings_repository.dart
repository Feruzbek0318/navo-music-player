import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import 'app_settings.dart';

/// Loads and saves [AppSettings] as one JSON document in the settings box.
class SettingsRepository {
  SettingsRepository(this._store);

  final LocalStore _store;
  Timer? _debounce;
  AppSettings? _pending;

  static const _key = 'app_settings';
  static const _legacyKeys = ['locale', 'artwork_style', 'show_demo', 'speed', 'volume'];

  AppSettings load() {
    Map<String, Object?>? stored;
    final raw = _store.setting<String>(_key);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) stored = decoded.cast<String, Object?>();
      } catch (e) {
        debugPrint('Settings were unreadable, using defaults: $e');
      }
    }
    final legacy = {for (final k in _legacyKeys) k: _store.setting<Object>(k)};
    final migrated = migrateSettings(stored, legacy: legacy);
    final settings = AppSettings.fromJson(migrated);
    if (stored == null && legacy.values.any((v) => v != null)) {
      // Persist the migrated document once and drop the old keys.
      unawaited(_write(settings).then((_) => Future.wait(_legacyKeys.map((k) => _store.putSetting(k, null)))));
    }
    return settings;
  }

  /// Saves after a short pause so sliders don't write on every tick.
  void save(AppSettings settings) {
    _pending = settings;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), flush);
  }

  Future<void> flush() async {
    _debounce?.cancel();
    final s = _pending;
    _pending = null;
    if (s != null) await _write(s);
  }

  Future<void> _write(AppSettings s) => _store.putSetting(_key, jsonEncode(s.toJson()));
}
