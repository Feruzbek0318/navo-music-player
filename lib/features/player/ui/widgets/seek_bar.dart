import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/state/settings_providers.dart';
import '../../data/navo_audio_handler.dart';
import '../../state/player_providers.dart';
import '../../../../core/theme/navo_theme.dart';

/// Orange seek bar with elapsed / total times. The thumb grows while dragging.
class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key, required this.duration});

  final Duration duration;

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final total = widget.duration.inMilliseconds <= 0 ? 1 : widget.duration.inMilliseconds;
    final value = _dragValue ?? (position.inMilliseconds / total).clamp(0.0, 1.0);
    final shown = _dragValue != null ? Duration(milliseconds: (_dragValue! * total).round()) : position;
    final dragging = _dragValue != null;
    final showRemaining = ref.watch(appearanceProvider.select((a) => a.showRemainingTime));
    final ab = ref.watch(abRepeatProvider).value ?? AbRepeat.off;
    final navo = context.navo;
    double frac(Duration d) => (d.inMilliseconds / total).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: dragging ? 1 : 0),
          duration: AppDurations.fast,
          builder: (context, t, _) => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4 + 2 * t,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7 + 3 * t),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14 + 6 * t),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // A–B markers.
                if (ab.a != null)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, c) => Stack(
                          children: [
                            if (ab.active)
                              Positioned(
                                left: c.maxWidth * frac(ab.a!),
                                width: c.maxWidth * (frac(ab.b!) - frac(ab.a!)),
                                top: c.maxHeight / 2 - 5,
                                height: 10,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: navo.accent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            for (final (d, label) in [(ab.a, 'A'), (ab.b, 'B')])
                              if (d != null)
                                Positioned(
                                  left: c.maxWidth * frac(d) - 6,
                                  top: 0,
                                  child: Text(label, style: context.text.labelSmall?.copyWith(color: navo.accent)),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Slider(
                  value: value,
                  semanticFormatterCallback: (v) => formatDuration(Duration(milliseconds: (v * total).round())),
                  onChangeStart: (v) => setState(() => _dragValue = v),
                  onChanged: (v) => setState(() => _dragValue = v),
                  onChangeEnd: (v) {
                    ref.read(playerControllerProvider).seek(Duration(milliseconds: (v * total).round()));
                    setState(() => _dragValue = null);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg + 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(shown), style: context.text.labelSmall?.copyWith(color: context.navo.textPrimary)),
              Text(
                showRemaining
                    ? '−${formatDuration(widget.duration - shown < Duration.zero ? Duration.zero : widget.duration - shown)}'
                    : formatDuration(widget.duration),
                style: context.text.labelSmall?.copyWith(color: context.navo.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 2 px progress line used by the mini player.
class ThinProgress extends ConsumerWidget {
  const ThinProgress({super.key, required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final total = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
    final v = (position.inMilliseconds / total).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: v),
      duration: const Duration(milliseconds: 250),
      builder: (_, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 2,
        backgroundColor: context.navo.surfaceHigh,
        valueColor: AlwaysStoppedAnimation(context.navo.accent),
      ),
    );
  }
}
