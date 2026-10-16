import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/device_bridge.dart';
import '../../../../core/router/app_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/tap_scale.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../../player/state/player_providers.dart';
import '../../../playlists/ui/add_to_playlist_sheet.dart';
import '../../data/models.dart';
import '../../state/library_providers.dart';
import '../../state/song_actions.dart';
import '../../data/tag_editor.dart';
import '../collection_detail_screen.dart';
import '../tag_editor_screen.dart';
import '../labels.dart';
import 'song_details_dialog.dart';
import '../../../../core/theme/navo_theme.dart';

@immutable
class SongMenuEntry {
  const SongMenuEntry({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

Future<void> showSongOptions(BuildContext context, Track track, {List<SongMenuEntry> extras = const []}) {
  return showAppSheet<void>(context, (_) => _SongOptionsSheet(track: track, extras: extras));
}

class _SongOptionsSheet extends ConsumerWidget {
  const _SongOptionsSheet({required this.track, required this.extras});

  final Track track;
  final List<SongMenuEntry> extras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final actions = ref.read(songActionsProvider);
    final player = ref.read(playerControllerProvider);
    final isFav = ref.watch(isFavoriteProvider(track.key));
    final nav = rootNavigatorKey.currentState!;

    void close() => Navigator.of(context).pop();

    void openCollection(CollectionKind kind) {
      final id = kind == CollectionKind.album ? track.albumKey : artistIdFor(ref, track);
      close();
      nav.push(
        FadeThroughRoute<void>(
          builder: (_) => CollectionDetailScreen(kind: kind, id: id),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.sm, Insets.md),
            child: Row(
              children: [
                TrackArtwork(track: track, size: 56),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Insets.xs),
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
          const Divider(indent: Insets.page, endIndent: Insets.page),
          const SizedBox(height: Insets.xs),
          for (final e in extras)
            SheetAction(
              icon: e.icon,
              label: e.label,
              onTap: () {
                close();
                e.onTap();
              },
            ),
          SheetAction(
            icon: Icons.skip_next_outlined,
            label: l10n.playNext,
            onTap: () {
              close();
              player.playNext(track);
              showAppSnack(l10n.willPlayNext);
            },
          ),
          SheetAction(
            icon: Icons.queue_music_outlined,
            label: l10n.addToQueue,
            onTap: () {
              close();
              player.addToQueue(track);
              showAppSnack(l10n.addedToQueue);
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
          SheetAction(
            icon: Icons.album_outlined,
            label: l10n.goToAlbum,
            onTap: () => openCollection(CollectionKind.album),
          ),
          SheetAction(
            icon: Icons.person_outline_rounded,
            label: l10n.goToArtist,
            onTap: () => openCollection(CollectionKind.artist),
          ),
          if (TagEditor.canEdit(track))
            SheetAction(
              icon: Icons.edit_note_rounded,
              label: l10n.editTags,
              onTap: () {
                close();
                nav.push(FadeThroughRoute<void>(builder: (_) => TagEditorScreen(track: track)));
              },
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
            icon: Icons.ring_volume_outlined,
            label: l10n.setAsRingtone,
            onTap: () async {
              close();
              if (track.isDemo) return showAppSnack(l10n.notAvailableForDemo);
              final r = await actions.setRingtone(track);
              showAppSnack(switch (r) {
                RingtoneResult.ok => l10n.ringtoneSet,
                RingtoneResult.needsPermission => l10n.ringtoneNeedsPermission,
                RingtoneResult.failed => l10n.actionFailed,
              });
            },
          ),
          SheetAction(
            icon: Icons.block_rounded,
            label: l10n.addToBlocklist,
            onTap: () {
              close();
              actions.block(track);
              showAppSnack(l10n.addedToBlocklist, actionLabel: l10n.undo, onAction: () => actions.unblock(track.key));
            },
          ),
          SheetAction(
            icon: Icons.share_outlined,
            label: l10n.share,
            onTap: () {
              final box = context.findRenderObject() as RenderBox?;
              final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
              close();
              actions.share(track, origin: origin);
            },
          ),
          SheetAction(
            icon: Icons.delete_outline_rounded,
            label: l10n.deleteFromDevice,
            color: context.navo.danger,
            onTap: () async {
              close();
              if (track.isDemo) return showAppSnack(l10n.notAvailableForDemo);
              final confirmed = await showDialog<bool>(
                context: nav.context,
                builder: (c) => AlertDialog(
                  title: Text(l10n.deleteSongTitle),
                  content: Text(l10n.deleteSongMessage(track.title)),
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
              if (confirmed != true) return;
              final r = await actions.delete(track);
              if (r == DeleteResult.deleted) showAppSnack(l10n.songDeleted);
              if (r == DeleteResult.unsupported) showAppSnack(l10n.actionFailed);
            },
          ),
        ],
      ),
    );
  }
}

/// Heart toggle with a pop animation.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.track, required this.isFavorite, this.size = 24});

  final Track track;
  final bool isFavorite;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      toggled: isFavorite,
      label: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      child: TapScale(
        scale: 0.8,
        onTap: () async {
          final added = await ref.read(songActionsProvider).toggleFavorite(track);
          showAppSnack(added ? l10n.addedToFavorites : l10n.removedFromFavorites);
        },
        child: Padding(
          padding: const EdgeInsets.all(Insets.sm),
          child: AnimatedSwitcher(
            duration: AppDurations.medium,
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: c,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite ? context.navo.accent : context.navo.textPrimary,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}
