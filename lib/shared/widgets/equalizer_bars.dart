import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/navo_theme.dart';

/// Animated "now playing" bars. Settles to low bars when [animating] is false.
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key, required this.animating, this.size = 16, this.color, this.bars = 4});

  final bool animating;
  final double size;

  /// Defaults to the theme accent.
  final Color? color;
  final int bars;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _amp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: widget.animating ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animating) _c.repeat();
  }

  @override
  void didUpdateWidget(EqualizerBars old) {
    super.didUpdateWidget(old);
    if (widget.animating == old.animating) return;
    if (widget.animating) {
      _c.repeat();
      _amp.forward();
    } else {
      _amp.reverse().whenComplete(() {
        if (!widget.animating) _c.stop();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _amp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_c, _amp]),
          builder: (_, _) => CustomPaint(
            painter: _BarsPainter(
              t: _c.value,
              amp: Curves.easeOut.transform(_amp.value),
              color: widget.color ?? context.navo.accent,
              bars: widget.bars,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.t, required this.amp, required this.color, required this.bars});

  final double t;
  final double amp;
  final Color color;
  final int bars;

  static const _speeds = [1.0, 2.0, 1.0, 3.0, 2.0];
  static const _phases = [0.0, 1.7, 3.1, 0.9, 2.4];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final gap = size.width * 0.12;
    final w = (size.width - gap * (bars - 1)) / bars;
    for (var i = 0; i < bars; i++) {
      final wave = 0.5 + 0.5 * math.sin(2 * math.pi * t * _speeds[i % 5] + _phases[i % 5]);
      final level = 0.2 + amp * 0.8 * wave;
      final h = size.height * level;
      final x = i * (w + gap);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - h, w, h), Radius.circular(w / 2)), paint);
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.t != t || old.amp != amp || old.color != color;
}
