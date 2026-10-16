import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import 'tap_scale.dart';
import '../../core/theme/navo_theme.dart';

/// Orange pill button with a soft glow, as on the onboarding screens.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.expand = true});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(color: context.navo.onAccent);
    return TapScale(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        height: 48,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
        decoration: BoxDecoration(
          color: context.navo.accent,
          borderRadius: context.navo.radius(Radii.pill),
          boxShadow: context.navo.accentGlow(),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: context.navo.onAccent), const SizedBox(width: Insets.sm)],
            Flexible(
              child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// Muted pill button (e.g. "Play" next to "Shuffle" on detail pages).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(color: context.navo.accent);
    return TapScale(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        decoration: BoxDecoration(
          color: context.navo.accent.withValues(alpha: 0.12),
          borderRadius: context.navo.radius(Radii.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: context.navo.accent), const SizedBox(width: Insets.sm)],
            Flexible(
              child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small filled orange circle with a play glyph (list tiles).
class RoundPlayButton extends StatelessWidget {
  const RoundPlayButton({
    super.key,
    required this.onPressed,
    this.size = Sizes.smallPlayButton,
    this.playing = false,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final double size;
  final bool playing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: TapScale(
        onTap: onPressed,
        scale: 0.85,
        child: SizedBox(
          width: size + 16,
          height: size + 16,
          child: Center(
            child: AnimatedSwitcher(
              duration: AppDurations.fast,
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: playing
                  ? Icon(Icons.pause_rounded, key: const ValueKey('pause'), color: context.navo.accent, size: size + 4)
                  : Container(
                      key: const ValueKey('play'),
                      width: size,
                      height: size,
                      decoration: BoxDecoration(color: context.navo.accent, shape: BoxShape.circle),
                      child: Icon(Icons.play_arrow_rounded, color: context.navo.onAccent, size: size * 0.72),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
