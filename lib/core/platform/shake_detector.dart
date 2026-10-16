import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects a deliberate shake from the user accelerometer (gravity removed).
/// [sensitivity] 0…1: higher means a lighter shake is enough.
class ShakeDetector {
  ShakeDetector({required this.onShake, double sensitivity = 0.5}) : _threshold = thresholdFor(sensitivity);

  final VoidCallback onShake;
  final double _threshold;
  StreamSubscription<UserAccelerometerEvent>? _sub;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  int _hits = 0;
  DateTime _firstHit = DateTime.fromMillisecondsSinceEpoch(0);

  /// Acceleration (m/s²) a reading must exceed to count as a shake.
  static double thresholdFor(double sensitivity) => 26 - 14 * sensitivity.clamp(0.0, 1.0);

  void start() {
    _sub ??= userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) => onReading(e.x, e.y, e.z, DateTime.now()),
      onError: (Object e) => debugPrint('Accelerometer unavailable: $e'),
      cancelOnError: true,
    );
  }

  /// Two strong readings within 600 ms make a shake; then 1 s cool-down.
  @visibleForTesting
  void onReading(double x, double y, double z, DateTime now) {
    final g = math.sqrt(x * x + y * y + z * z);
    if (g < _threshold || now.difference(_last) < const Duration(seconds: 1)) return;
    if (now.difference(_firstHit) > const Duration(milliseconds: 600)) {
      _firstHit = now;
      _hits = 0;
    }
    if (++_hits >= 2) {
      _hits = 0;
      _last = now;
      onShake();
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
