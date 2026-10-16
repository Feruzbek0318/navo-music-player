import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../library/data/models.dart';
import '../../library/ui/widgets/collection_options_sheet.dart';
import '../../library/ui/widgets/collection_page.dart';
import '../../library/ui/widgets/song_options_sheet.dart';
import '../../library/ui/widgets/song_tile.dart';
import '../state/playlist_io.dart';
import '../state/playlist_providers.dart';
import 'playlist_name_dialog.dart';
import 'widgets/playlist_cover.dart';
import '../../../core/theme/navo_theme.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playlist = ref.watch(playlistProvider(playlistId));
    if (playlist == null) return const Scaffold();
    final entries = ref.watch(playlistTracksProvider(playlistId));
    final tracks = entries.map((e) => e.$2).toList();
    final notifier = ref.read(playlistsProvider.notifier);
    final total = tracks.fold(Duration.zero, (a, t) => a + t.duration);

    Future<void> rename() async {
      final name = await showPlaylistNameDialog(context, initial: playlist.name, rename: true);
      if (name != null) await notifier.rename(playlist.id, name);
    }

    Future<void> delete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l10n.deletePlaylistTitle),
          content: Text(l10n.deletePlaylistMessage(playlist.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              style: TextButton.styleFrom(foregroundColor: context.navo.danger),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (ok == true && context.mounted) {
        Navigator.pop(context);
        await notifier.delete(playlist.id);
      }
    }

    final collection = TrackCollection(
      id: playlist.id,
      kind: CollectionKind.playlist,
      name: playlist.name,
      tracks: tracks,
    );

    return CollectionPage(
      artwork: PlaylistCover(playlistId: playlist.id, size: 240, radius: Radii.lg),
      title: playlist.name,
      stats: '${l10n.songsCount(tracks.length)}  |  ${l10n.durationMins(formatDuration(total))}',
      tracks: tracks,
      onMore: () => tracks.isEmpty
          ? showAppSheet<void>(context, (c) => _PlaylistManageActions(onRename: rename, onDelete: delete))
          : showCollectionOptions(
              context,
              collection,
              extras: (close) => [
                SheetAction(
                  icon: Icons.file_upload_outlined,
                  label: l10n.exportM3u,
                  onTap: () async {
                    close();
                    final ok = await ref.read(playlistIoProvider).exportM3u(playlist.name, tracks);
                    if (ok && context.mounted) context.showSnack(l10n.m3uExported);
                  },
                ),
                SheetAction(
                  icon: Icons.edit_outlined,
                  label: l10n.rename,
                  onTap: () {
                    close();
                    rename();
                  },
                ),
                SheetAction(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.delete,
                  color: context.navo.danger,
                  onTap: () {
                    close();
                    delete();
                  },
                ),
              ],
            ),
      emptyState: EmptyState(
        icon: Icons.playlist_add_rounded,
        title: l10n.emptyPlaylist,
        message: l10n.emptyPlaylistHint,
      ),
      songList: SliverReorderableList(
        itemCount: entries.length,
        onReorderItem: (from, to) => notifier.moveTrack(playlist.id, entries[from].$1, entries[to].$1),
        proxyDecorator: (child, _, _) => Material(color: context.navo.surfaceHigh, elevation: 6, child: child),
        itemBuilder: (_, i) => Builder(
          // Reorderable lists need the key on the outermost item widget.
          key: ValueKey('${playlist.id}-${entries[i].$1}-${entries[i].$2.key}'),
          builder: (context) {
            final (storedIndex, track) = entries[i];
            return Material(
              key: ValueKey('${playlist.id}-$storedIndex-${track.key}'),
              type: MaterialType.transparency,
              child: SongTile(
                track: track,
                queue: tracks,
                menuExtras: [
                  SongMenuEntry(
                    icon: Icons.playlist_remove_rounded,
                    label: l10n.removeFromPlaylist,
                    onTap: () => notifier.removeTrackAt(playlist.id, storedIndex),
                  ),
                ],
                trailing: ReorderableDragStartListener(
                  index: i,
                  child: Padding(
                    padding: EdgeInsets.all(Insets.md),
                    child: Icon(Icons.drag_handle_rounded, color: context.navo.textSecondary),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlaylistManageActions extends StatelessWidget {
  const _PlaylistManageActions({required this.onRename, required this.onDelete});

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetAction(
            icon: Icons.edit_outlined,
            label: l10n.rename,
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          SheetAction(
            icon: Icons.delete_outline_rounded,
            label: l10n.delete,
            color: context.navo.danger,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
