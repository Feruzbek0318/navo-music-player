import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../../library/state/library_providers.dart';
import '../../playlists/state/playlist_providers.dart';
import 'settings_providers.dart';

/// What a backup file holds: settings plus the user's own library data
/// (favourites, playlists, hidden songs). Music files are never included.
@immutable
class NavoBackup {
  const NavoBackup({
    required this.settings,
    required this.favorites,
    required this.blocklist,
    required this.playlists,
  });

  static const format = 'navo-backup';
  static const version = 1;

  final Map<String, Object?> settings;
  final List<String> favorites;
  final List<String> blocklist;
  final List<Map<String, dynamic>> playlists;

  String encode() => const JsonEncoder.withIndent('  ').convert({
    'format': format,
    'version': version,
    'createdAt': DateTime.now().toIso8601String(),
    'settings': settings,
    'favorites': favorites,
    'blocklist': blocklist,
    'playlists': playlists,
  });

  /// Throws [FormatException] when [source] isn't a Navo backup.
  static NavoBackup decode(String source) {
    final j = jsonDecode(source);
    if (j is! Map || j['format'] != format) throw const FormatException('Not a Navo backup');
    if ((j['version'] as num? ?? 0) > version) throw const FormatException('Backup is from a newer Navo');
    List<String> strings(Object? v) => v is List ? v.whereType<String>().toList() : const [];
    return NavoBackup(
      settings: j['settings'] is Map ? (j['settings'] as Map).cast<String, Object?>() : const {},
      favorites: strings(j['favorites']),
      blocklist: strings(j['blocklist']),
      playlists: j['playlists'] is List
          ? [for (final p in j['playlists'] as List) if (p is Map) Map<String, dynamic>.from(p)]
          : const [],
    );
  }
}

enum RestoreResult { restored, cancelled, invalid }

/// Exports / imports a [NavoBackup] through the system file picker.
class BackupService {
  BackupService(this._ref);

  final Ref _ref;

  LocalStore get _store => _ref.read(localStoreProvider);

  NavoBackup snapshot() => NavoBackup(
    settings: _ref.read(settingsProvider).toJson(),
    favorites: _store.stringList(StoreKeys.favorites),
    blocklist: _store.stringList(StoreKeys.blocklist),
    playlists: _store.mapList(StoreKeys.playlists),
  );

  /// Returns true when the file was written.
  Future<bool> export() async {
    await _ref.read(settingsProvider.notifier).flush();
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final bytes = Uint8List.fromList(utf8.encode(snapshot().encode()));
    final uri = await FilePicker.saveFile(
      fileName: 'navo-backup-$date.json',
      bytes: bytes,
      mimeType: 'application/json',
    );
    return uri != null;
  }

  Future<RestoreResult> import() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
    if (file == null) return RestoreResult.cancelled;
    final NavoBackup backup;
    try {
      backup = NavoBackup.decode(utf8.decode(await file.xFile.readAsBytes(), allowMalformed: true));
    } catch (e) {
      debugPrint('Backup rejected: $e');
      return RestoreResult.invalid;
    }
    await apply(backup);
    return RestoreResult.restored;
  }

  /// Writes [backup] and reloads everything that depends on it.
  Future<void> apply(NavoBackup backup) async {
    await _store.putStringList(StoreKeys.favorites, backup.favorites);
    await _store.putStringList(StoreKeys.blocklist, backup.blocklist);
    await _store.putMapList(StoreKeys.playlists, backup.playlists);
    _ref
      ..invalidate(favoritesProvider)
      ..invalidate(blocklistProvider)
      ..invalidate(playlistsProvider);
    final migrated = migrateSettings(backup.settings, legacy: const {});
    _ref.read(settingsProvider.notifier).replace(AppSettings.fromJson(migrated));
  }
}

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(ref));
