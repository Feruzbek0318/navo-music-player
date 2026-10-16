import 'dart:io';

import 'package:feruzbek/core/storage/local_store.dart';
import 'package:feruzbek/core/theme/app_theme.dart';
import 'package:feruzbek/features/settings/data/settings_repository.dart';
import 'package:feruzbek/features/settings/state/settings_providers.dart';
import 'package:feruzbek/features/settings/ui/settings_items.dart';
import 'package:feruzbek/features/settings/ui/settings_registry.dart';
import 'package:feruzbek/features/settings/ui/settings_screen.dart';
import 'package:feruzbek/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// Keeps settings in memory so widget tests do no file I/O.
class _MemorySettings extends SettingsRepository {
  _MemorySettings(super.store);

  AppSettings value = const AppSettings();

  @override
  AppSettings load() => value;

  @override
  void save(AppSettings settings) => value = settings;

  @override
  Future<void> flush() async {}
}

void main() {
  late Directory dir;
  late LocalStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('navo_settings');
    store = await LocalStore.openAt(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<ProviderContainer> pump(WidgetTester tester, Widget home, {String code = 'en'}) async {
    tester.view.physicalSize = const Size(412, 915) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        settingsRepositoryProvider.overrideWithValue(_MemorySettings(store)),
      ],
    );
    addTearDown(container.dispose);
    final locale = Locale(code);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.dark(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: home,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    return container;
  }

  for (final code in ['uz', 'ru', 'en']) {
    testWidgets('settings home lists every group without layout errors ($code)', (tester) async {
      await pump(tester, const SettingsScreen(), code: code);
      expect(tester.takeException(), isNull);
      expect(find.byType(ListTile), findsWidgets);
    });

    for (final g in settingsGroups) {
      testWidgets('group ${g.id.name} renders ($code)', (tester) async {
        await pump(tester, SettingsGroupScreen(id: g.id), code: code);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('search finds settings across groups and filters the rest out', (tester) async {
    await pump(tester, const SettingsScreen());
    await tester.enterText(find.byType(TextField), 'contrast');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('High contrast'), findsOneWidget);
    expect(find.text('Appearance'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('No settings match'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1)); // let the empty-state animation finish
  });

  testWidgets('toggling a switch updates settings immediately', (tester) async {
    final c = await pump(tester, const SettingsGroupScreen(id: SettingsGroupId.accessibility));
    expect(c.read(settingsProvider).accessibility.highContrast, isFalse);
    await tester.tap(find.text('High contrast'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(c.read(settingsProvider).accessibility.highContrast, isTrue);
  });

  testWidgets('group reset asks first and restores defaults', (tester) async {
    final c = await pump(tester, const SettingsGroupScreen(id: SettingsGroupId.accessibility));
    c.read(settingsProvider.notifier).accessibility((a) => a.copyWith(highContrast: true));
    await tester.pump();
    await tester.tap(find.byTooltip('Reset to defaults'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(c.read(settingsProvider).accessibility.highContrast, isFalse);
  });

  testWidgets('every choice sheet opens and selecting an option applies it', (tester) async {
    final c = await pump(tester, const SettingsGroupScreen(id: SettingsGroupId.appearance));
    await tester.tap(find.text('Theme').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Light'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.read(settingsProvider).appearance.themeMode, AppThemeMode.light);

    // Open every choice sheet in every group: catches type errors like the
    // one that broke the theme sheet.
    for (final g in settingsGroups) {
      for (final item in g.items.whereType<ChoiceItem<dynamic>>()) {
        final l10n = lookupAppLocalizations(const Locale('en'));
        expect(item.labels(l10n), isNotEmpty);
        final s = c.read(settingsProvider);
        expect(item.selectedIndex(s), greaterThanOrEqualTo(0), reason: '${g.id.name}: ${item.title(l10n)}');
        expect(() => item.writeIndex(s, item.options.length - 1), returnsNormally);
      }
    }
  });

  test('every registry item has a unique, non-empty title per group', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    for (final g in settingsGroups) {
      final titles = g.items.whereType<SwitchItem>().map((i) => i.title(l10n)).toList();
      expect(titles.toSet().length, titles.length, reason: g.id.name);
      expect(titles.every((t) => t.isNotEmpty), isTrue);
    }
  });
}
