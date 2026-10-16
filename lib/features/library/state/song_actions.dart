import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/platform/device_bridge.dart';
import '../../player/state/player_providers.dart';
import '../../playlists/state/playlist_providers.dart';
import '../data/models.dart';
import 'library_providers.dart';

enum DeleteResult { deleted, cancelled, unsupported }

/// Song-level operations shared by every menu in the app.
class SongActions {
  SongActions(this._ref);

  final Ref _ref;

  Future<bool> toggleFavorite(Track t) => _ref.read(favoritesProvider.notifier).toggle(t.key);

  Future<void> block(Track t) async {
    await _ref.read(blocklistProvider.notifier).block(t.key);
    await _ref.read(playerControllerProvider).dropFromQueue({t.key});
  }

  Future<void> unblock(String key) => _ref.read(blocklistProvider.notifier).unblock(key);

  Future<RingtoneResult> setRingtone(Track t) async {
    final id = t.mediaId;
    if (id == null) return RingtoneResult.failed;
    return _ref.read(deviceBridgeProvider).setRingtone(id);
  }

  Future<DeleteResult> delete(Track t) => deleteMany([t]);

  /// Deletes device songs (demo tracks are skipped). The system confirms once
  /// for the whole batch on Android 11+.
  Future<DeleteResult> deleteMany(List<Track> tracks) async {
    final device = tracks.where((t) => t.mediaId != null).toList();
    if (device.isEmpty) return DeleteResult.unsupported;
    final ok = await _ref.read(deviceBridgeProvider).deleteAudio([for (final t in device) t.mediaId!]);
    if (!ok) return DeleteResult.cancelled;
    final keys = {for (final t in device) t.key};
    await _ref.read(playerControllerProvider).dropFromQueue(keys);
    for (final k in keys) {
      if (_ref.read(favoritesProvider).contains(k)) await _ref.read(favoritesProvider.notifier).toggle(k);
      await _ref.read(playlistsProvider.notifier).forgetTrack(k);
    }
    await _ref.read(deviceTracksProvider.notifier).rescan();
    return DeleteResult.deleted;
  }

  /// Adds every song to favourites (keeps ones already there).
  Future<void> favoriteMany(List<Track> tracks) async {
    final fav = _ref.read(favoritesProvider);
    for (final t in tracks.reversed) {
      if (!fav.contains(t.key)) await _ref.read(favoritesProvider.notifier).toggle(t.key);
    }
  }

  /// Opens the system share sheet with the audio file.
  Future<void> share(Track t, {Rect? origin}) async {
    final path = await _ref.read(musicRepositoryProvider).shareablePath(t);
    final text = [t.title, if (t.artist != null) t.artist].join(' — ');
    await SharePlus.instance.share(
      ShareParams(
        files: path == null ? null : [XFile(path)],
        text: path == null ? text : null,
        subject: text,
        sharePositionOrigin: origin,
      ),
    );
  }

  /// Shares several songs at once (artist / album / playlist menus).
  Future<void> shareMany(List<Track> tracks, {Rect? origin}) async {
    final repo = _ref.read(musicRepositoryProvider);
    final paths = <String>[];
    for (final t in tracks.take(20)) {
      final p = await repo.shareablePath(t);
      if (p != null) paths.add(p);
    }
    if (paths.isEmpty) return;
    await SharePlus.instance.share(ShareParams(files: paths.map(XFile.new).toList(), sharePositionOrigin: origin));
  }
}

final songActionsProvider = Provider<SongActions>((ref) => SongActions(ref));
