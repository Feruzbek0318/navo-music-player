import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../shared/widgets/app_logo.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/state/settings_providers.dart';
import '../shell/app_shell.dart';
import '../../core/theme/navo_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final seen = ref.read(onboardingSeenProvider);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: AppDurations.slow,
        pageBuilder: (_, _, _) => seen ? const AppShell() : const OnboardingScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AppLogo(size: 40, nameStyle: context.text.headlineMedium)
                .animate()
                .fadeIn(duration: AppDurations.slow)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: AppDurations.slow),
          ),
          const Positioned(left: 0, right: 0, bottom: 96, child: Center(child: DotsLoader())),
        ],
      ),
    );
  }
}

/// Ring of orange dots with a travelling highlight.
class DotsLoader extends StatefulWidget {
  const DotsLoader({super.key, this.size = 36});

  final double size;

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(painter: _DotsPainter(_c.value, context.navo.accent)),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.t, this.color);

  final Color color;

  final double t;
  static const _count = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    for (var i = 0; i < _count; i++) {
      final angle = 2 * math.pi * i / _count - math.pi / 2;
      final phase = ((t * _count - i) % _count) / _count; // 0 = head of the tail
      final k = 1 - phase;
      final paint = Paint()..color = color.withValues(alpha: 0.25 + 0.75 * k * k);
      canvas.drawCircle(c + Offset(math.cos(angle), math.sin(angle)) * r, 2 + 2.2 * k, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.t != t || old.color != color;
}
