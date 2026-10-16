import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';

/// Seconds listened per day (`yyyy-mm-dd`) and per track. Local only.
@immutable
class ListeningStats {
  const ListeningStats({this.byDay = const {}, this.byTrack = const {}});

  static const empty = ListeningStats();

  final Map<String, int> byDay;
  final Map<String, int> byTrack;

  int get totalSeconds => byDay.values.fold(0, (a, b) => a + b);
  bool get isEmpty => totalSeconds == 0;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Seconds for each of the 7 days ending [today] (oldest first).
  List<(DateTime, int)> lastSevenDays(DateTime today) => [
    for (var i = 6; i >= 0; i--)
      (DateTime(today.year, today.month, today.day - i), byDay[dayKey(DateTime(today.year, today.month, today.day - i))] ?? 0),
  ];

  ListeningStats add(String trackKey, int seconds, DateTime when) {
    if (seconds <= 0) return this;
    final day = dayKey(when);
    return ListeningStats(
      byDay: {...byDay, day: (byDay[day] ?? 0) + seconds},
      byTrack: {...byTrack, trackKey: (byTrack[trackKey] ?? 0) + seconds},
    );
  }
}

/// Turns position updates into listened time: only small forward steps on
/// the same track count (seeks, track changes and pauses don't).
class ListenAccumulator {
  String? _track;
  Duration? _last;
  double _pending = 0;

  /// Returns whole seconds to record (with their track) when enough has built up.
  (String, int)? onPosition(String trackKey, Duration position, {required bool playing}) {
    (String, int)? flush;
    if (trackKey != _track) {
      flush = _take();
      _track = trackKey;
      _last = position;
      return flush;
    }
    final last = _last;
    _last = position;
    if (!playing || last == null) return null;
    final delta = (position - last).inMilliseconds / 1000;
    if (delta > 0 && delta < 5) _pending += delta;
    if (_pending >= 10) return _take();
    return null;
  }

  /// Flushes what's left (e.g. on pause).
  (String, int)? flush() => _take();

  (String, int)? _take() {
    final t = _track;
    final s = _pending.floor();
    _pending -= s;
    return t == null || s <= 0 ? null : (t, s);
  }
}

class ListeningStatsRepository {
  ListeningStatsRepository(this._store);

  final LocalStore _store;

  static const _dayKey = 'stats_by_day';
  static const _trackKey = 'stats_by_track';

  ListeningStats load() => ListeningStats(byDay: _store.intMap(_dayKey), byTrack: _store.intMap(_trackKey));

  Future<void> save(ListeningStats s) async {
    await _store.putIntMap(_dayKey, s.byDay);
    await _store.putIntMap(_trackKey, s.byTrack);
  }
}
