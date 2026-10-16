import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../../player/ui/mini_player.dart';
import '../../search/ui/search_screen.dart';
import '../state/library_providers.dart';
import 'widgets/song_tile.dart';

class RecentlyPlayedScreen extends ConsumerWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tracks = ref.watch(recentlyPlayedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recentlyPlayed),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.pushPage<void>((_) => const SearchScreen()),
          ),
          const SizedBox(width: Insets.xs),
        ],
      ),
      body: tracks.isEmpty
          ? EmptyState(icon: Icons.history_rounded, title: l10n.nothingPlayedYet, message: l10n.nothingPlayedHint)
          : ListView.builder(
              itemCount: tracks.length,
              padding: const EdgeInsets.only(bottom: Insets.lg),
              itemBuilder: (_, i) => SongTile(track: tracks[i], queue: tracks).staggered(i),
            ),
      bottomNavigationBar: const MiniPlayer(standalone: true),
    );
  }
}
