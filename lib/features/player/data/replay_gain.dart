import 'dart:io';
import 'dart:math' as math;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';

import '../../library/data/models.dart';

/// Reads ReplayGain track gain from file tags (ID3 TXXX or Vorbis comments)
/// and turns it into a volume factor. Tracks without tags play unchanged.
class ReplayGainRepository {
  final _cache = <String, double?>{};

  /// Volume multiplier (0.25…1) or null when the file has no ReplayGain tag.
  Future<double?> factorFor(Track track) async {
    if (_cache.containsKey(track.key)) return _cache[track.key];
    final path = track.path;
    final gain = path == null ? null : await compute(_readTrackGain, path);
    return _cache[track.key] = gain == null ? null : factorForGain(gain);
  }

  /// Most files are tagged around −6 to −10 dB relative to the ReplayGain
  /// reference; a +6 dB pre-amp keeps average loudness close to untagged
  /// files. Values above 1 can't be applied through the player volume.
  static double factorForGain(double gainDb) => math.pow(10, (gainDb + 6) / 20).toDouble().clamp(0.25, 1.0);

  static double? parseGain(String? raw) {
    if (raw == null) return null;
    final m = RegExp(r'([-+]?\d+(?:[.,]\d+)?)').firstMatch(raw);
    return m == null ? null : double.tryParse(m.group(1)!.replaceAll(',', '.'));
  }
}

double? _readTrackGain(String path) {
  try {
    final tag = readAllMetadata(File(path), getImage: false);
    String? raw;
    if (tag is Mp3Metadata) {
      for (final e in tag.customMetadata.entries) {
        if (e.key.toUpperCase() == 'REPLAYGAIN_TRACK_GAIN') raw = e.value;
      }
    } else if (tag is VorbisMetadata && tag.replayGainTrackGain.isNotEmpty) {
      raw = tag.replayGainTrackGain.first;
    }
    return ReplayGainRepository.parseGain(raw);
  } catch (_) {
    return null;
  }
}
