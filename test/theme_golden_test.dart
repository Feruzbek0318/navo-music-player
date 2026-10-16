import 'dart:io';

import 'package:feruzbek/core/theme/app_theme.dart';
import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:feruzbek/features/settings/ui/widgets/appearance_widgets.dart';
import 'package:feruzbek/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden images of the appearance preview in each theme variant.
/// Regenerate with: flutter test --update-goldens test/theme_golden_test.dart
void main() {
  setUpAll(() async {
    final loader = FontLoader('Urbanist');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final bytes = File('assets/fonts/Urbanist-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
    // Real icon glyphs instead of boxes (the font ships with the Flutter SDK).
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? '';
    final icons = File('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final bytes = icons.readAsBytesSync();
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
    }
  });

  final variants = <String, (Brightness, bool, bool)>{
    'light': (Brightness.light, false, false),
    'dark': (Brightness.dark, false, false),
    'amoled': (Brightness.dark, true, false),
    'dark_high_contrast': (Brightness.dark, false, true),
  };

  for (final MapEntry(key: name, value: (brightness, amoled, contrast)) in variants.entries) {
    testWidgets('appearance preview – $name', (tester) async {
      tester.view.physicalSize = const Size(400, 320) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      const locale = Locale('en');
      final theme = AppTheme.build(
        locale: locale,
        brightness: brightness,
        amoled: amoled,
        accent: const Color(0xFFFF9F1C),
        appearance: const AppearanceSettings(animations: AnimationLevel.off),
        highContrast: contrast,
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            theme: theme,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const Scaffold(body: Center(child: AppearancePreview())),
          ),
        ),
      );
      final element = tester.element(find.byType(AppearancePreview));
      await tester.runAsync(() => precacheImage(const AssetImage('assets/demo/tashkent_nights.jpg'), element));
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/appearance_$name.png'));
    });
  }
}
