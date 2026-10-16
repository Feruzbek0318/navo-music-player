import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/list_helpers.dart';
import '../../../../shared/widgets/tap_scale.dart';
import '../../data/models.dart';
import '../../data/sorting.dart';
import '../../state/library_providers.dart';
import '../collection_detail_screen.dart';
import '../labels.dart';
import '../widgets/collection_artwork.dart';
import '../widgets/collection_options_sheet.dart';
import '../widgets/library_states.dart';
import '../widgets/sort_header.dart';
import '../../../../core/theme/navo_theme.dart';

void openCollection(BuildContext context, TrackCollection c) {
  context.pushPage<void>((_) => CollectionDetailScreen(kind: c.kind, id: c.id));
}

class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return LibraryAsyncView(
      value: ref.watch(artistsProvider),
      isEmpty: (d) => d.isEmpty,
      emptyIcon: Icons.person_off_outlined,
      emptyTitle: l10n.noArtists,
      builder: (artists) => CustomScrollView(
        key: const PageStorageKey('artists'),
        slivers: [
          SliverToBoxAdapter(
            child: SortHeader(section: LibrarySection.artists, countLabel: l10n.artistsCount(artists.length)),
          ),
          SliverList.builder(
            itemCount: artists.length,
            itemBuilder: (_, i) => CollectionTile(collection: artists[i]).staggered(i),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Insets.lg)),
        ],
      ),
    );
  }
}

class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return LibraryAsyncView(
      value: ref.watch(foldersProvider),
      isEmpty: (d) => d.isEmpty,
      emptyIcon: Icons.folder_off_outlined,
      emptyTitle: l10n.noFolders,
      builder: (folders) => CustomScrollView(
        key: const PageStorageKey('folders'),
        slivers: [
          SliverToBoxAdapter(
            child: SortHeader(section: LibrarySection.folders, countLabel: l10n.foldersCount(folders.length)),
          ),
          SliverList.builder(
            itemCount: folders.length,
            itemBuilder: (_, i) => CollectionTile(collection: folders[i]).staggered(i),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Insets.lg)),
        ],
      ),
    );
  }
}

class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return LibraryAsyncView(
      value: ref.watch(albumsProvider),
      isEmpty: (d) => d.isEmpty,
      emptyIcon: Icons.album_outlined,
      emptyTitle: l10n.noAlbums,
      builder: (albums) => CustomScrollView(
        key: const PageStorageKey('albums'),
        slivers: [
          SliverToBoxAdapter(
            child: SortHeader(section: LibrarySection.albums, countLabel: l10n.albumsCount(albums.length)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.lg),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: Insets.lg,
                crossAxisSpacing: Insets.lg,
                childAspectRatio: 0.72,
              ),
              itemCount: albums.length,
              itemBuilder: (_, i) => AlbumCard(album: albums[i]).staggered(i, max: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row for an artist or folder: artwork, name, counts, menu.
class CollectionTile extends StatelessWidget {
  const CollectionTile({super.key, required this.collection, this.trailing});

  final TrackCollection collection;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      scale: 0.98,
      onTap: () => openCollection(context, collection),
      onLongPress: () => showCollectionOptions(context, collection),
      child: Padding(
        padding: EdgeInsets.fromLTRB(Insets.page, context.navo.rowPadding, Insets.xs, context.navo.rowPadding),
        child: Row(
          children: [
            CollectionArtwork(collection: collection, size: context.navo.listArtSize),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.collectionTitle(collection),
                    style: context.text.bodyLarge,
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
            trailing ??
                IconButton(
                  tooltip: context.l10n.more,
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () => showCollectionOptions(context, collection),
                ),
          ],
        ),
      ),
    );
  }
}

/// Grid card for an album (reference: Albums tab).
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album});

  final TrackCollection album;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () => openCollection(context, album),
      onLongPress: () => showCollectionOptions(context, album),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CollectionArtwork(collection: album, radius: Radii.lg),
          ),
          const SizedBox(height: Insets.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.collectionTitle(album),
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  tooltip: context.l10n.more,
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () => showCollectionOptions(context, album),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            context.collectionSubtitle(album),
            style: context.text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.songsCount(album.songCount),
            style: context.text.bodySmall?.copyWith(color: context.navo.textTertiary),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
