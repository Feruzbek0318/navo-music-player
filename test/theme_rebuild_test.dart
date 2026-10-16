import 'package:feruzbek/core/theme/app_theme.dart';
import 'package:feruzbek/core/theme/navo_theme.dart';
import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: list items must pick up theme changes without being
/// recreated (item builders read the theme from a per-item context).
void main() {
  testWidgets('horizontal list items follow a light/dark switch', (tester) async {
    ThemeData theme(Brightness b) => AppTheme.build(
      locale: const Locale('en'),
      brightness: b,
      amoled: false,
      accent: const Color(0xFFFF9F1C),
      appearance: const AppearanceSettings(),
      highContrast: false,
    );
    Widget app(Brightness b) => MaterialApp(
      theme: theme(b),
      home: Scaffold(
        body: ListView.builder(
          itemCount: 1,
          itemBuilder: (_, _) => SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (_, i) => Builder(
                builder: (context) => Text('t$i', style: TextStyle(color: context.navo.textPrimary)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(Brightness.dark));
    await tester.pumpWidget(app(Brightness.light));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('t0')).style?.color,
      NavoTheme.build(
        brightness: Brightness.light,
        amoled: false,
        accent: const Color(0xFFFF9F1C),
        highContrast: false,
        appearance: const AppearanceSettings(),
      ).textPrimary,
    );
  });
}
