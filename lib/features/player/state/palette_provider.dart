import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/data/models.dart';

/// Dominant colour from a track's artwork, used for the player background.
final paletteColorProvider = FutureProvider.autoDispose.family<Color, Track>((ref, track) async {
  final fallback = AppColors.artworkGradients[track.albumKey.hashCode.abs() % AppColors.artworkGradients.length].first;
  final bytes = track.assetArtwork == null ? await ref.watch(artworkBytesProvider(track).future) : null;
  final provider = artworkImageProvider(track, bytes);
  if (provider == null) return fallback;
  try {
    final palette = await PaletteGenerator.fromImageProvider(
      ResizeImage(provider, width: 96, height: 96),
      maximumColorCount: 12,
    );
    final color = palette.vibrantColor?.color ?? palette.dominantColor?.color ?? palette.mutedColor?.color ?? fallback;
    return _tame(color);
  } catch (_) {
    return fallback;
  }
});

/// Keeps very light or very dark colours usable behind white text.
Color _tame(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness.clamp(0.28, 0.5)).withSaturation(hsl.saturation.clamp(0.25, 0.85)).toColor();
}
