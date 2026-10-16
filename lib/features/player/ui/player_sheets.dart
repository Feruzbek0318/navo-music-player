import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/router/app_keys.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/equalizer_bars.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/data/models.dart';
import '../../library/state/library_providers.dart';
import '../../library/state/song_actions.dart';
import '../../library/ui/collection_detail_screen.dart';
import '../../library/ui/labels.dart';
import '../../library/ui/widgets/song_details_dialog.dart';
import '../../library/ui/widgets/song_options_sheet.dart';
import '../../playlists/state/playlist_providers.dart';
import '../../playlists/ui/add_to_playlist_sheet.dart';
import '../../playlists/ui/playlist_name_dialog.dart';
import '../../settings/state/settings_providers.dart';
import '../data/navo_audio_handler.dart';
import 'equalizer_screen.dart';
import '../state/player_providers.dart';
import 'player_screen.dart';
import '../../../core/theme/navo_theme.dart';

// ---------------------------------------------------------------------------
// Queue
// ---------------------------------------------------------------------------

Future<void> showQueueSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: false,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    builder: (context, scroll) => _QueueSheet(scrollController: scroll),
  ),
);

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(queueViewProvider).value;
    final controller = ref.read(playerControllerProvider);
    final playing = ref.watch(isPlayingProvider);
    final tracks = view?.tracks ?? const <Track>[];

    return Column(
      children: [
        const SizedBox(height: Insets.md),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: context.navo.textTertiary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: Insets.lg),
        SheetTitle(
          l10n.playingQueue,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.songsCount(tracks.length), style: context.text.bodySmall),
              PopupMenuButton<void>(
                tooltip: l10n.more,
                enabled: tracks.isNotEmpty,
                itemBuilder: (_) => [
                  PopupMenuItem<void>(
                    onTap: () async {
                      final name = await showPlaylistNameDialog(context, rename: false);
                      if (name == null) return;
                      await ref
                          .read(playlistsProvider.notifier)
                          .create(name, trackKeys: [for (final t in controller.queueTracks) t.key]);
                      showAppSnack(l10n.addedToPlaylist(name));
                    },
                    child: Text(l10n.saveQueueAsPlaylist),
                  ),
                  PopupMenuItem<void>(
                    onTap: () async {
                      await controller.clearUpcoming();
                      showAppSnack(l10n.queueCleared);
                    },
                    child: Text(l10n.clearQueue),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: tracks.isEmpty
              ? Center(child: Text(l10n.queueEmpty, style: context.text.bodyMedium))
              : ReorderableListView.builder(
                  scrollController: scrollController,
                  buildDefaultDragHandles: false,
                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.lg),
                  itemCount: tracks.length,
                  onReorderItem: controller.moveInQueue,
                  proxyDecorator: (child, _, _) => Material(
                    color: context.navo.surfaceHigh,
                    elevation: 6,
                    borderRadius: context.navo.cardRadius,
                    child: child,
                  ),
                  itemBuilder: (_, i) => Builder(
                    // Reorderable lists need the key on the outermost item widget.
                    key: ValueKey('q-${view!.sourceIndices[i]}-${tracks[i].key}'),
                    builder: (context) {
                      final t = tracks[i];
                      final isCurrent = i == view.currentPosition;
                      return Dismissible(
                        key: ValueKey('q-${view.sourceIndices[i]}-${t.key}'),
                        direction: isCurrent ? DismissDirection.none : DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
                          color: context.navo.danger.withValues(alpha: 0.2),
                          child: Icon(Icons.delete_outline_rounded, color: context.navo.danger),
                        ),
                        onDismissed: (_) {
                          final source = view.sourceIndices[i];
                          controller.removeFromQueue(source);
                          showAppSnack(
                            l10n.queueRemoved(t.title),
                            actionLabel: l10n.undo,
                            onAction: () => controller.undoRemove(source, t),
                          );
                        },
                        child: ListTile(
                          onTap: () => controller.playFromQueue(i),
                          leading: SizedBox.square(
                            dimension: 44,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                TrackArtwork(track: t, size: 44, radius: Radii.xs),
                                if (isCurrent)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: context.navo.radius(Radii.xs),
                                    ),
                                    child: Center(child: EqualizerBars(animating: playing, size: 16)),
                                  ),
                              ],
                            ),
                          ),
                          title: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyLarge?.copyWith(color: isCurrent ? context.navo.accent : null),
                          ),
                          subtitle: Text(context.trackSubtitle(t), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: Padding(
                              padding: EdgeInsets.all(Insets.sm),
                              child: Icon(Icons.drag_handle_rounded, color: context.navo.textSecondary),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sleep timer
// ---------------------------------------------------------------------------

Future<void> showSleepTimerSheet(BuildContext context) => showAppSheet<void>(context, (_) => const _SleepTimerSheet());

class _SleepTimerSheet extends ConsumerWidget {
  const _SleepTimerSheet();

  static const _minutes = [5, 10, 15, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(sleepTimerProvider);
    final remaining = ref.watch(sleepRemainingProvider).value;
    final notifier = ref.read(sleepTimerProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(
            l10n.sleepTimer,
            trailing: remaining == null
                ? null
                : Text(
                    l10n.sleepTimerRemaining(formatDuration(remaining)),
                    style: context.text.labelMedium?.copyWith(color: context.navo.accent),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final m in _minutes)
                  ChoiceChip(
                    label: Text(l10n.minutesCount(m)),
                    selected: false,
                    onSelected: (_) {
                      notifier.start(Duration(minutes: m));
                      Navigator.pop(context);
                      showAppSnack(l10n.sleepTimerSet(l10n.minutesCount(m)));
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),
          SheetAction(
            icon: Icons.music_note_outlined,
            label: l10n.sleepTimerEndOfTrack,
            color: state.endOfTrack ? context.navo.accent : null,
            onTap: () {
              notifier.endOfTrack();
              Navigator.pop(context);
              showAppSnack(l10n.sleepTimerEndSet);
            },
          ),
          if (state.isActive)
            SheetAction(
              icon: Icons.timer_off_outlined,
              label: l10n.sleepTimerOff,
              color: context.navo.danger,
              onTap: () {
                notifier.cancel();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speed
// ---------------------------------------------------------------------------

Future<void> showSpeedSheet(BuildContext context) => showAppSheet<void>(context, (_) => const _SpeedSheet());

class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet();

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final speed = ref.watch(playbackSettingsProvider.select((p) => p.speed));
    final pitch = ref.watch(playbackSettingsProvider.select((p) => p.pitch));
    final controller = ref.read(playerControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetTitle(
            l10n.playbackSpeed,
            trailing: Text(
              '${speed.toStringAsFixed(2)}×',
              style: context.text.titleSmall?.copyWith(color: context.navo.accent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Slider(
              value: speed.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              divisions: 30,
              onChanged: controller.setSpeed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              alignment: WrapAlignment.center,
              children: [
                for (final s in _speeds)
                  ChoiceChip(
                    label: Text('$s×'),
                    selected: (speed - s).abs() < 0.01,
                    onSelected: (_) => controller.setSpeed(s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Insets.lg),
          SheetTitle(
            l10n.pitch,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pitch.toStringAsFixed(2)}×',
                  style: context.text.titleSmall?.copyWith(color: context.navo.accent),
                ),
                if (pitch != 1) TextButton(onPressed: () => controller.setPitch(1), child: Text(l10n.resetValue)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Slider(
              value: pitch.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              divisions: 30,
              label: '${pitch.toStringAsFixed(2)}×',
              semanticFormatterCallback: (v) => '${l10n.pitch} ${v.toStringAsFixed(2)}',
              onChanged: controller.setPitch,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Output device
// ---------------------------------------------------------------------------

Future<void> openOutputPicker(WidgetRef ref) async {
  final ok = await ref.read(deviceBridgeProvider).showOutputSwitcher();
  if (!ok) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) showAppSnack(ctx.l10n.audioOutputUnavailable);
  }
}

// ---------------------------------------------------------------------------
// More (volume, favourite, playlist, album, artist, details, share)
// ---------------------------------------------------------------------------

Future<void> showPlayerMoreSheet(BuildContext context, Track track) =>
    showAppSheet<void>(context, (_) => _PlayerMoreSheet(track: track));

class _PlayerMoreSheet extends ConsumerStatefulWidget {
  const _PlayerMoreSheet({required this.track});

  final Track track;

  @override
  ConsumerState<_PlayerMoreSheet> createState() => _PlayerMoreSheetState();
}

class _PlayerMoreSheetState extends ConsumerState<_PlayerMoreSheet> {
  double? _volume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final track = widget.track;
    final volume = _volume ?? ref.watch(volumeProvider).value ?? 1.0;
    final controller = ref.read(playerControllerProvider);
    final actions = ref.read(songActionsProvider);
    final isFav = ref.watch(isFavoriteProvider(track.key));
    final nav = rootNavigatorKey.currentState!;
    void close() => Navigator.pop(context);

    void open(CollectionKind kind) {
      close();
      // Leave the player first so the page isn't hidden behind it.
      nav.popUntil((r) => r.settings.name != PlayerScreen.routeName);
      nav.push(
        FadeThroughRoute<void>(
          builder: (_) => CollectionDetailScreen(
            kind: kind,
            id: kind == CollectionKind.album ? track.albumKey : artistIdFor(ref, track),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.sm, Insets.sm),
            child: Row(
              children: [
                TrackArtwork(track: track, size: 52),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        context.trackSubtitle(track),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                FavoriteButton(track: track, isFavorite: isFav),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.md),
            child: Row(
              children: [
                Semantics(
                  label: l10n.volume,
                  child: Padding(
                    padding: EdgeInsets.all(Insets.sm),
                    child: Icon(Icons.volume_down_rounded, color: context.navo.textSecondary),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: volume,
                    semanticFormatterCallback: (v) => '${l10n.volume} ${(v * 100).round()}%',
                    onChanged: (v) {
                      setState(() => _volume = v);
                      controller.setVolume(v);
                    },
                    onChangeEnd: (v) {
                      controller.persistVolume(v);
                      setState(() => _volume = null);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Insets.sm),
                  child: Icon(Icons.volume_up_rounded, color: context.navo.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(indent: Insets.page, endIndent: Insets.page),
          SheetAction(
            icon: Icons.repeat_on_rounded,
            label: switch (ref.watch(abRepeatProvider).value ?? AbRepeat.off) {
              AbRepeat(a: null) => l10n.abSetA,
              AbRepeat(b: null) => l10n.abSetB,
              _ => l10n.abClear,
            },
            onTap: () {
              controller.toggleAb();
              if ((ref.read(abRepeatProvider).value ?? AbRepeat.off).active) close();
            },
          ),
          SheetAction(
            icon: Icons.equalizer_rounded,
            label: l10n.equalizer,
            onTap: () {
              close();
              nav.push(FadeThroughRoute<void>(builder: (_) => const EqualizerScreen()));
            },
          ),
          SheetAction(
            icon: Icons.playlist_add_rounded,
            label: l10n.addToPlaylist,
            onTap: () {
              close();
              showAddToPlaylist(nav.context, [track]);
            },
          ),
          SheetAction(icon: Icons.album_outlined, label: l10n.goToAlbum, onTap: () => open(CollectionKind.album)),
          SheetAction(
            icon: Icons.person_outline_rounded,
            label: l10n.goToArtist,
            onTap: () => open(CollectionKind.artist),
          ),
          SheetAction(
            icon: Icons.info_outline_rounded,
            label: l10n.details,
            onTap: () {
              close();
              showSongDetails(nav.context, track);
            },
          ),
          SheetAction(
            icon: Icons.share_outlined,
            label: l10n.share,
            onTap: () {
              close();
              actions.share(track);
            },
          ),
        ],
      ),
    );
  }
}
