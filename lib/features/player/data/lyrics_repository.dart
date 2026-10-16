import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../library/data/models.dart';

@immutable
class LyricLine {
  const LyricLine(this.time, this.text);

  /// `null` for unsynced lyrics.
  final Duration? time;
  final String text;
}

@immutable
class Lyrics {
  const Lyrics(this.lines);

  final List<LyricLine> lines;

  bool get isSynced => lines.isNotEmpty && lines.every((l) => l.time != null);

  /// Index of the line active at [position], or -1 before the first line.
  int indexAt(Duration position) {
    if (!isSynced) return -1;
    var lo = 0;
    var hi = lines.length - 1;
    var result = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lines[mid].time! <= position) {
        result = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return result;
  }
}

/// Parses LRC text (`[mm:ss.xx] line`), falling back to plain lines.
Lyrics? parseLyrics(String raw) {
  final timeTag = RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');
  final metaTag = RegExp(r'^\[[a-zA-Z]+:.*\]$');
  final synced = <LyricLine>[];
  final plain = <LyricLine>[];

  for (final rawLine in const LineSplitter().convert(raw)) {
    final line = rawLine.trim();
    if (line.isEmpty || metaTag.hasMatch(line)) continue;
    final tags = timeTag.allMatches(line).toList();
    if (tags.isEmpty) {
      plain.add(LyricLine(null, line));
      continue;
    }
    final text = line.substring(tags.last.end).trim();
    for (final m in tags) {
      final frac = m.group(3) ?? '0';
      final ms = int.parse(frac.padRight(3, '0').substring(0, 3));
      synced.add(
        LyricLine(Duration(minutes: int.parse(m.group(1)!), seconds: int.parse(m.group(2)!), milliseconds: ms), text),
      );
    }
  }

  if (synced.isNotEmpty) {
    synced.sort((a, b) => a.time!.compareTo(b.time!));
    return Lyrics(synced);
  }
  return plain.isEmpty ? null : Lyrics(plain);
}

/// Finds lyrics for a track. Only reads what the user already has: a sidecar
/// `.lrc` file, lyrics embedded in the file's tags, or the bundled demo LRCs.
class LyricsRepository {
  final _cache = <String, Lyrics?>{};

  Future<Lyrics?> lyricsFor(Track track) async {
    if (_cache.containsKey(track.key)) return _cache[track.key];
    final result = await _load(track);
    return _cache[track.key] = result;
  }

  Future<Lyrics?> _load(Track track) async {
    try {
      if (track.assetLyrics != null) {
        return parseLyrics(await rootBundle.loadString(track.assetLyrics!));
      }
      final path = track.path;
      if (path == null) return null;

      final dot = path.lastIndexOf('.');
      final base = dot > 0 ? path.substring(0, dot) : path;
      for (final candidate in ['$base.lrc', '$base.LRC']) {
        final file = File(candidate);
        if (await file.exists()) return parseLyrics(await file.readAsString());
      }

      final embedded = await compute(_readEmbedded, path);
      return embedded == null ? null : parseLyrics(embedded);
    } catch (e) {
      debugPrint('Lyrics lookup failed for ${track.key}: $e');
      return null;
    }
  }
}

String? _readEmbedded(String path) {
  try {
    final lyrics = readMetadata(File(path)).lyrics;
    return lyrics == null || lyrics.trim().isEmpty ? null : lyrics;
  } catch (_) {
    return null;
  }
}
