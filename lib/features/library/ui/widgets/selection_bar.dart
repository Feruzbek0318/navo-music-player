import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_keys.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/navo_theme.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../player/state/player_providers.dart';
import '../../../playlists/ui/add_to_playlist_sheet.dart';
import '../../data/models.dart';
import '../../state/selection.dart';
import '../../state/song_actions.dart';

/// Batch actions for the multi-selection. Shown wherever song lists are;
/// back clears the selection.
class SelectionBar extends ConsumerWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectionProvider);
    final l10n = context.l10n;
    final navo = context.navo;
    final notifier = ref.read(selectionProvider.notifier);
    final player = ref.read(playerControllerProvider);
    final actions = ref.read(songActionsProvider);

    Widget action(IconData icon, String label, Future<void> Function(List<Track> t) run, {Color? color}) => Tooltip(
      message: label,
      child: InkResponse(
        onTap: () async {
          final tracks = sel.tracks;
          notifier.clear();
          await run(tracks);
        },
        radius: 28,
        child: SizedBox(
          width: 56,
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? navo.textPrimary, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedSize(
      duration: AppDurations.medium,
      curve: AppCurves.standard,
      child: !sel.active
          ? const SizedBox(width: double.infinity)
          : PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) notifier.clear();
              },
              child: Material(
                color: navo.surface,
                elevation: 8,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.cancelSelection,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: notifier.clear,
                          ),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(l10n.selectedCount(sel.selected.length), style: context.text.titleSmall),
                            ),
                          ),
                          TextButton(onPressed: notifier.selectAll, child: Text(l10n.selectAll)),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                        child: Row(
                          children: [
                            action(Icons.play_arrow_rounded, l10n.play, (t) => player.playTracks(t)),
                            action(Icons.queue_music_rounded, l10n.queueAction, (t) async {
                              await player.enqueue(t);
                              showAppSnack(l10n.addedToQueue);
                            }),
                            action(Icons.playlist_add_rounded, l10n.addToPlaylist, (t) async {
                              final ctx = rootNavigatorKey.currentContext;
                              if (ctx != null) await showAddToPlaylist(ctx, t);
                            }),
                            action(Icons.favorite_border_rounded, l10n.favorites, (t) async {
                              await actions.favoriteMany(t);
                              showAppSnack(l10n.addedToFavoritesMany);
                            }),
                            action(Icons.share_outlined, l10n.share, actions.shareMany),
                            action(
                              Icons.delete_outline_rounded,
                              l10n.delete,
                              (t) => confirmAndDelete(t),
                              color: navo.danger,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Insets.xs),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> confirmAndDelete(List<Track> tracks) async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final l10n = ctx.l10n;
    final container = ProviderScope.containerOf(ctx, listen: false);
    final device = tracks.where((t) => !t.isDemo).toList();
    if (device.isEmpty) return showAppSnack(l10n.notAvailableForDemo);
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteSongsTitle(device.length)),
        content: Text(l10n.deleteSongsMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: c.navo.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final r = await container.read(songActionsProvider).deleteMany(device);
    if (r == DeleteResult.deleted) showAppSnack(l10n.songsDeleted(device.length));
  }
}
