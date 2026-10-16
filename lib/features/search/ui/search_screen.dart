import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_helpers.dart';
import '../../library/ui/tabs/collections_tabs.dart';
import '../../library/ui/widgets/song_tile.dart';
import '../../player/ui/mini_player.dart';
import '../state/search_providers.dart';
import '../../../core/theme/navo_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _saveDebounce;

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    ref.read(searchQueryProvider.notifier).set(q);
    setState(() {});
    // Remember queries the user lingered on.
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1500), () => _remember(q));
  }

  void _remember(String q) {
    if (!mounted) return;
    if (!ref.read(searchResultsProvider).isEmpty) ref.read(recentSearchesProvider.notifier).add(q);
  }

  void _use(String q) {
    _controller
      ..text = q
      ..selection = TextSelection.collapsed(offset: q.length);
    _onChanged(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: Insets.page),
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: context.text.bodyMedium,
              cursorColor: context.navo.accent,
              onChanged: _onChanged,
              onSubmitted: (q) => ref.read(recentSearchesProvider.notifier).add(q),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: Insets.md),
                prefixIcon: Icon(Icons.search_rounded, color: context.navo.accent, size: 20),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearAll,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => _use(''),
                      ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: query.trim().isEmpty
            ? _RecentSearches(key: const ValueKey('recent'), onPick: _use)
            : _Results(key: const ValueKey('results'), query: query),
      ),
      bottomNavigationBar: const MiniPlayer(standalone: true),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider);
    final notifier = ref.read(recentSearchesProvider.notifier);
    if (recent.isEmpty) {
      return EmptyState(icon: Icons.manage_search_rounded, title: l10n.search, message: l10n.searchEmptyHint);
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.sm, Insets.xs),
          child: Row(
            children: [
              Expanded(child: Text(l10n.recentSearches, style: context.text.titleSmall)),
              TextButton(onPressed: notifier.clear, child: Text(l10n.clearAll)),
            ],
          ),
        ),
        const Divider(indent: Insets.page, endIndent: Insets.page),
        for (var i = 0; i < recent.length; i++)
          ListTile(
            dense: true,
            title: Text(recent[i], style: context.text.bodyMedium?.copyWith(color: context.navo.textSecondary)),
            onTap: () => onPick(recent[i]),
            trailing: IconButton(
              tooltip: l10n.delete,
              icon: Icon(Icons.close_rounded, size: 18, color: context.navo.textSecondary),
              onPressed: () => notifier.remove(recent[i]),
            ),
          ).staggered(i),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = ref.watch(searchResultsProvider);
    if (r.isEmpty) {
      return EmptyState(icon: Icons.search_off_rounded, title: l10n.noResults(query.trim()));
    }
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (r.artists.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(title: l10n.tabArtists)),
          SliverList.builder(
            itemCount: r.artists.length,
            itemBuilder: (_, i) => CollectionTile(collection: r.artists[i]),
          ),
        ],
        if (r.albums.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(title: l10n.tabAlbums)),
          SliverList.builder(
            itemCount: r.albums.length,
            itemBuilder: (_, i) => CollectionTile(collection: r.albums[i]),
          ),
        ],
        if (r.songs.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(title: l10n.tabSongs)),
          SliverList.builder(
            itemCount: r.songs.length,
            itemBuilder: (_, i) => SongTile(track: r.songs[i], queue: r.songs),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: Insets.xl)),
      ],
    );
  }
}
