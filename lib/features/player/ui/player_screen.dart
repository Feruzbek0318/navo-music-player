import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/tap_scale.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/data/models.dart';
import '../../library/ui/labels.dart';
import '../../settings/state/settings_providers.dart';
import '../state/palette_provider.dart';
import '../state/player_providers.dart';
import 'lyrics_view.dart';
import 'mini_player.dart';
import 'player_sheets.dart';
import 'widgets/play_pause_button.dart';
import 'widgets/player_artwork.dart';
import 'widgets/seek_bar.dart';
import '../../../core/theme/navo_theme.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  static const routeName = '/player';

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> with SingleTickerProviderStateMixin {
  bool _lyricsOpen = false;
  late final _drag = AnimationController(vsync: this, duration: AppDurations.medium);

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  // Drag down anywhere (outside scrollables) to dismiss.
  void _onDragUpdate(DragUpdateDetails d) {
    final h = MediaQuery.sizeOf(context).height;
    _drag.value = (_drag.value + d.primaryDelta! / h).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_drag.value > 0.22 || (d.primaryVelocity ?? 0) > 900) {
      Navigator.pop(context);
    } else {
      _drag.animateBack(0, curve: AppCurves.standard);
    }
  }

  void _setLyrics(bool open) => setState(() => _lyricsOpen = open);

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    if (track == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) Navigator.pop(context);
      });
      return const Scaffold();
    }

    final accent = ref.watch(paletteColorProvider(track)).value;

    return AnimatedBuilder(
      animation: _drag,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _drag.value * MediaQuery.sizeOf(context).height), child: child),
      child: GestureDetector(
        onVerticalDragUpdate: _lyricsOpen ? null : _onDragUpdate,
        onVerticalDragEnd: _lyricsOpen ? null : _onDragEnd,
        child: Scaffold(
          backgroundColor: context.navo.background,
          body: _AnimatedBackdrop(
            color: accent,
            track: track,
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(track: track),
                  Expanded(
                    child: _Body(track: track, lyricsOpen: _lyricsOpen, onLyrics: _setLyrics),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Player background: a gradient that cross-fades to the artwork colour
/// (optionally drifting slowly), the blurred artwork itself, or a plain
/// surface for the minimal style.
class _AnimatedBackdrop extends ConsumerStatefulWidget {
  const _AnimatedBackdrop({required this.color, required this.track, required this.child});

  final Color? color;
  final Track track;
  final Widget child;

  @override
  ConsumerState<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends ConsumerState<_AnimatedBackdrop> with SingleTickerProviderStateMixin {
  late final _drift = AnimationController(vsync: this, duration: const Duration(seconds: 12));

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navo = context.navo;
    final a = ref.watch(appearanceProvider);
    final animate = a.animatedBackground && !navo.animationsOff && a.playerStyle != PlayerStyle.minimal;
    if (animate && !_drift.isAnimating) {
      _drift.repeat(reverse: true);
    } else if (!animate && _drift.isAnimating) {
      _drift.stop();
    }

    if (a.playerStyle == PlayerStyle.minimal) {
      return ColoredBox(color: navo.background, child: widget.child);
    }

    final gradient = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.color ?? navo.surface),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, c, _) => AnimatedBuilder(
        animation: _drift,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_drift.value);
          final base = c ?? navo.surface;
          final top = a.playerStyle == PlayerStyle.blurred
              ? Colors.black.withValues(alpha: 0.25)
              : base.withValues(alpha: 0.55);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.6 + 1.2 * t, -1),
                end: Alignment(0.6 - 1.2 * t, 1),
                stops: const [0, 0.55, 1],
                colors: [
                  top,
                  navo.background.withValues(alpha: a.playerStyle == PlayerStyle.blurred ? 0.75 : 0.96),
                  navo.background,
                ],
              ),
            ),
          );
        },
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (a.playerStyle == PlayerStyle.blurred)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8 + 40 * a.blurStrength, sigmaY: 8 + 40 * a.blurStrength),
            child: TrackArtwork(track: widget.track, radius: 0),
          ),
        RepaintBoundary(child: gradient),
        widget.child,
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.back,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              l10n.nowPlaying,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(color: context.navo.textSecondary),
            ),
          ),
          IconButton(
            tooltip: l10n.more,
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => showPlayerMoreSheet(context, track),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.track, required this.lyricsOpen, required this.onLyrics});

  final Track track;
  final bool lyricsOpen;
  final ValueChanged<bool> onLyrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(isPlayingProvider);
    final style = ref.watch(appearanceProvider.select((a) => a.playerStyle));

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > constraints.maxHeight) {
          return _LandscapeBody(
            track: track,
            playing: playing,
            style: style,
            lyricsOpen: lyricsOpen,
            onLyrics: onLyrics,
            constraints: constraints,
          );
        }
        // Controls need ~300 px; the artwork takes what's left.
        final artSize = math.max(
          120.0,
          math.min(constraints.maxWidth - Insets.page * 2.5, constraints.maxHeight - 330),
        );
        // On tall screens, push the artwork down a little so the layout
        // doesn't leave a gap above the lyrics handle.
        final spare = constraints.maxHeight - artSize - 380;
        final topGap = (spare * 0.45).clamp(0.0, 96.0);
        return Column(
          children: [
            AnimatedSize(
              duration: AppDurations.slow,
              curve: AppCurves.emphasized,
              child: lyricsOpen
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      children: [
                        SizedBox(height: Insets.md + topGap),
                        PlayerArtwork(
                          track: track,
                          playing: playing,
                          style: style,
                          size: artSize,
                          heroTag: nowPlayingHeroTag,
                        ),
                        const SizedBox(height: Insets.xxl),
                        _TitleBlock(track: track),
                      ],
                    ),
            ),
            const SizedBox(height: Insets.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
              child: SeekBar(duration: track.duration),
            ),
            const SizedBox(height: Insets.md),
            const _MainControls(),
            const SizedBox(height: Insets.md),
            const _SecondaryControls(),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDurations.slow,
                switchInCurve: AppCurves.standard,
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a),
                    child: c,
                  ),
                ),
                child: lyricsOpen
                    ? _LyricsPanel(key: const ValueKey('lyrics'), track: track, onClose: () => onLyrics(false))
                    : _LyricsHandle(key: const ValueKey('handle'), onOpen: () => onLyrics(true)),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Side-by-side layout for landscape: artwork (or lyrics) on the left,
/// scrollable controls on the right, so nothing overflows on short screens.
class _LandscapeBody extends StatelessWidget {
  const _LandscapeBody({
    required this.track,
    required this.playing,
    required this.style,
    required this.lyricsOpen,
    required this.onLyrics,
    required this.constraints,
  });

  final Track track;
  final bool playing;
  final PlayerStyle style;
  final bool lyricsOpen;
  final ValueChanged<bool> onLyrics;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final artSize = math.max(96.0, math.min(constraints.maxHeight - Insets.xl, constraints.maxWidth * 0.4));
    return Row(
      children: [
        SizedBox(
          width: constraints.maxWidth * 0.45,
          child: AnimatedSwitcher(
            duration: AppDurations.slow,
            child: lyricsOpen
                ? Padding(
                    key: const ValueKey('lyrics'),
                    padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.sm, Insets.md),
                    child: LyricsView(track: track),
                  )
                : Center(
                    key: const ValueKey('art'),
                    child: PlayerArtwork(
                      track: track,
                      playing: playing,
                      style: style,
                      size: artSize,
                      heroTag: nowPlayingHeroTag,
                    ),
                  ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: Insets.md),
            child: Column(
              children: [
                _TitleBlock(track: track),
                const SizedBox(height: Insets.sm),
                SeekBar(duration: track.duration),
                const _MainControls(),
                const SizedBox(height: Insets.xs),
                const _SecondaryControls(),
                TextButton.icon(
                  onPressed: () => onLyrics(!lyricsOpen),
                  icon: Icon(lyricsOpen ? Icons.album_rounded : Icons.lyrics_outlined),
                  label: Text(context.l10n.lyrics),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: Column(
          key: ValueKey(track.key),
          children: [
            Text(
              track.title,
              style: context.text.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Insets.xs),
            Text(
              context.artistOf(track),
              style: context.text.bodyMedium?.copyWith(color: context.navo.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MainControls extends ConsumerWidget {
  const _MainControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playing = ref.watch(isPlayingProvider);
    final c = ref.read(playerControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlIcon(icon: Icons.skip_previous_rounded, size: 34, tooltip: l10n.previous, onTap: c.previous),
        _ControlIcon(icon: Icons.replay_10_rounded, tooltip: l10n.rewind10, onTap: c.rewind10),
        BigPlayButton(playing: playing, onPressed: c.togglePlay, semanticLabel: playing ? l10n.pause : l10n.play),
        _ControlIcon(icon: Icons.forward_10_rounded, tooltip: l10n.forward10, onTap: c.forward10),
        _ControlIcon(icon: Icons.skip_next_rounded, size: 34, tooltip: l10n.next, onTap: c.next),
      ],
    );
  }
}

class _SecondaryControls extends ConsumerWidget {
  const _SecondaryControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = ref.read(playerControllerProvider);
    final shuffle = ref.watch(shuffleEnabledProvider);
    final repeat = ref.watch(repeatModeProvider);
    final speed = ref.watch(speedProvider).value ?? 1.0;
    final sleep = ref.watch(sleepTimerProvider);
    final remaining = ref.watch(sleepRemainingProvider).value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlIcon(
          icon: Icons.shuffle_rounded,
          size: 22,
          active: shuffle,
          tooltip: shuffle ? l10n.shuffleOn : l10n.shuffleOff,
          onTap: c.toggleShuffle,
        ),
        _ControlIcon(
          icon: Icons.speed_rounded,
          size: 22,
          active: speed != 1.0,
          badge: speed != 1.0 ? '${speed.toStringAsFixed(speed * 100 % 10 == 0 ? 1 : 2)}×' : null,
          tooltip: l10n.playbackSpeed,
          onTap: () => showSpeedSheet(context),
        ),
        _ControlIcon(
          icon: Icons.timer_outlined,
          size: 22,
          active: sleep.isActive,
          badge: remaining == null ? null : formatDuration(remaining),
          tooltip: l10n.sleepTimer,
          onTap: () => showSleepTimerSheet(context),
        ),
        _ControlIcon(icon: Icons.cast_rounded, size: 22, tooltip: l10n.audioOutput, onTap: () => openOutputPicker(ref)),
        _ControlIcon(
          icon: Icons.queue_music_rounded,
          size: 22,
          tooltip: l10n.playingQueue,
          onTap: () => showQueueSheet(context),
        ),
        _ControlIcon(
          icon: repeat == AudioServiceRepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
          size: 22,
          active: repeat != AudioServiceRepeatMode.none,
          tooltip: switch (repeat) {
            AudioServiceRepeatMode.none => l10n.repeatOff,
            AudioServiceRepeatMode.one => l10n.repeatOne,
            _ => l10n.repeatAll,
          },
          onTap: c.cycleRepeat,
        ),
      ],
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 28,
    this.active = false,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;
  final bool active;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final color = active ? context.navo.accent : context.navo.textPrimary;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: TapScale(
          scale: 0.85,
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: Icon(icon, key: ValueKey(icon), size: size, color: color),
                ),
                if (badge != null)
                  Text(
                    badge!,
                    style: context.text.labelSmall?.copyWith(color: context.navo.accent, fontSize: 9),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LyricsHandle extends StatelessWidget {
  const _LyricsHandle({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -200) onOpen();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.xxxl, Insets.sm, Insets.xxxl, Insets.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_up_rounded, color: context.navo.textSecondary),
              Text(context.l10n.lyrics, style: context.text.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricsPanel extends ConsumerWidget {
  const _LyricsPanel({super.key, required this.track, required this.onClose});

  final Track track;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final opts = ref.watch(lyricsSettingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    void size(double d) => notifier.lyrics((x) => x.copyWith(fontSize: (x.fontSize + d).clamp(12.0, 32.0)));
    void shift(int ms) => notifier.lyrics((x) => x.copyWith(offsetMs: (x.offsetMs + ms).clamp(-10000, 10000)));
    final offset = opts.offsetMs / 1000;

    Widget small(IconData icon, String tip, VoidCallback onTap) =>
        IconButton(tooltip: tip, visualDensity: VisualDensity.compact, icon: Icon(icon, size: 20), onPressed: onTap);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0) > 200) onClose();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Insets.md),
                    child: Row(
                      children: [
                        Flexible(child: Text(l10n.lyrics, style: context.text.titleMedium, maxLines: 1)),
                        Icon(Icons.keyboard_arrow_down_rounded, color: context.navo.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              small(Icons.text_decrease_rounded, l10n.lyricsSmaller, () => size(-2)),
              small(Icons.text_increase_rounded, l10n.lyricsLarger, () => size(2)),
              small(Icons.fast_rewind_rounded, l10n.lyricsEarlier, () => shift(-500)),
              Text(
                l10n.offsetSeconds('${offset > 0 ? '+' : ''}${offset.toStringAsFixed(1)}'),
                style: context.text.labelSmall?.copyWith(color: opts.offsetMs == 0 ? null : context.navo.accent),
              ),
              small(Icons.fast_forward_rounded, l10n.lyricsLater, () => shift(500)),
            ],
          ),
          Expanded(child: LyricsView(track: track)),
        ],
      ),
    );
  }
}
