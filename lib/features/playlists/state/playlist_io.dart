import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../library/data/models.dart';
import '../../library/state/library_providers.dart';
import '../data/m3u.dart';
import 'playlist_providers.dart';

/// Result of importing an M3U file.
@immutable
class M3uImport {
  const M3uImport(this.name, this.count);

  final String name;
  final int count;
}

/// Imports and exports playlists as M3U through the system file picker
/// (Storage Access Framework on Android).
class PlaylistIo {
  PlaylistIo(this._ref);

  final Ref _ref;

  /// Returns null when cancelled; count 0 when nothing matched.
  Future<M3uImport?> importM3u() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['m3u', 'm3u8']);
    if (file == null) return null;
    final content = utf8.decode(await file.xFile.readAsBytes(), allowMalformed: true);
    final library = await _ref.read(knownTracksProvider.future);
    final tracks = M3u.match(content, library);
    final name = file.name.replaceAll(RegExp(r'\.m3u8?$', caseSensitive: false), '');
    if (tracks.isNotEmpty) {
      await _ref.read(playlistsProvider.notifier).create(name, trackKeys: [for (final t in tracks) t.key]);
    }
    return M3uImport(name, tracks.length);
  }

  /// Returns true when the file was written.
  Future<bool> exportM3u(String name, List<Track> tracks) async {
    final bytes = Uint8List.fromList(utf8.encode(M3u.export(tracks)));
    final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final uri = await FilePicker.saveFile(fileName: '$safe.m3u8', bytes: bytes, mimeType: 'audio/x-mpegurl');
    return uri != null;
  }
}

final playlistIoProvider = Provider<PlaylistIo>((ref) => PlaylistIo(ref));
