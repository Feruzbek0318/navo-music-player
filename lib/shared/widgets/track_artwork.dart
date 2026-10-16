import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/library/data/models.dart';
import '../../features/library/state/library_providers.dart';
import '../../core/theme/navo_theme.dart';

final artworkBytesProvider = FutureProvider.autoDispose.family<Uint8List?, Track>((ref, track) {
  if (track.assetArtwork != null) return null;
  return ref.read(musicRepositoryProvider).artwork(track);
});

/// Image provider for a track's artwork, if any (used for palettes too).
ImageProvider? artworkImageProvider(Track track, Uint8List? bytes) {
  if (track.assetArtwork != null) return AssetImage(track.assetArtwork!);
  if (bytes != null) return MemoryImage(bytes);
  return null;
}

/// Album art with a generated gradient placeholder.
class TrackArtwork extends ConsumerWidget {
  const TrackArtwork({
    super.key,
    required this.track,
    this.size,
    this.radius = Radii.sm,
    this.circle = false,
    this.heroTag,
  });

  final Track? track;

  /// `null` expands to the parent's constraints.
  final double? size;

  /// Base corner radius, scaled by the user's corner style.
  final double radius;
  final bool circle;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = track;
    Widget image;
    if (t == null) {
      image = const ArtworkPlaceholder(seed: 0);
    } else if (t.assetArtwork != null) {
      image = Image.asset(t.assetArtwork!, fit: BoxFit.cover, cacheWidth: _cacheWidth(context), gaplessPlayback: true);
    } else {
      final bytes = ref.watch(artworkBytesProvider(t));
      image = AnimatedSwitcher(
        duration: AppDurations.medium,
        child: switch (bytes) {
          AsyncData(value: final b?) => Image.memory(
            b,
            key: ValueKey(t.key),
            fit: BoxFit.cover,
            cacheWidth: _cacheWidth(context),
            gaplessPlayback: true,
          ),
          _ => ArtworkPlaceholder(key: ValueKey('ph-${t.key}'), seed: t.albumKey.hashCode),
        },
      );
    }

    Widget child = SizedBox(
      width: size,
      height: size,
      child: circle ? ClipOval(child: image) : ClipRRect(borderRadius: context.navo.radius(radius), child: image),
    );
    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }
    return child;
  }

  int? _cacheWidth(BuildContext context) {
    final s = size;
    if (s == null) return null;
    return (s * MediaQuery.devicePixelRatioOf(context)).round();
  }
}

class ArtworkPlaceholder extends StatelessWidget {
  const ArtworkPlaceholder({super.key, required this.seed, this.icon = Icons.music_note_rounded});

  final int seed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.artworkGradients[seed.abs() % AppColors.artworkGradients.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
      ),
      child: LayoutBuilder(
        builder: (context, c) => Center(
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: c.biggest.shortestSide * 0.42),
        ),
      ),
    );
  }
}

/// Orange folder glyph used for folder tiles and the folder detail header.
class FolderArtwork extends StatelessWidget {
  const FolderArtwork({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _FolderPainter(context.navo)),
    );
  }
}

class _FolderPainter extends CustomPainter {
  _FolderPainter(this.tokens);

  final NavoTheme tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Radius.circular(w * 0.12);
    final back = Paint()..color = tokens.accentDark;
    final front = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(tokens.accent, Colors.white, 0.25)!, tokens.accent],
      ).createShader(Offset.zero & size);

    final tab = Path()
      ..addRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(w * 0.06, h * 0.14, w * 0.42, h * 0.2), topLeft: r, topRight: r),
      );
    canvas.drawPath(tab, back);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.22, w * 0.88, h * 0.64), r), back);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.32, w * 0.88, h * 0.56), r), front);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, h * 0.56, w * 0.4, h * 0.07), Radius.circular(h * 0.035)),
      Paint()..color = tokens.background,
    );
  }

  @override
  bool shouldRepaint(_FolderPainter old) => old.tokens != tokens;
}
