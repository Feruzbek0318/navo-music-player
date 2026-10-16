import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../../library/data/models.dart';
import '../../../settings/state/settings_providers.dart';
import '../../../../core/theme/navo_theme.dart';

/// Large player artwork. Vinyl spins while playing and eases to a stop on
/// pause; the other styles show a rounded cover that shrinks a little when
/// paused (minimal keeps it smaller).
class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({
    super.key,
    required this.track,
    required this.playing,
    required this.style,
    required this.size,
    required this.heroTag,
  });

  final Track track;
  final bool playing;
  final PlayerStyle style;
  final double size;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final navo = context.navo;
    final shown = style == PlayerStyle.minimal ? size * 0.62 : size;
    return Hero(
      tag: heroTag,
      child: SizedBox.square(
        dimension: size,
        child: AnimatedSwitcher(
          duration: AppDurations.slow,
          switchInCurve: AppCurves.standard,
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: child),
          ),
          child: KeyedSubtree(
            key: ValueKey('${track.key}-${style.name}'),
            child: style == PlayerStyle.vinyl
                ? _Vinyl(track: track, playing: playing && !navo.animationsOff, size: size)
                : Center(
                    child: AnimatedScale(
                      scale: playing || navo.animationsOff ? 1 : 0.9,
                      duration: AppDurations.slow,
                      curve: AppCurves.standard,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: navo.radius(Radii.lg),
                          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 16))],
                        ),
                        child: TrackArtwork(track: track, size: shown, radius: Radii.lg),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Vinyl extends StatefulWidget {
  const _Vinyl({required this.track, required this.playing, required this.size});

  final Track track;
  final bool playing;
  final double size;

  @override
  State<_Vinyl> createState() => _VinylState();
}

class _VinylState extends State<_Vinyl> with SingleTickerProviderStateMixin {
  static const _secondsPerTurn = 12.0;
  static const _easeTime = 0.5; // seconds to reach full speed / stop

  late final Ticker _ticker = createTicker(_tick);
  final _angle = ValueNotifier<double>(0);
  double _velocity = 0; // 0..1 of full speed
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.playing) {
      _velocity = 1;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(_Vinyl old) {
    super.didUpdateWidget(old);
    if (widget.playing != old.playing && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 0.0 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final target = widget.playing ? 1.0 : 0.0;
    final step = dt / _easeTime;
    _velocity = _velocity < target ? math.min(target, _velocity + step) : math.max(target, _velocity - step);
    // Ease the speed curve so stopping feels like a real platter.
    final eased = Curves.easeOut.transform(_velocity);
    _angle.value = (_angle.value + eased * dt * 2 * math.pi / _secondsPerTurn) % (2 * math.pi);
    if (_velocity == 0 && !widget.playing) {
      _ticker.stop();
      _last = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _angle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: _angle,
        builder: (_, angle, child) => Transform.rotate(angle: angle, child: child),
        child: Container(
          width: s,
          height: s,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF121317),
            boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 16))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size.square(s), painter: _GroovePainter()),
              TrackArtwork(track: widget.track, size: s * 0.62, circle: true),
              Container(
                width: s * 0.07,
                height: s * 0.07,
                decoration: const BoxDecoration(color: Color(0xFF121317), shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(c, r * (0.66 + i * 0.037), groove);
    }
    // Light sheen so the rotation is visible even on dark covers.
    final sheen = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r * 0.98, sheen);
  }

  @override
  bool shouldRepaint(_GroovePainter oldDelegate) => false;
}
