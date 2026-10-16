import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/tap_scale.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/ui/labels.dart';
import '../../library/ui/widgets/selection_bar.dart';
import '../../settings/state/settings_providers.dart';
import '../state/player_providers.dart';
import 'player_screen.dart';
import 'widgets/play_pause_button.dart';
import 'widgets/seek_bar.dart';
import '../../../core/theme/navo_theme.dart';

const nowPlayingHeroTag = 'now-playing-artwork';

void openPlayer(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push(
    SlideUpRoute<void>(
      settings: const RouteSettings(name: PlayerScreen.routeName),
      builder: (_) => const PlayerScreen(),
    ),
  );
}

/// Compact player shown above the bottom navigation (and on detail pages).
/// Tap or swipe up to expand into the full player.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.standalone = false});

  /// When used as a page's `bottomNavigationBar`, pads for the system inset.
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);
    final playing = ref.watch(isPlayingProvider);
    final controller = ref.read(playerControllerProvider);
    final l10n = context.l10n;
    final navo = context.navo;
    final docked = ref.watch(appearanceProvider.select((a) => a.miniPlayerStyle)) == MiniPlayerStyle.docked;
    final swipe = ref.watch(gestureSettingsProvider.select((g) => g.miniPlayerSwipe));
    final haptics = ref.watch(gestureSettingsProvider.select((g) => g.haptics));

    final Widget content = track == null
        ? const SizedBox(width: double.infinity)
        : GestureDetector(
            key: const ValueKey('mini'),
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < -250) openPlayer(context);
            },
            // Swipe left/right for next/previous.
            onHorizontalDragEnd: !swipe
                ? null
                : (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v.abs() < 300) return;
                    if (haptics) HapticFeedback.selectionClick();
                    v < 0 ? controller.next() : controller.previous();
                  },
            child: TapScale(
              scale: 0.98,
              onTap: () => openPlayer(context),
              child: Container(
                margin: docked
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(Insets.sm, Insets.xs, Insets.sm, Insets.xs),
                decoration: BoxDecoration(
                  color: navo.surface,
                  borderRadius: docked ? null : navo.cardRadius,
                  border: docked ? Border(top: BorderSide(color: navo.divider)) : null,
                  boxShadow: docked || !navo.isDark
                      ? null
                      : const [BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 4))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: Sizes.miniPlayerHeight - 2,
                      child: Row(
                        children: [
                          const SizedBox(width: Insets.sm),
                          TrackArtwork(track: track, size: 44, radius: Radii.xs, heroTag: nowPlayingHeroTag),
                          const SizedBox(width: Insets.md),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: AppDurations.medium,
                              layoutBuilder: (current, previous) =>
                                  Stack(alignment: AlignmentDirectional.centerStart, children: [...previous, ?current]),
                              transitionBuilder: (c, a) => FadeTransition(
                                opacity: a,
                                child: SlideTransition(
                                  position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a),
                                  child: c,
                                ),
                              ),
                              child: Text(
                                '${track.title} - ${context.artistOf(track)}',
                                key: ValueKey(track.key),
                                style: context.text.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: playing ? l10n.pause : l10n.play,
                            onPressed: controller.togglePlay,
                            icon: MorphingPlayPause(playing: playing, color: context.navo.accent),
                          ),
                          IconButton(
                            tooltip: l10n.next,
                            onPressed: controller.next,
                            icon: Icon(Icons.skip_next_rounded, color: context.navo.accent, size: 28),
                          ),
                          const SizedBox(width: Insets.xs),
                        ],
                      ),
                    ),
                    ThinProgress(duration: track.duration),
                  ],
                ),
              ),
            ),
          );

    final animated = AnimatedSize(
      duration: AppDurations.medium,
      curve: AppCurves.standard,
      alignment: Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a),
            child: c,
          ),
        ),
        child: content,
      ),
    );

    if (!standalone) return animated;
    // On pushed pages the mini player also hosts the multi-select bar.
    return Material(
      color: context.navo.background,
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [const SelectionBar(), animated]),
      ),
    );
  }
}
