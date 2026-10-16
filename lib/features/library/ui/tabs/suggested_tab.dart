import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/list_helpers.dart';
import '../../../../shared/widgets/tap_scale.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../../player/state/player_providers.dart';
import '../../../settings/data/app_settings.dart';
import '../../data/models.dart';
import '../../data/sorting.dart';
import '../../state/library_providers.dart';
import '../labels.dart';
import '../recently_played_screen.dart';
import '../widgets/library_states.dart';
import '../widgets/song_options_sheet.dart';
import 'collections_tabs.dart';

class SuggestedTab extends ConsumerWidget {
  const SuggestedTab({super.key, required this.onOpenTab});

  /// Jumps to another Home tab ("See All" on Artists).
  final ValueChanged<HomeTab> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final library = ref.watch(libraryTracksProvider);
    final recent = ref.watch(recentlyPlayedProvider);
    final most = ref.watch(mostPlayedProvider);
    final artists = ref.watch(artistsProvider).value ?? const [];

    return LibraryAsyncView(
      value: library,
      isEmpty: (d) => d.isEmpty,
      emptyIcon: Icons.music_off_rounded,
      emptyTitle: l10n.noSongsTitle,
      builder: (songs) {
        // Before anything is played, suggest the newest songs instead.
        final recentOrNew = recent.isNotEmpty ? recent : sortTracks(songs, SortOption.dateAdded).take(10).toList();
        final mostOrRandom = most.isNotEmpty ? most : songs.reversed.take(10).toList();
        final sections = <Widget>[
          const PermissionBanner(),
          SectionHeader(
            title: l10n.recentlyPlayed,
            onSeeAll: () => context.pushPage<void>((_) => const RecentlyPlayedScreen()),
          ),
          _TrackCarousel(tracks: recentOrNew),
          if (artists.isNotEmpty) ...[
            SectionHeader(title: l10n.tabArtists, onSeeAll: () => onOpenTab(HomeTab.artists)),
            _ArtistCarousel(artists: artists.take(12).toList()),
          ],
          SectionHeader(title: l10n.mostPlayed, onSeeAll: () => onOpenTab(HomeTab.songs)),
          _TrackCarousel(tracks: mostOrRandom),
          const SizedBox(height: Insets.xl),
        ];
        return ListView.builder(
          key: const PageStorageKey('suggested'),
          itemCount: sections.length,
          itemBuilder: (_, i) => sections[i].staggered(i),
        );
      },
    );
  }
}

class _TrackCarousel extends ConsumerWidget {
  const _TrackCarousel({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const size = Sizes.carouselItem;
    return SizedBox(
      height: size + 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Insets.pagePadding,
        itemCount: tracks.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.md),
        itemBuilder: (_, i) => Builder(
          builder: (context) {
            final t = tracks[i];
            return TapScale(
              onTap: () => ref.read(playerControllerProvider).playOrToggle(t, tracks),
              onLongPress: () => showSongOptions(context, t),
              child: SizedBox(
                width: size,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrackArtwork(track: t, size: size, radius: Radii.lg),
                    const SizedBox(height: Insets.sm),
                    Text(
                      '${t.title} - ${context.artistOf(t)}',
                      style: context.text.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArtistCarousel extends StatelessWidget {
  const _ArtistCarousel({required this.artists});

  final List<TrackCollection> artists;

  @override
  Widget build(BuildContext context) {
    const size = Sizes.artistAvatar;
    return SizedBox(
      height: size + 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Insets.pagePadding,
        itemCount: artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.lg),
        itemBuilder: (_, i) => Builder(
          builder: (context) {
            final a = artists[i];
            return TapScale(
              onTap: () => openCollection(context, a),
              child: SizedBox(
                width: size,
                child: Column(
                  children: [
                    TrackArtwork(track: a.cover, size: size, circle: true),
                    const SizedBox(height: Insets.sm),
                    Text(
                      context.collectionTitle(a),
                      style: context.text.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
