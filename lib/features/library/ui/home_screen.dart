import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../search/ui/search_screen.dart';
import '../../settings/state/settings_providers.dart';
import '../../settings/ui/settings_labels.dart';
import 'tabs/collections_tabs.dart';
import 'tabs/songs_tab.dart';
import 'tabs/suggested_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    final a = ref.read(appearanceProvider);
    _tabs = TabController(
      length: HomeTab.values.length,
      vsync: this,
      initialIndex: a.homeTabOrder.indexOf(a.startHomeTab).clamp(0, HomeTab.values.length - 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _open(List<HomeTab> order, HomeTab t) => _tabs.animateTo(order.indexOf(t), duration: AppDurations.medium);

  Widget _page(HomeTab t, List<HomeTab> order) => switch (t) {
    HomeTab.suggested => SuggestedTab(onOpenTab: (tab) => _open(order, tab)),
    HomeTab.songs => const SongsTab(),
    HomeTab.artists => const ArtistsTab(),
    HomeTab.albums => const AlbumsTab(),
    HomeTab.folders => const FoldersTab(),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = ref.watch(appearanceProvider.select((a) => a.homeTabOrder));
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Insets.page,
        title: const AppLogo(),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search_rounded, size: 26),
            onPressed: () => context.pushPage<void>((_) => const SearchScreen()),
          ),
          const SizedBox(width: Insets.sm),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
          labelPadding: const EdgeInsets.symmetric(horizontal: Insets.md),
          tabs: [for (final t in order) Tab(text: homeTabLabel(l10n, t))],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [for (final t in order) KeyedSubtree(key: ValueKey(t), child: _page(t, order))],
      ),
    );
  }
}
