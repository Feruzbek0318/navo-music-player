import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/list_helpers.dart';
import '../../data/sorting.dart';
import '../../state/library_providers.dart';
import '../widgets/library_states.dart';
import '../widgets/song_tile.dart';
import '../widgets/sort_header.dart';

class SongsTab extends ConsumerWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return LibraryAsyncView(
      value: ref.watch(sortedSongsProvider),
      isEmpty: (d) => d.isEmpty,
      emptyIcon: Icons.music_off_rounded,
      emptyTitle: l10n.noSongsTitle,
      builder: (songs) => RefreshIndicator(
        onRefresh: () async => rescanLibrary(ref),
        child: CustomScrollView(
          key: const PageStorageKey('songs'),
          slivers: [
            const SliverToBoxAdapter(child: PermissionBanner()),
            SliverToBoxAdapter(
              child: SortHeader(section: LibrarySection.songs, countLabel: l10n.songsCount(songs.length)),
            ),
            SliverList.builder(
              itemCount: songs.length,
              itemBuilder: (_, i) => SongTile(track: songs[i], queue: songs).staggered(i),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Insets.lg)),
          ],
        ),
      ),
    );
  }
}
