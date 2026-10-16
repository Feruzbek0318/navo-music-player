import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../../library/state/library_providers.dart';
import '../../library/ui/widgets/song_tile.dart';
import '../../player/state/player_providers.dart';
import '../../../core/theme/navo_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tracks = ref.watch(favoriteTracksProvider);
    final player = ref.read(playerControllerProvider);

    return Scaffold(
      appBar: AppBar(titleSpacing: Insets.page, title: Text(l10n.favorites)),
      body: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: tracks.isEmpty
            ? EmptyState(
                key: const ValueKey('empty'),
                icon: Icons.favorite_border_rounded,
                title: l10n.noFavorites,
                message: l10n.noFavoritesHint,
              )
            : CustomScrollView(
                key: const ValueKey('list'),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.sm),
                      child: Row(
                        children: [
                          Expanded(child: Text(l10n.songsCount(tracks.length), style: context.text.titleSmall)),
                          Icon(Icons.favorite_rounded, color: context.navo.accent, size: 18),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: l10n.shuffle,
                              icon: Icons.shuffle_rounded,
                              onPressed: () => player.shuffleAll(tracks),
                            ),
                          ),
                          const SizedBox(width: Insets.lg),
                          Expanded(
                            child: SecondaryButton(
                              label: l10n.play,
                              icon: Icons.play_circle_fill_rounded,
                              onPressed: () => player.playTracks(tracks),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: tracks.length,
                    itemBuilder: (_, i) => SongTile(track: tracks[i], queue: tracks).staggered(i),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: Insets.lg)),
                ],
              ),
      ),
    );
  }
}
