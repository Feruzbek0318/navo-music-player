import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../library/state/library_providers.dart';
import '../../library/state/song_actions.dart';
import '../../library/ui/labels.dart';

class BlockedSongsScreen extends ConsumerWidget {
  const BlockedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final blocked = ref.watch(blocklistProvider).toList();
    final byKey = ref.watch(tracksByKeyProvider);
    final actions = ref.read(songActionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.blockedSongs)),
      body: blocked.isEmpty
          ? EmptyState(icon: Icons.check_circle_outline_rounded, title: l10n.blockedSongsEmpty)
          : ListView.builder(
              itemCount: blocked.length,
              itemBuilder: (_, i) {
                final t = byKey[blocked[i]];
                return ListTile(
                  title: Text(t?.title ?? l10n.unknown, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: t == null
                      ? null
                      : Text(context.trackSubtitle(t), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: TextButton(onPressed: () => actions.unblock(blocked[i]), child: Text(l10n.unblock)),
                );
              },
            ),
    );
  }
}
