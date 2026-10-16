import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../data/models.dart';

/// Artwork for a collection: circle for artists, folder glyph for folders,
/// rounded square otherwise.
class CollectionArtwork extends StatelessWidget {
  const CollectionArtwork({super.key, required this.collection, this.size, this.radius = Radii.sm, this.heroTag});

  final TrackCollection collection;
  final double? size;
  final double radius;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (collection.kind) {
      CollectionKind.folder => FolderArtwork(size: size ?? 120),
      CollectionKind.artist => TrackArtwork(track: collection.cover, size: size, circle: true),
      _ => TrackArtwork(track: collection.tracks.isEmpty ? null : collection.cover, size: size, radius: radius),
    };
    return heroTag == null ? child : Hero(tag: heroTag!, child: child);
  }
}
