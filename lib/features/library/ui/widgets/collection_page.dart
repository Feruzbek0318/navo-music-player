import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/list_helpers.dart';
import '../../../player/state/player_providers.dart';
import '../../../player/ui/mini_player.dart';
import '../../../search/ui/search_screen.dart';
import '../../data/models.dart';

/// Shared layout for artist / album / folder / playlist pages:
/// big artwork, title, stats, Shuffle + Play, then the song list.
class CollectionPage extends ConsumerWidget {
  const CollectionPage({
    super.key,
    required this.artwork,
    required this.title,
    required this.stats,
    required this.tracks,
    required this.songList,
    this.onMore,
    this.emptyState,
  });

  final Widget artwork;
  final String title;
  final String stats;
  final List<Track> tracks;

  /// Sliver containing the songs.
  final Widget songList;
  final VoidCallback? onMore;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final player = ref.read(playerControllerProvider);
    final artworkSize = (MediaQuery.sizeOf(context).width * 0.5).clamp(160.0, 240.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.pushPage<void>((_) => const SearchScreen()),
          ),
          if (onMore != null)
            IconButton(tooltip: l10n.more, icon: const Icon(Icons.more_horiz_rounded), onPressed: onMore),
          const SizedBox(width: Insets.xs),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.page),
              child: Column(
                children: [
                  const SizedBox(height: Insets.sm),
                  SizedBox.square(dimension: artworkSize, child: artwork)
                      .animate()
                      .fadeIn(duration: AppDurations.medium)
                      .scale(begin: const Offset(0.92, 0.92), curve: AppCurves.standard, duration: AppDurations.slow),
                  const SizedBox(height: Insets.xl),
                  Text(
                    title,
                    style: context.text.headlineSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(stats, style: context.text.bodySmall, textAlign: TextAlign.center, maxLines: 2),
                  const SizedBox(height: Insets.xl),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.shuffle,
                          icon: Icons.shuffle_rounded,
                          onPressed: tracks.isEmpty ? null : () => player.shuffleAll(tracks),
                        ),
                      ),
                      const SizedBox(width: Insets.lg),
                      Expanded(
                        child: SecondaryButton(
                          label: l10n.play,
                          icon: Icons.play_circle_fill_rounded,
                          onPressed: tracks.isEmpty ? null : () => player.playTracks(tracks),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: AppDurations.fast, duration: AppDurations.medium),
                  const SizedBox(height: Insets.lg),
                  const Divider(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.songs,
              padding: const EdgeInsets.fromLTRB(Insets.page, Insets.lg, Insets.page, Insets.xs),
            ),
          ),
          if (tracks.isEmpty && emptyState != null)
            SliverFillRemaining(hasScrollBody: false, child: emptyState)
          else
            songList,
          const SliverToBoxAdapter(child: SizedBox(height: Insets.xl)),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(standalone: true),
    );
  }
}
