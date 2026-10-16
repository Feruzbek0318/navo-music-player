import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/tap_scale.dart';
import '../../../../core/theme/navo_theme.dart';

/// Play/pause glyph that morphs between states (AnimatedIcon).
class MorphingPlayPause extends StatefulWidget {
  const MorphingPlayPause({super.key, required this.playing, this.size = 28, this.color});

  final bool playing;
  final double size;

  /// Defaults to the theme's on-accent colour.
  final Color? color;

  @override
  State<MorphingPlayPause> createState() => _MorphingPlayPauseState();
}

class _MorphingPlayPauseState extends State<MorphingPlayPause> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: AppDurations.medium, value: widget.playing ? 1 : 0);

  @override
  void didUpdateWidget(MorphingPlayPause old) {
    super.didUpdateWidget(old);
    if (widget.playing != old.playing) {
      widget.playing ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: CurvedAnimation(parent: _c, curve: AppCurves.emphasized),
      size: widget.size,
      color: widget.color ?? context.navo.onAccent,
    );
  }
}

/// The large orange play button with a glow.
class BigPlayButton extends StatelessWidget {
  const BigPlayButton({super.key, required this.playing, required this.onPressed, required this.semanticLabel});

  final bool playing;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: TapScale(
        scale: 0.9,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          width: Sizes.playButton,
          height: Sizes.playButton,
          decoration: BoxDecoration(
            color: context.navo.accent,
            shape: BoxShape.circle,
            boxShadow: context.navo.accentGlow(strength: playing ? 1.2 : 0.7),
          ),
          child: Center(child: MorphingPlayPause(playing: playing, size: 34)),
        ),
      ),
    );
  }
}
