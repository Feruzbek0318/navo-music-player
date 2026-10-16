import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../favorites/ui/favorites_screen.dart';
import '../library/state/library_providers.dart';
import '../library/ui/home_screen.dart';
import '../library/ui/widgets/selection_bar.dart';
import '../player/data/navo_audio_handler.dart';
import '../player/state/playback_setup.dart';
import '../player/state/player_providers.dart';
import '../player/ui/mini_player.dart';
import '../playlists/ui/playlists_screen.dart';
import '../settings/state/settings_providers.dart';
import '../settings/ui/settings_screen.dart';
import 'app_bottom_nav.dart';
import '../../core/theme/navo_theme.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  NavTab? _current;
  final _subs = <StreamSubscription<Object?>>[];
  bool _setupDone = false;

  static const _pages = {
    NavTab.home: HomeScreen(),
    NavTab.favorites: FavoritesScreen(),
    NavTab.playlists: PlaylistsScreen(),
    NavTab.settings: SettingsScreen(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final handler = ref.read(audioHandlerProvider);
    _subs
      ..add(handler.failures.listen(_onFailure))
      ..add(handler.trackStarted.listen((_) => _firstPlaybackSetup()));
  }

  void _onFailure(PlaybackFailure f) {
    if (!mounted) return;
    final l10n = context.l10n;
    context.showSnack(f.track == null ? l10n.cannotPlayUnknown : l10n.cannotPlayFile(f.track!.title));
  }

  /// Asks for notification access and, on aggressive OEMs, shows a battery
  /// hint, the first time something plays in this session.
  Future<void> _firstPlaybackSetup() async {
    if (_setupDone) return;
    _setupDone = true;
    final setup = ref.read(playbackSetupProvider);
    final access = await setup.ensureNotifications();
    if (!mounted) return;
    final l10n = context.l10n;
    if (access != NotificationAccess.granted) {
      context.showSnack(l10n.notificationsDeniedMessage, actionLabel: l10n.openSettings, onAction: openAppSettings);
      return;
    }
    if (!await setup.shouldShowBatteryHint() || !mounted) return;
    await setup.markBatteryHintShown();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        icon: Icon(Icons.battery_saver_rounded, color: context.navo.accent),
        title: Text(l10n.backgroundPlayback),
        content: Text(l10n.backgroundPlaybackHint),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.later)),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              setup.openBatterySettings();
            },
            child: Text(l10n.batterySettings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have granted access in system settings.
    if (state == AppLifecycleState.resumed) ref.read(libraryPermissionProvider.notifier).recheck();
  }

  @override
  Widget build(BuildContext context) {
    // A shake extended the sleep timer: confirm it.
    ref.listen<int>(sleepTimerProvider.select((t) => t.extensions), (prev, next) {
      if (next > (prev ?? 0)) {
        if (ref.read(gestureSettingsProvider).haptics) HapticFeedback.mediumImpact();
        context.showSnack(context.l10n.sleepExtended);
      }
    });

    final appearance = ref.watch(appearanceProvider);
    final tabs = appearance.visibleNavTabs;
    final start = tabs.contains(appearance.startTab) ? appearance.startTab : tabs.first;
    // A tab hidden while selected falls back to the start tab.
    final current = _current != null && tabs.contains(_current) ? _current! : start;

    return PopScope(
      canPop: current == start,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _current = start);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: NavTab.values.indexOf(current),
                children: [
                  for (final t in NavTab.values)
                    TickerMode(
                      enabled: t == current,
                      child: AnimatedOpacity(
                        opacity: t == current ? 1 : 0,
                        duration: AppDurations.medium,
                        curve: AppCurves.standard,
                        child: _pages[t]!,
                      ),
                    ),
                ],
              ),
            ),
            const SelectionBar(),
            const MiniPlayer(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          tabs: tabs,
          current: current,
          showLabels: appearance.showNavLabels,
          onChanged: (t) => setState(() => _current = t),
        ),
      ),
    );
  }
}
