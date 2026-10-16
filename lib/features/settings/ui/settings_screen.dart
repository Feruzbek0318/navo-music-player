import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../search/state/search_providers.dart';
import '../state/settings_providers.dart';
import 'settings_items.dart';
import 'settings_registry.dart';
import 'widgets/setting_tile.dart';

/// Settings home: a search field and the list of groups. While searching,
/// matching settings from every group are shown inline and stay editable.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _resetAll() async {
    final l10n = context.l10n;
    final ok = await confirmReset(context, title: l10n.resetAllTitle, message: l10n.resetAllMessage);
    if (!ok || !mounted) return;
    ref.read(settingsProvider.notifier).resetAll();
    context.showSnack(l10n.settingsRestored);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navo = context.navo;
    final settings = ref.watch(settingsProvider);
    final q = normalizeForSearch(_query);

    final results = <(SettingsGroup, SettingItem)>[];
    if (q.isNotEmpty) {
      for (final g in settingsGroups) {
        for (final item in g.items) {
          if (item is HeaderItem || item is CustomItem && item.keywords == null) continue;
          if (!item.isVisible(settings, ref)) continue;
          final hay = normalizeForSearch(
            '${item.title(l10n)} ${item.subtitle?.call(l10n) ?? ''} ${item.keywords?.call(l10n) ?? ''} ${g.title(l10n)}',
          );
          if (hay.contains(q)) results.add((g, item));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Insets.page,
        title: Text(l10n.settings),
        actions: [
          PopupMenuButton<void>(
            tooltip: l10n.more,
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: _resetAll,
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, color: navo.danger),
                    const SizedBox(width: Insets.md),
                    Text(l10n.resetAll),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, Insets.sm),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.settingsSearchHint,
                prefixIcon: Icon(Icons.search_rounded, color: navo.accent, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearAll,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() {
                          _search.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
          ),
          Expanded(
            child: q.isEmpty
                ? ListView(
                    padding: const EdgeInsets.only(bottom: Insets.xl),
                    children: [for (final g in settingsGroups) _GroupTile(group: g)],
                  )
                : results.isEmpty
                ? EmptyState(icon: Icons.search_off_rounded, title: l10n.noSettingsFound(_query.trim()))
                : ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: Insets.xl),
                    children: [for (final (g, item) in results) SettingTile(item: item, caption: g.title(l10n))],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final SettingsGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navo = context.navo;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: navo.accent.withValues(alpha: 0.14), borderRadius: navo.radius(Radii.sm)),
        child: Icon(group.icon, color: navo.accent, size: 22),
      ),
      title: Text(group.title(l10n), style: context.text.bodyLarge),
      subtitle: group.subtitle == null
          ? null
          : Text(group.subtitle!(l10n), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right_rounded, color: navo.textSecondary),
      onTap: () => context.pushPage<void>((_) => SettingsGroupScreen(id: group.id)),
    );
  }
}

/// One group's settings, with a reset action.
class SettingsGroupScreen extends ConsumerWidget {
  const SettingsGroupScreen({super.key, required this.id});

  final SettingsGroupId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final group = groupById(id);
    final reset = group.reset;
    return Scaffold(
      appBar: AppBar(
        title: Text(group.title(l10n)),
        actions: [
          if (reset != null)
            IconButton(
              tooltip: l10n.resetGroup,
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () async {
                final ok = await confirmReset(
                  context,
                  title: l10n.resetGroupTitle(group.title(l10n)),
                  message: l10n.resetGroupMessage,
                );
                if (!ok) return;
                ref.read(settingsProvider.notifier).update(reset);
                if (context.mounted) context.showSnack(l10n.settingsRestored);
              },
            ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final s = ref.watch(settingsProvider);
          final basic = sectionItems(group.items, advanced: false, isVisible: (i) => i.isVisible(s, ref));
          final advanced = sectionItems(group.items, advanced: true, isVisible: (i) => i.isVisible(s, ref));
          return ListView(
            padding: EdgeInsets.only(bottom: Insets.xxl + MediaQuery.paddingOf(context).bottom),
            children: [
              for (final item in basic) SettingTile(item: item),
              if (advanced.isNotEmpty) _AdvancedSection(items: advanced),
            ],
          );
        },
      ),
    );
  }
}

/// The basic or advanced items of a group, keeping only headers that have
/// at least one visible item under them.
@visibleForTesting
List<SettingItem> sectionItems(
  List<SettingItem> items, {
  required bool advanced,
  required bool Function(SettingItem item) isVisible,
}) {
  final out = <SettingItem>[];
  HeaderItem? pending;
  for (final item in items) {
    if (item is HeaderItem) {
      pending = item;
    } else if (item.advanced == advanced && isVisible(item)) {
      if (pending != null) out.add(pending);
      pending = null;
      out.add(item);
    }
  }
  return out;
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({required this.items});

  final List<SettingItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navo = context.navo;
    final count = items.where((i) => i is! HeaderItem).length;
    return Padding(
      padding: const EdgeInsets.only(top: Insets.md),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: Insets.page),
        leading: Icon(Icons.tune_rounded, color: navo.accent),
        title: Text(l10n.advancedSettings, style: context.text.bodyLarge),
        subtitle: Text(l10n.advancedSettingsCount(count)),
        children: [for (final item in items) SettingTile(item: item)],
      ),
    );
  }
}
