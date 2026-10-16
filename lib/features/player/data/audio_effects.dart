import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../settings/data/app_settings.dart';

/// One device equalizer band.
@immutable
class EqBand {
  const EqBand({required this.centerHz, required this.minDb, required this.maxDb});

  final double centerHz;
  final double minDb;
  final double maxDb;
}

/// Built-in presets, defined at reference frequencies and mapped onto
/// whatever bands the device equalizer exposes.
abstract final class EqPresets {
  static const referenceHz = [60.0, 230.0, 910.0, 3600.0, 14000.0];

  static const builtIn = <String, List<double>>{
    'normal': [0, 0, 0, 0, 0],
    'bass': [6, 4, 0, 0, 0],
    'treble': [0, 0, 0, 3, 6],
    'rock': [5, 3, -1, 3, 5],
    'pop': [-1, 2, 4, 2, -1],
    'jazz': [4, 2, -1, 2, 4],
    'classical': [4, 3, -2, 3, 4],
    'vocal': [-2, 0, 4, 3, 0],
  };

  /// Interpolates [curve] (dB at [referenceHz]) at [hz] on a log scale.
  static double gainAt(List<double> curve, double hz) {
    final x = math.log(hz.clamp(referenceHz.first, referenceHz.last));
    for (var i = 0; i < referenceHz.length - 1; i++) {
      final a = math.log(referenceHz[i]);
      final b = math.log(referenceHz[i + 1]);
      if (x <= b) {
        final t = (x - a) / (b - a);
        return curve[i] + (curve[i + 1] - curve[i]) * t;
      }
    }
    return curve.last;
  }

  /// Gains for [bands] from a reference-frequency [curve].
  static List<double> forBands(List<double> curve, List<EqBand> bands) => [
    for (final b in bands) gainAt(curve, b.centerHz).clamp(b.minDb, b.maxDb),
  ];
}

/// Owns the Android equalizer and loudness enhancer that sit in the player's
/// audio pipeline. On other platforms everything is a no-op.
class AudioEffects {
  AudioEffects()
    : equalizer = Platform.isAndroid ? AndroidEqualizer() : null,
      loudness = Platform.isAndroid ? AndroidLoudnessEnhancer() : null;

  final AndroidEqualizer? equalizer;
  final AndroidLoudnessEnhancer? loudness;

  bool get supported => equalizer != null;

  AudioPipeline? get pipeline => equalizer == null ? null : AudioPipeline(androidAudioEffects: [equalizer!, loudness!]);

  List<EqBand>? _bands;

  /// Device bands, available once the player has loaded something.
  Future<List<EqBand>?> bands() async {
    if (_bands != null || equalizer == null) return _bands;
    try {
      final p = await equalizer!.parameters.timeout(const Duration(seconds: 3));
      _bands = [
        for (final b in p.bands) EqBand(centerHz: b.centerFrequency, minDb: p.minDecibels, maxDb: p.maxDecibels),
      ];
    } catch (e) {
      debugPrint('Equalizer unavailable: $e');
    }
    return _bands;
  }

  /// Gains to use for [s] on [bands]: the preset (or manual bands) plus bass boost.
  static List<double> baseGains(AudioSettings s, List<EqBand> bands) {
    final builtIn = EqPresets.builtIn[s.eqPreset];
    if (builtIn != null) return EqPresets.forBands(builtIn, bands);
    // Custom presets and manual tweaks store one value per device band.
    final values = s.customPresets[s.eqPreset] ?? s.bandGains;
    return [for (var i = 0; i < bands.length; i++) i < values.length ? values[i] : 0.0];
  }

  static List<double> targetGains(AudioSettings s, List<EqBand> bands) {
    final base = s.eqEnabled ? baseGains(s, bands) : List<double>.filled(bands.length, 0);
    // Bass boost: up to +8 dB, fading out above ~250 Hz.
    return [
      for (var i = 0; i < bands.length; i++)
        (base[i] + s.bassBoost * 8 * (1 - ((bands[i].centerHz - 60) / 190).clamp(0.0, 1.0))).clamp(
          bands[i].minDb,
          bands[i].maxDb,
        ),
    ];
  }

  Future<void> apply(AudioSettings s) async {
    final eq = equalizer;
    if (eq == null) return;
    try {
      final enabled = s.eqEnabled || s.bassBoost > 0;
      await eq.setEnabled(enabled);
      if (enabled) {
        final deviceBands = await bands();
        if (deviceBands != null) {
          final gains = targetGains(s, deviceBands);
          final params = await eq.parameters;
          for (var i = 0; i < params.bands.length && i < gains.length; i++) {
            await params.bands[i].setGain(gains[i]);
          }
        }
      }
      await loudness!.setEnabled(s.loudness > 0);
      // Up to +9 dB of make-up gain.
      if (s.loudness > 0) await loudness!.setTargetGain(s.loudness * 9);
    } catch (e) {
      debugPrint('Applying audio effects failed: $e');
    }
  }
}
