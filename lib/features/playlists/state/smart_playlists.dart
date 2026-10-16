import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../library/data/models.dart';
import '../../library/data/sorting.dart';
import '../../library/state/library_providers.dart';

enum SmartPlaylist { recentlyAdded, mostPlayed, neverPlayed, favorites, lastPlayed }

extension SmartPlaylistInfo on SmartPlaylist {
  String title(AppLocalizations l) => switch (this) {
    SmartPlaylist.recentlyAdded => l.recentlyAdded,
    SmartPlaylist.mostPlayed => l.mostPlayed,
    SmartPlaylist.neverPlayed => l.neverPlayed,
    SmartPlaylist.favorites => l.favorites,
    SmartPlaylist.lastPlayed => l.recentlyPlayed,
  };

  IconData get icon => switch (this) {
    SmartPlaylist.recentlyAdded => Icons.new_releases_outlined,
    SmartPlaylist.mostPlayed => Icons.trending_up_rounded,
    SmartPlaylist.neverPlayed => Icons.explore_outlined,
    SmartPlaylist.favorites => Icons.favorite_rounded,
    SmartPlaylist.lastPlayed => Icons.history_rounded,
  };
}

const _limit = 100;

/// Songs for a smart playlist, always computed from the current library.
final smartPlaylistTracksProvider = Provider.family<List<Track>, SmartPlaylist>((ref, p) {
  final library = ref.watch(libraryTracksProvider).value ?? const <Track>[];
  switch (p) {
    case SmartPlaylist.recentlyAdded:
      return sortTracks(library, SortOption.dateAdded).take(_limit).toList();
    case SmartPlaylist.mostPlayed:
      final counts = ref.watch(historyProvider).counts;
      final played = library.where((t) => (counts[t.key] ?? 0) > 0).toList()
        ..sort((a, b) => counts[b.key]!.compareTo(counts[a.key]!));
      return played.take(_limit).toList();
    case SmartPlaylist.neverPlayed:
      final counts = ref.watch(historyProvider).counts;
      return library.where((t) => (counts[t.key] ?? 0) == 0).toList();
    case SmartPlaylist.favorites:
      return ref.watch(favoriteTracksProvider);
    case SmartPlaylist.lastPlayed:
      return ref.watch(recentlyPlayedProvider);
  }
});
