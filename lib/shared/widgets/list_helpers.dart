import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../core/theme/navo_theme.dart';

extension StaggeredEntrance on Widget {
  /// Fades and slides list items in, staggered by [index]. Only the first
  /// screenful animates so long lists don't replay effects while scrolling.
  Widget staggered(int index, {int max = 12}) {
    if (index >= max) return this;
    return animate(delay: AppDurations.stagger * index)
        .fadeIn(duration: AppDurations.medium, curve: AppCurves.standard)
        .slideY(begin: 0.12, end: 0, duration: AppDurations.medium, curve: AppCurves.standard);
  }
}

/// "Recently Played ........ See All"
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll, this.padding});

  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(Insets.page, Insets.xl, Insets.sm, Insets.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(context.l10n.seeAll, style: context.text.labelMedium?.copyWith(color: context.navo.accent)),
            ),
        ],
      ),
    );
  }
}

/// Shimmering placeholder rows shown while the library loads.
class SongListSkeleton extends StatelessWidget {
  const SongListSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          padding: const EdgeInsets.only(top: Insets.lg),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page, vertical: Insets.sm),
            child: Row(
              children: [
                const _Bone(width: Sizes.songArtwork, height: Sizes.songArtwork, radius: Radii.sm),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(widthFactor: 0.4 + (i % 3) * 0.15, child: const _Bone(height: 14)),
                      const SizedBox(height: Insets.sm),
                      const FractionallySizedBox(widthFactor: 0.35, child: _Bone(height: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: Insets.md),
                const _Bone(width: 26, height: 26, radius: 13),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withValues(alpha: 0.06));
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.width, required this.height, this.radius = Radii.xs});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: context.navo.surface, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
