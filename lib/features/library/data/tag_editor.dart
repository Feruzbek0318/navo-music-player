import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/platform/device_bridge.dart';
import 'models.dart';

@immutable
class TagEdit {
  const TagEdit({
    required this.title,
    this.artist,
    this.album,
    this.year,
    this.artwork,
    this.artworkMime = 'image/jpeg',
    this.artworkChanged = false,
  });

  final String title;
  final String? artist;
  final String? album;
  final int? year;

  /// New cover; null with [artworkChanged] removes the cover.
  final Uint8List? artwork;
  final String artworkMime;
  final bool artworkChanged;
}

enum TagSaveResult { saved, cancelled, unsupported, failed }

/// Edits tags without breaking scoped storage: the file is copied to the
/// app's cache, edited there, and written back through MediaStore after the
/// system grants write access (Android 11+ shows one confirmation).
class TagEditor {
  TagEditor(this._bridge);

  final DeviceBridge _bridge;

  static const editableExtensions = {'mp3', 'flac', 'm4a', 'mp4', 'aac', 'ogg', 'opus', 'wav'};

  static bool canEdit(Track t) =>
      !t.isDemo && t.mediaId != null && t.path != null && editableExtensions.contains(t.extension.toLowerCase());

  Future<TagSaveResult> save(Track track, TagEdit edit) async {
    if (!canEdit(track)) return TagSaveResult.unsupported;
    final source = File(track.path!);
    final tmpDir = await getTemporaryDirectory();
    final copy = File('${tmpDir.path}/edit_${track.mediaId}.${track.extension}');
    try {
      await source.copy(copy.path);
      final ok = await compute(_applyTags, (copy.path, edit));
      if (!ok) return TagSaveResult.failed;
      if (!await _bridge.requestWrite([track.mediaId!])) return TagSaveResult.cancelled;
      if (!await _bridge.writeAudio(track.mediaId!, copy.path)) return TagSaveResult.failed;
      await _bridge.scanFile(track.path!);
      return TagSaveResult.saved;
    } catch (e) {
      debugPrint('Tag edit failed: $e');
      return TagSaveResult.failed;
    } finally {
      if (await copy.exists()) await copy.delete();
    }
  }
}

bool _applyTags((String, TagEdit) args) {
  final (path, e) = args;
  try {
    updateMetadata(File(path), (m) {
      m.setTitle(e.title.trim().isEmpty ? null : e.title.trim());
      m.setArtist(e.artist?.trim().isEmpty ?? true ? null : e.artist!.trim());
      m.setAlbum(e.album?.trim().isEmpty ?? true ? null : e.album!.trim());
      m.setYear(e.year == null ? null : DateTime(e.year!));
      if (e.artworkChanged) {
        m.setPictures(e.artwork == null ? [] : [Picture(e.artwork!, e.artworkMime, PictureType.coverFront)]);
      }
    });
    return true;
  } catch (err) {
    debugPrint('Writing tags failed: $err');
    return false;
  }
}
