import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_keys.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../player/state/player_providers.dart';
import '../../../playlists/ui/add_to_playlist_sheet.dart';
import '../../data/models.dart';
import '../../state/song_actions.dart';
import '../labels.dart';
import 'collection_artwork.dart';

/// Menu for an artist, album, folder or playlist (reference: artist menu).
Future<void> showCollectionOptions(
  BuildContext context,
  TrackCollection collection, {
  List<Widget> Function(VoidCallback close)? extras,
}) {
  return showAppSheet<void>(context, (_) => _CollectionOptionsSheet(collection: collection, extras: extras));
}

class _CollectionOptionsSheet extends ConsumerWidget {
  const _CollectionOptionsSheet({required this.collection, this.extras});

  final TrackCollection collection;
  final List<Widget> Function(VoidCallback close)? extras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final player = ref.read(playerControllerProvider);
    final actions = ref.read(songActionsProvider);
    final tracks = collection.tracks;
    final nav = rootNavigatorKey.currentState!;
    void close() => Navigator.of(context).pop();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, Insets.md),
            child: Row(
              children: [
                CollectionArtwork(collection: collection, size: 56),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.collectionTitle(collection),
                        style: context.text.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Insets.xs),
                      Text(
                        context.collectionSubtitle(collection),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: Insets.page, endIndent: Insets.page),
          const SizedBox(height: Insets.xs),
          SheetAction(
            icon: Icons.play_circle_outline_rounded,
            label: l10n.play,
            onTap: () {
              close();
              player.playTracks(tracks);
            },
          ),
          SheetAction(
            icon: Icons.skip_next_outlined,
            label: l10n.playNext,
            onTap: () async {
              close();
              for (final t in tracks.reversed) {
                await player.playNext(t);
              }
              showAppSnack(l10n.willPlayNext);
            },
          ),
          SheetAction(
            icon: Icons.queue_music_outlined,
            label: l10n.addToQueue,
            onTap: () async {
              close();
              for (final t in tracks) {
                await player.addToQueue(t);
              }
              showAppSnack(l10n.addedToQueue);
            },
          ),
          if (collection.kind != CollectionKind.playlist)
            SheetAction(
              icon: Icons.playlist_add_rounded,
              label: l10n.addToPlaylist,
              onTap: () {
                close();
                showAddToPlaylist(nav.context, tracks);
              },
            ),
          SheetAction(
            icon: Icons.share_outlined,
            label: l10n.share,
            onTap: () {
              close();
              actions.shareMany(tracks);
            },
          ),
          ...?extras?.call(close),
        ],
      ),
    );
  }
}
