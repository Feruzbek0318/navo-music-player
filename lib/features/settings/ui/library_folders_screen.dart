import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../../library/data/models.dart';
import '../../library/state/library_providers.dart';
import '../state/settings_providers.dart';

enum FolderRule { shown, hidden, only }

/// Every folder that contains audio, with show / hide / only-these rules.
final deviceFoldersProvider = FutureProvider<List<(String, int)>>((ref) async {
  final all = await ref.watch(deviceTracksProvider.future);
  final counts = <String, int>{};
  for (final t in all) {
    if (t.path != null) counts[t.folderPath] = (counts[t.folderPath] ?? 0) + 1;
  }
  final list = counts.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) => a.$1.compareTo(b.$1));
  return list;
});

class LibraryFoldersScreen extends ConsumerWidget {
  const LibraryFoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final navo = context.navo;
    final lib = ref.watch(librarySettingsProvider);
    final folders = ref.watch(deviceFoldersProvider);
    final notifier = ref.read(settingsProvider.notifier);

    FolderRule rule(String f) => lib.includedFolders.contains(f)
        ? FolderRule.only
        : lib.excludedFolders.contains(f)
        ? FolderRule.hidden
        : FolderRule.shown;

    void set(String f, FolderRule r) => notifier.library(
      (l) => l.copyWith(
        includedFolders: [...l.includedFolders.where((x) => x != f), if (r == FolderRule.only) f],
        excludedFolders: [...l.excludedFolders.where((x) => x != f), if (r == FolderRule.hidden) f],
      ),
    );

    String label(FolderRule r) => switch (r) {
      FolderRule.shown => l10n.folderShown,
      FolderRule.hidden => l10n.folderHidden,
      FolderRule.only => l10n.folderOnly,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryFolders),
        actions: [
          if (lib.includedFolders.isNotEmpty || lib.excludedFolders.isNotEmpty)
            TextButton(
              onPressed: () =>
                  notifier.library((l) => l.copyWith(includedFolders: const [], excludedFolders: const [])),
              child: Text(l10n.resetFolders),
            ),
        ],
      ),
      body: switch (folders) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          icon: Icons.folder_off_outlined,
          title: l10n.noFolders,
        ),
        AsyncData(:final value) => ListView(
          padding: EdgeInsets.only(bottom: Insets.xxl + MediaQuery.paddingOf(context).bottom),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.md),
              child: Text(
                lib.includedFolders.isNotEmpty ? l10n.folderOnlyActive : l10n.libraryFoldersHint,
                style: context.text.bodySmall,
              ),
            ),
            for (final (path, count) in value)
              ListTile(
                leading: Opacity(
                  opacity: rule(path) == FolderRule.hidden ? 0.4 : 1,
                  child: const FolderArtwork(size: 40),
                ),
                title: Text(
                  path == Track.demoFolderPath ? l10n.appName : path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${l10n.songsCount(count)} · $path', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: PopupMenuButton<FolderRule>(
                  tooltip: label(rule(path)),
                  initialValue: rule(path),
                  onSelected: (r) => set(path, r),
                  itemBuilder: (_) => [
                    for (final r in FolderRule.values) PopupMenuItem(value: r, child: Text(label(r))),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: Insets.md),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label(rule(path)),
                          style: context.text.labelMedium?.copyWith(
                            color: rule(path) == FolderRule.hidden ? navo.textTertiary : navo.accent,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: navo.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        AsyncError() => EmptyState(icon: Icons.error_outline_rounded, title: l10n.errorTitle),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
