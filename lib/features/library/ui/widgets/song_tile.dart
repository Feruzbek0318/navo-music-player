import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/equalizer_bars.dart';
import '../../../../shared/widgets/tap_scale.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../../player/state/player_providers.dart';
import '../../data/models.dart';
import '../../state/selection.dart';
import '../labels.dart';
import 'song_options_sheet.dart';
import '../../../../core/theme/navo_theme.dart';

/// A song row: artwork, title, "artist | duration", play button and menu.
class SongTile extends ConsumerWidget {
  const SongTile({
    super.key,
    required this.track,
    required this.queue,
    this.menuExtras = const [],
    this.trailing,
    this.heroPrefix,
  });

  final Track track;

  /// The list this tile belongs to; tapping plays it from this track.
  final List<Track> queue;

  /// Extra entries for the options sheet (e.g. "Remove from playlist").
  final List<SongMenuEntry> menuExtras;

  /// Replaces the menu button (e.g. a drag handle).
  final Widget? trailing;
  final String? heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrent = ref.watch(isCurrentTrackProvider(track.key));
    final isPlaying = ref.watch(isTrackPlayingProvider(track.key));
    final controller = ref.read(playerControllerProvider);
    final navo = context.navo;
    final selecting = ref.watch(selectionProvider.select((s) => s.active));
    final selected = ref.watch(isSelectedProvider(track.key));
    final selection = ref.read(selectionProvider.notifier);

    return TapScale(
      scale: 0.98,
      onTap: selecting ? () => selection.toggle(track) : () => controller.playOrToggle(track, queue),
      // Long-press starts multi-select (the ⋮ button opens the song menu).
      onLongPress: selecting ? () => selection.toggle(track) : () => selection.start(track, queue),
      child: Padding(
        padding: EdgeInsets.fromLTRB(Insets.page, navo.rowPadding, Insets.xs, navo.rowPadding),
        child: Row(
          children: [
            if (navo.showListArtwork) ...[
              SizedBox.square(
                dimension: navo.listArtSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TrackArtwork(
                      track: track,
                      size: navo.listArtSize,
                      radius: navo.listArtRadius,
                      circle: navo.listArtCircle,
                      heroTag: heroPrefix == null ? null : '$heroPrefix-${track.key}',
                    ),
                    AnimatedOpacity(
                      opacity: isCurrent ? 1 : 0,
                      duration: AppDurations.medium,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: navo.listArtCircle ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: navo.listArtCircle ? null : navo.radius(navo.listArtRadius),
                        ),
                        child: Center(
                          child: isCurrent ? EqualizerBars(animating: isPlaying, size: 18, color: Colors.white) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Insets.md),
            ] else if (isCurrent) ...[
              EqualizerBars(animating: isPlaying, size: 16),
              const SizedBox(width: Insets.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: AppDurations.fast,
                    style: context.text.bodyLarge!.copyWith(
                      color: isCurrent ? context.navo.accent : context.navo.textPrimary,
                    ),
                    child: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: Insets.xs),
                  Row(
                    children: [
                      if (track.isDemo) ...[const _DemoBadge(), const SizedBox(width: Insets.xs)],
                      Expanded(
                        child: Text(
                          context.trackSubtitle(track),
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Insets.sm),
            if (selecting)
              Padding(
                padding: const EdgeInsets.only(right: Insets.sm),
                child: Checkbox(value: selected, onChanged: (_) => selection.toggle(track)),
              )
            else ...[
              RoundPlayButton(
                playing: isPlaying,
                semanticLabel: isPlaying ? context.l10n.pause : context.l10n.play,
                onPressed: () => controller.playOrToggle(track, queue),
              ),
              trailing ??
                  IconButton(
                    tooltip: context.l10n.more,
                    icon: Icon(Icons.more_vert_rounded, color: context.navo.textPrimary),
                    onPressed: () => showSongOptions(context, track, extras: menuExtras),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: context.navo.accent.withValues(alpha: 0.15),
        borderRadius: context.navo.radius(Radii.xs),
      ),
      child: Text(
        context.l10n.demoTrack,
        style: context.text.labelSmall?.copyWith(color: context.navo.accent, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}
