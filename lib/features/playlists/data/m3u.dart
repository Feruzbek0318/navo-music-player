import '../../library/data/models.dart';

/// Reads and writes extended M3U playlists.
abstract final class M3u {
  static String export(List<Track> tracks) {
    final b = StringBuffer('#EXTM3U\n');
    for (final t in tracks) {
      final name = [if (t.artist != null) t.artist, t.title].join(' - ');
      b
        ..writeln('#EXTINF:${t.duration.inSeconds},$name')
        ..writeln(t.path ?? t.uri);
    }
    return b.toString();
  }

  static String _fileName(String path) {
    final p = path.replaceAll(r'\', '/');
    return Uri.decodeFull(p.substring(p.lastIndexOf('/') + 1)).toLowerCase();
  }

  static String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Matches playlist entries to [library] by full path, then file name, then
  /// "Artist - Title" from `#EXTINF`. Unmatched entries are skipped.
  static List<Track> match(String content, List<Track> library) {
    final byPath = {
      for (final t in library)
        if (t.path != null) t.path!: t,
    };
    final byFile = <String, Track>{
      for (final t in library)
        if (t.path != null) _fileName(t.path!): t,
    };
    final byName = <String, Track>{
      for (final t in library) _norm([if (t.artist != null) t.artist!, t.title].join(' - ')): t,
      for (final t in library) _norm(t.title): t,
    };

    final out = <Track>[];
    final seen = <String>{};
    String? pendingName;
    for (final raw in content.split(RegExp(r'\r?\n'))) {
      final line = raw.trim().replaceFirst('﻿', '');
      if (line.isEmpty) continue;
      if (line.startsWith('#EXTINF')) {
        final comma = line.indexOf(',');
        pendingName = comma < 0 ? null : line.substring(comma + 1).trim();
        continue;
      }
      if (line.startsWith('#')) continue;
      final path = line.startsWith('file://') ? Uri.decodeFull(line.substring(7)) : line;
      final t = byPath[path] ?? byFile[_fileName(path)] ?? (pendingName == null ? null : byName[_norm(pendingName)]);
      pendingName = null;
      if (t != null && seen.add(t.key)) out.add(t);
    }
    return out;
  }
}
