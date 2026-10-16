import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../../library/ui/widgets/collection_page.dart';
import '../../library/ui/widgets/song_tile.dart';
import '../state/smart_playlists.dart';

/// Read-only playlist built from listening data or the library.
class SmartPlaylistScreen extends ConsumerWidget {
  const SmartPlaylistScreen({super.key, required this.playlist});

  final SmartPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final navo = context.navo;
    final tracks = ref.watch(smartPlaylistTracksProvider(playlist));
    final total = tracks.fold(Duration.zero, (a, t) => a + t.duration);
    return CollectionPage(
      artwork: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: navo.radius(Radii.lg),
          gradient: LinearGradient(colors: [navo.accent, navo.accentDark]),
        ),
        child: Icon(playlist.icon, size: 96, color: navo.onAccent),
      ),
      title: playlist.title(l10n),
      stats: '${l10n.songsCount(tracks.length)}  |  ${l10n.durationMins(formatDuration(total))}',
      tracks: tracks,
      emptyState: EmptyState(icon: playlist.icon, title: l10n.noSongsTitle),
      songList: SliverList.builder(
        itemCount: tracks.length,
        itemBuilder: (_, i) => SongTile(track: tracks[i], queue: tracks).staggered(i),
      ),
    );
  }
}
