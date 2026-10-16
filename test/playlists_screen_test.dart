import 'dart:io';

import 'package:feruzbek/core/storage/local_store.dart';
import 'package:feruzbek/core/theme/app_theme.dart';
import 'package:feruzbek/features/playlists/data/playlist_repository.dart';
import 'package:feruzbek/features/playlists/state/playlist_providers.dart';
import 'package:feruzbek/features/playlists/ui/playlists_screen.dart';
import 'package:feruzbek/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// Keeps playlists in memory so the widget test does no file I/O.
class _MemoryPlaylists implements PlaylistRepository {
  List<Playlist> _items = const [];

  @override
  List<Playlist> load() => _items;

  @override
  Future<void> save(List<Playlist> playlists) async => _items = playlists;
}

void main() {
  late Directory dir;
  late LocalStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('navo_test');
    store = await LocalStore.openAt(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<ProviderContainer> pump(WidgetTester tester, Locale locale) async {
    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        playlistRepositoryProvider.overrideWithValue(_MemoryPlaylists()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(playlistsProvider.notifier).create('Kechki');
    await container.read(playlistsProvider.notifier).create('Yoʻl uchun');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.dark(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const PlaylistsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  for (final code in ['uz', 'ru', 'en']) {
    testWidgets('lists playlists without layout errors ($code)', (tester) async {
      await pump(tester, Locale(code));
      expect(find.text('Kechki'), findsOneWidget);
      expect(find.text('Yoʻl uchun'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reorders playlists by dragging the handle', (tester) async {
    final container = await pump(tester, const Locale('en'));
    final handle = find.byIcon(Icons.drag_handle_rounded).first;
    final drag = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 6; i++) {
      await drag.moveBy(const Offset(0, 25));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await drag.up();
    await tester.pumpAndSettle();
    expect(container.read(playlistsProvider).map((p) => p.name), ['Yoʻl uchun', 'Kechki']);
  });
}
