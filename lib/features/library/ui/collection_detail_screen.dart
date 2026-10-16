import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../data/models.dart';
import '../state/library_providers.dart';
import 'labels.dart';
import 'widgets/collection_artwork.dart';
import 'widgets/collection_options_sheet.dart';
import 'widgets/collection_page.dart';
import 'widgets/song_tile.dart';

/// Artist, album or folder page.
class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.kind, required this.id});

  final CollectionKind kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(collectionProvider((kind, id)));
    if (collection == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.music_off_rounded, title: context.l10n.noSongsTitle),
      );
    }
    final tracks = collection.tracks;
    return CollectionPage(
      artwork: CollectionArtwork(collection: collection, radius: Radii.lg),
      title: context.collectionTitle(collection),
      stats: context.collectionStats(collection),
      tracks: tracks,
      onMore: () => showCollectionOptions(context, collection),
      songList: SliverList.builder(
        itemCount: tracks.length,
        itemBuilder: (_, i) => SongTile(track: tracks[i], queue: tracks).staggered(i),
      ),
    );
  }
}
