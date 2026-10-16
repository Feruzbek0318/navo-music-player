import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../data/sorting.dart';
import '../../state/library_providers.dart';
import '../labels.dart';
import '../../../../core/theme/navo_theme.dart';

/// "560 songs ............ Ascending ⇅" with a radio popup.
class SortHeader extends ConsumerWidget {
  const SortHeader({super.key, required this.section, required this.countLabel});

  final LibrarySection section;
  final String countLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortProvider(section));
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.sm, Insets.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(countLabel, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          PopupMenuButton<SortOption>(
            tooltip: l10n.sortBy,
            initialValue: current,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 4),
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
            onSelected: (o) => ref.read(sortProvider(section).notifier).set(o),
            itemBuilder: (context) => [
              for (final o in section.options)
                PopupMenuItem<SortOption>(
                  value: o,
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(child: Text(sortLabel(l10n, o), style: context.text.bodyMedium)),
                      const SizedBox(width: Insets.md),
                      _RadioDot(selected: o == current),
                    ],
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 170),
                    child: Text(
                      sortLabel(l10n, current),
                      style: context.text.labelMedium?.copyWith(color: context.navo.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Insets.xs),
                  Icon(Icons.swap_vert_rounded, color: context.navo.accent, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.navo.accent, width: 2),
      ),
      padding: const EdgeInsets.all(3),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: AppDurations.fast,
        child: DecoratedBox(
          decoration: BoxDecoration(color: context.navo.accent, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
