import 'dart:ui';

import 'package:feruzbek/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Measures frame build/raster times while flinging through the Songs list.
/// Run on a device that has finished onboarding and has a large library:
///   flutter drive --profile --driver=test_driver/perf_driver.dart \
///     --target=integration_test/scroll_perf_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Songs list scrolls smoothly', (tester) async {
    app.main();
    // The app has endless animations (loader, equalizer), so pump for a
    // fixed time instead of waiting to settle.
    Future<void> wait(int ms) async {
      for (var t = 0; t < ms; t += 50) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 3)));
    await wait(3000);
    expect(find.byType(TabBar), findsOneWidget, reason: 'Finish onboarding on the device first');

    await tester.tap(find.byType(Tab).at(1));
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await wait(1500);

    final timings = <FrameTiming>[];
    void collect(List<FrameTiming> t) => timings.addAll(t);
    SchedulerBinding.instance.addTimingsCallback(collect);

    final list = find.byType(Scrollable).last;
    for (var i = 0; i < 6; i++) {
      await tester.fling(list, const Offset(0, -2500), 4000);
      await wait(1200);
    }
    for (var i = 0; i < 3; i++) {
      await tester.fling(list, const Offset(0, 2500), 4000);
      await wait(1200);
    }
    // Timings are delivered in batches; give the engine a moment.
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
    SchedulerBinding.instance.removeTimingsCallback(collect);

    double pct(List<double> v, double p) => v.isEmpty ? 0 : v[((v.length - 1) * p).round()];
    final build = timings.map((t) => t.buildDuration.inMicroseconds / 1000).toList()..sort();
    final raster = timings.map((t) => t.rasterDuration.inMicroseconds / 1000).toList()..sort();
    final summary = {
      'frames': timings.length,
      'build_p50_ms': pct(build, .5),
      'build_p90_ms': pct(build, .9),
      'build_p99_ms': pct(build, .99),
      'build_over_16ms': build.where((b) => b > 16.7).length,
      'raster_p50_ms': pct(raster, .5),
      'raster_p90_ms': pct(raster, .9),
    };
    binding.reportData = {'songs_scroll': summary};
    debugPrint('SCROLL_PERF $summary');
    expect(timings, isNotEmpty);
  });
}
