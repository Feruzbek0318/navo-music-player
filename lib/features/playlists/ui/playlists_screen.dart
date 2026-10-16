import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../../../shared/widgets/tap_scale.dart';
import '../state/playlist_io.dart';
import '../state/playlist_providers.dart';
import '../state/smart_playlists.dart';
import 'playlist_detail_screen.dart';
import 'playlist_name_dialog.dart';
import 'smart_playlist_screen.dart';
import 'widgets/playlist_cover.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await showPlaylistNameDialog(context, rename: false);
    if (name != null) await ref.read(playlistsProvider.notifier).create(name);
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final r = await ref.read(playlistIoProvider).importM3u();
    if (r == null || !context.mounted) return;
    context.showSnack(r.count == 0 ? l10n.m3uNoMatches : l10n.m3uImported(r.name, l10n.songsCount(r.count)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final navo = context.navo;
    final playlists = ref.watch(playlistsProvider);
    final notifier = ref.read(playlistsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Insets.page,
        title: Text(l10n.playlists),
        actions: [
          IconButton(
            tooltip: l10n.importM3u,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _import(context, ref),
          ),
          IconButton(
            tooltip: l10n.newPlaylist,
            icon: Icon(Icons.add_rounded, color: navo.accent, size: 28),
            onPressed: () => _create(context, ref),
          ),
          const SizedBox(width: Insets.xs),
        ],
      ),
      body: Column(
        children: [
          SectionHeader(
            title: l10n.smartPlaylists,
            padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.sm),
          ),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: Insets.pagePadding,
              itemCount: SmartPlaylist.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: Insets.md),
              itemBuilder: (_, i) => _SmartCard(playlist: SmartPlaylist.values[i]),
            ),
          ),
          SectionHeader(
            title: '${l10n.myPlaylists} · ${playlists.length}',
            padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xl, Insets.page, Insets.xs),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: playlists.isEmpty
                  ? EmptyState(
                      key: const ValueKey('empty'),
                      icon: Icons.queue_music_rounded,
                      title: l10n.noPlaylists,
                      message: l10n.noPlaylistsHint,
                      actionLabel: l10n.newPlaylist,
                      onAction: () => _create(context, ref),
                    )
                  : ReorderableListView.builder(
                      key: const ValueKey('list'),
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.only(bottom: Insets.lg),
                      itemCount: playlists.length,
                      onReorderItem: notifier.reorder,
                      proxyDecorator: (child, _, _) =>
                          Material(color: navo.surfaceHigh, elevation: 6, borderRadius: navo.cardRadius, child: child),
                      itemBuilder: (_, i) => Builder(
                        // Reorderable lists need the key on the outermost item widget.
                        key: ValueKey(playlists[i].id),
                        builder: (context) {
                          final p = playlists[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.xs, Insets.xs),
                            leading: PlaylistCover(playlistId: p.id, size: context.navo.listArtSize),
                            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(context.l10n.songsCount(p.trackKeys.length)),
                            onTap: () => context.pushPage<void>((_) => PlaylistDetailScreen(playlistId: p.id)),
                            trailing: ReorderableDragStartListener(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.all(Insets.md),
                                child: Icon(Icons.drag_handle_rounded, color: context.navo.textSecondary),
                              ),
                            ),
                          ).staggered(i);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartCard extends ConsumerWidget {
  const _SmartCard({required this.playlist});

  final SmartPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navo = context.navo;
    final count = ref.watch(smartPlaylistTracksProvider(playlist)).length;
    return TapScale(
      onTap: () => context.pushPage<void>((_) => SmartPlaylistScreen(playlist: playlist)),
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(Insets.md),
        decoration: BoxDecoration(
          borderRadius: navo.radius(Radii.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [navo.accent.withValues(alpha: 0.28), navo.surface],
          ),
          border: Border.all(color: navo.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(playlist.icon, color: navo.accent),
            Text(
              playlist.title(context.l10n),
              style: context.text.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(context.l10n.songsCount(count), style: context.text.bodySmall, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
