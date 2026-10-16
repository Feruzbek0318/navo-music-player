import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/navo_theme.dart';

/// Original vector illustrations for the onboarding pages: an orange sun
/// disc, floating dots and a motif (headphones, sound wave, vinyl).
///
/// [parallax] is the page offset (-1..1) used to shift layers at different
/// speeds while swiping.
class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({super.key, required this.page, this.parallax = 0});

  final int page;
  final double parallax;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: _IllustrationPainter(
            page: widget.page,
            t: _c.value,
            parallax: widget.parallax,
            tokens: context.navo,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter({required this.page, required this.t, required this.parallax, required this.tokens});

  final NavoTheme tokens;

  final int page;
  final double t;
  final double parallax;

  static const _dots = [
    (0.12, 0.14, 9.0),
    (0.86, 0.10, 6.0),
    (0.08, 0.52, 6.0),
    (0.92, 0.46, 10.0),
    (0.78, 0.78, 5.0),
    (0.20, 0.82, 7.0),
    (0.50, 0.06, 4.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wave = 2 * math.pi * t;

    // Floating dots (move faster than the disc for depth).
    final dotPaint = Paint()..color = tokens.accent;
    for (var i = 0; i < _dots.length; i++) {
      final (x, y, r) = _dots[i];
      final dy = math.sin(wave + i) * 6;
      canvas.drawCircle(Offset(x * w - parallax * 60, y * h + dy), r, dotPaint);
    }

    // Sun disc with a soft glow.
    final center = Offset(w / 2 - parallax * 24, h * 0.52);
    final radius = math.min(w, h) * 0.34;
    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..color = tokens.accent.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(tokens.accent, Colors.white, 0.25)!, tokens.accentDark],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final motifCenter = center.translate(-parallax * 30, 0);
    switch (page) {
      case 0:
        _headphones(canvas, motifCenter, radius, wave);
      case 1:
        _soundWave(canvas, motifCenter, radius, wave);
      default:
        _vinyl(canvas, motifCenter, radius, t);
    }
  }

  void _headphones(Canvas canvas, Offset c, double r, double wave) {
    final band = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.11
      ..strokeCap = StrokeCap.round;
    final arcRect = Rect.fromCircle(center: c.translate(0, r * 0.08), radius: r * 0.62);
    canvas.drawArc(arcRect, math.pi * 1.05, math.pi * 0.9, false, band);

    final cup = Paint()..color = Colors.white;
    final inner = Paint()..color = tokens.background;
    for (final side in [-1, 1]) {
      final cupRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(side * r * 0.6, r * 0.24), width: r * 0.3, height: r * 0.52),
        Radius.circular(r * 0.15),
      );
      canvas.drawRRect(cupRect, cup);
      canvas.drawRRect(cupRect.deflate(r * 0.06), inner);
    }

    // Equalizer between the cups.
    final bar = Paint()..color = tokens.background;
    for (var i = 0; i < 5; i++) {
      final hgt = r * (0.16 + 0.22 * (0.5 + 0.5 * math.sin(wave * 2 + i * 1.3)));
      final x = c.dx + (i - 2) * r * 0.14;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, c.dy + r * 0.26), width: r * 0.08, height: hgt),
          Radius.circular(r * 0.04),
        ),
        bar,
      );
    }
  }

  void _soundWave(Canvas canvas, Offset c, double r, double wave) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;
    for (var ring = 0; ring < 3; ring++) {
      final phase = (t * 1.5 + ring / 3) % 1;
      paint.color = Colors.white.withValues(alpha: (1 - phase) * 0.9);
      canvas.drawCircle(c, r * (0.25 + phase * 0.7), paint);
    }
    // Speaker cone.
    final cone = Paint()..color = Colors.white;
    canvas.drawCircle(c, r * 0.22, cone);
    canvas.drawCircle(c, r * 0.1, Paint()..color = tokens.accentDark);

    final barPaint = Paint()..color = tokens.background.withValues(alpha: 0.85);
    for (var i = 0; i < 9; i++) {
      final hgt = r * (0.08 + 0.16 * (0.5 + 0.5 * math.sin(wave * 3 + i * 0.9)));
      final x = c.dx + (i - 4) * r * 0.13;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, c.dy + r * 0.72), width: r * 0.07, height: hgt),
          Radius.circular(r * 0.035),
        ),
        barPaint,
      );
    }
  }

  void _vinyl(Canvas canvas, Offset c, double r, double t) {
    final disc = r * 0.7;
    canvas.drawCircle(c, disc, Paint()..color = const Color(0xFF15161B));
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 1; i < 7; i++) {
      canvas.drawCircle(c, disc * (0.4 + i * 0.085), groove);
    }
    // Rotating highlight.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(2 * math.pi * t);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: disc * 0.82),
      0,
      0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = disc * 0.22
        ..color = Colors.white.withValues(alpha: 0.06),
    );
    canvas.restore();
    canvas.drawCircle(c, disc * 0.32, Paint()..color = tokens.accent);
    canvas.drawCircle(c, disc * 0.06, Paint()..color = const Color(0xFF15161B));

    // Tone arm.
    final arm = Paint()
      ..color = Colors.white
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;
    final pivot = c.translate(disc * 0.95, -disc * 0.95);
    canvas.drawCircle(pivot, r * 0.07, Paint()..color = Colors.white);
    canvas.drawLine(pivot, c.translate(disc * 0.35, -disc * 0.1), arm);
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) =>
      old.t != t || old.parallax != parallax || old.page != page || old.tokens != tokens;
}
