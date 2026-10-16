import 'dart:math';

import 'package:just_audio/just_audio.dart';

/// Shuffle order that pushes recently played items to the end, so a new
/// shuffle doesn't open with songs you just heard. With an empty
/// [recentRank] it behaves like a plain random shuffle.
class SmartShuffleOrder extends ShuffleOrder {
  SmartShuffleOrder({required this.recentRank, Random? random}) : _random = random ?? Random();

  /// Returns how recently the item at a playlist index was played
  /// (0 = most recent) or null if not recent.
  final int? Function(int index) recentRank;
  final Random _random;

  @override
  final List<int> indices = [];

  @override
  void shuffle({int? initialIndex}) {
    final fresh = <int>[];
    final recent = <int>[];
    for (final i in indices) {
      if (i == initialIndex) continue;
      (recentRank(i) == null ? fresh : recent).add(i);
    }
    fresh.shuffle(_random);
    // Least recently played first among the recent ones.
    recent.sort((a, b) => recentRank(b)!.compareTo(recentRank(a)!));
    indices
      ..clear()
      ..addAll([?initialIndex, ...fresh, ...recent]);
  }

  @override
  void insert(int index, int count) {
    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= index) indices[i] += count;
    }
    // New items play right after the current position, like DefaultShuffleOrder.
    final added = List.generate(count, (i) => index + i);
    final insertAt = indices.isEmpty ? 0 : _random.nextInt(indices.length + 1);
    indices.insertAll(insertAt, added);
  }

  @override
  void removeRange(int start, int end) {
    final count = end - start;
    indices.removeWhere((i) => i >= start && i < end);
    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= end) indices[i] -= count;
    }
  }

  @override
  void clear() => indices.clear();
}
