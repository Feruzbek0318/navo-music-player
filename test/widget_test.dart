import 'package:feruzbek/core/utils/formatters.dart';
import 'package:feruzbek/features/settings/state/settings_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDuration', () {
    test('formats minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 3, seconds: 50)), '03:50');
    });
    test('includes hours when needed', () {
      expect(formatDuration(const Duration(hours: 1, minutes: 25, seconds: 43)), '1:25:43');
    });
  });

  group('resolveLocale', () {
    test('uses the explicit selection', () {
      expect(resolveLocale(const Locale('ru'), const [Locale('en')]), const Locale('ru'));
    });
    test('follows the device language when supported', () {
      expect(resolveLocale(null, const [Locale('uz', 'UZ')]), const Locale('uz'));
    });
    test('falls back to English', () {
      expect(resolveLocale(null, const [Locale('de')]), const Locale('en'));
    });
  });
}
