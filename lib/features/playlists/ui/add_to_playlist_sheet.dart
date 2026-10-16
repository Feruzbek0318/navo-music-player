import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_keys.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../library/data/models.dart';
import '../state/playlist_providers.dart';
import 'playlist_name_dialog.dart';
import 'widgets/playlist_cover.dart';
import '../../../core/theme/navo_theme.dart';

Future<void> showAddToPlaylist(BuildContext context, List<Track> tracks) {
  return showAppSheet<void>(context, (_) => _AddToPlaylistSheet(tracks: tracks));
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playlists = ref.watch(playlistsProvider);
    final notifier = ref.read(playlistsProvider.notifier);
    final keys = tracks.map((t) => t.key).toList();
    final nav = rootNavigatorKey.currentState!;

    Future<void> createNew() async {
      Navigator.of(context).pop();
      final name = await showPlaylistNameDialog(nav.context, rename: false);
      if (name == null) return;
      await notifier.create(name, trackKeys: keys);
      showAppSnack(l10n.addedToPlaylist(name));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetTitle(l10n.addToPlaylist),
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.navo.accent.withValues(alpha: 0.15),
              borderRadius: context.navo.tileRadius,
            ),
            child: Icon(Icons.add_rounded, color: context.navo.accent),
          ),
          title: Text(l10n.newPlaylist, style: context.text.bodyLarge?.copyWith(color: context.navo.accent)),
          onTap: createNew,
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.md),
            itemCount: playlists.length,
            itemBuilder: (_, i) {
              final p = playlists[i];
              return ListTile(
                leading: PlaylistCover(playlistId: p.id, size: 48),
                title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(l10n.songsCount(p.trackKeys.length)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final added = await notifier.addTracks(p.id, keys);
                  showAppSnack(added == 0 ? l10n.alreadyInPlaylist(p.name) : l10n.addedToPlaylist(p.name));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
