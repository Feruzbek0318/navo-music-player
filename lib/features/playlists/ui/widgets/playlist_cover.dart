import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../state/playlist_providers.dart';

/// 2×2 mosaic of the first songs' artwork, or a placeholder.
class PlaylistCover extends ConsumerWidget {
  const PlaylistCover({super.key, required this.playlistId, required this.size, this.radius = Radii.sm});

  final String playlistId;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(playlistTracksProvider(playlistId)).map((e) => e.$2).toList();
    final Widget child;
    if (tracks.length < 4) {
      child = tracks.isEmpty
          ? ArtworkPlaceholder(seed: playlistId.hashCode, icon: Icons.queue_music_rounded)
          : TrackArtwork(track: tracks.first, size: size, radius: 0);
    } else {
      final half = size / 2;
      child = Wrap(
        children: [for (final t in tracks.take(4)) TrackArtwork(track: t, size: half, radius: 0)],
      );
    }
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}
