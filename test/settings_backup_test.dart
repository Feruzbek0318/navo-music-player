import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:feruzbek/features/settings/state/backup_service.dart';
import 'package:feruzbek/features/settings/ui/settings_items.dart';
import 'package:feruzbek/features/settings/ui/settings_registry.dart';
import 'package:feruzbek/features/settings/ui/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavoBackup', () {
    test('round-trips settings and library data', () {
      final settings = const AppSettings().copyWith(
        notifications: const NotificationSettings(showFavoriteButton: false),
      );
      final backup = NavoBackup(
        settings: settings.toJson(),
        favorites: const ['a', 'b'],
        blocklist: const ['c'],
        playlists: const [
          {'id': 'p1', 'name': 'Mix', 'keys': ['a']},
        ],
      );
      final back = NavoBackup.decode(backup.encode());
      expect(back.favorites, ['a', 'b']);
      expect(back.blocklist, ['c']);
      expect(back.playlists.single['name'], 'Mix');
      expect(AppSettings.fromJson(migrateSettings(back.settings)).notifications.showFavoriteButton, isFalse);
    });

    test('rejects other files and newer versions', () {
      expect(() => NavoBackup.decode('{"hello": 1}'), throwsFormatException);
      expect(() => NavoBackup.decode('not json'), throwsFormatException);
      expect(() => NavoBackup.decode('{"format": "navo-backup", "version": 99}'), throwsFormatException);
    });
  });

  group('basic / advanced split', () {
    test('every item lands in exactly one section; empty headers dropped', () {
      for (final g in settingsGroups) {
        final basic = sectionItems(g.items, advanced: false, isVisible: (_) => true);
        final advanced = sectionItems(g.items, advanced: true, isVisible: (_) => true);
        final nonHeaders = g.items.where((i) => i is! HeaderItem).length;
        expect(
          basic.where((i) => i is! HeaderItem).length + advanced.where((i) => i is! HeaderItem).length,
          nonHeaders,
          reason: g.id.name,
        );
        for (final list in [basic, advanced]) {
          for (var i = 0; i < list.length; i++) {
            if (list[i] is HeaderItem) {
              expect(i + 1 < list.length && list[i + 1] is! HeaderItem, isTrue, reason: '${g.id.name} empty header');
            }
          }
        }
      }
    });

    test('playback keeps the essentials up front', () {
      final g = groupById(SettingsGroupId.playback);
      final basic = sectionItems(g.items, advanced: false, isVisible: (_) => true);
      expect(basic.length, lessThan(g.items.length));
      expect(basic.whereType<SliderItem>(), isNotEmpty); // crossfade
    });
  });
}
