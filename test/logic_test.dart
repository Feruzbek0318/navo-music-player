import 'package:feruzbek/features/library/data/demo_catalog.dart';
import 'package:feruzbek/features/library/data/models.dart';
import 'package:feruzbek/features/library/data/sorting.dart';
import 'package:feruzbek/features/player/data/lyrics_repository.dart';
import 'package:feruzbek/features/playlists/data/playlist_repository.dart';
import 'package:feruzbek/features/search/state/search_providers.dart';
import 'package:flutter_test/flutter_test.dart';

Track _t(String key, String title, {String? artist, String? album, int? year, DateTime? added}) => Track(
  key: key,
  title: title,
  artist: artist,
  album: album,
  year: year,
  dateAdded: added,
  uri: 'file:///$key.mp3',
  path: '/music/$artist/$key.mp3',
  duration: const Duration(minutes: 3),
);

void main() {
  group('parseLyrics', () {
    test('parses synced LRC, skips metadata and sorts lines', () {
      final l = parseLyrics('[ti:Song]\n[00:10.50]second\n[00:01.00]first\n[01:02.123]third')!;
      expect(l.isSynced, isTrue);
      expect(l.lines.map((e) => e.text), ['first', 'second', 'third']);
      expect(l.lines[1].time, const Duration(seconds: 10, milliseconds: 500));
      expect(l.lines[2].time, const Duration(minutes: 1, seconds: 2, milliseconds: 123));
    });

    test('expands lines with several timestamps', () {
      final l = parseLyrics('[00:01.00][00:05.00]chorus')!;
      expect(l.lines.length, 2);
      expect(l.lines.every((e) => e.text == 'chorus'), isTrue);
    });

    test('falls back to plain lyrics', () {
      final l = parseLyrics('line one\nline two')!;
      expect(l.isSynced, isFalse);
      expect(l.indexAt(const Duration(seconds: 3)), -1);
    });

    test('finds the active line', () {
      final l = parseLyrics('[00:01.00]a\n[00:05.00]b\n[00:09.00]c')!;
      expect(l.indexAt(Duration.zero), -1);
      expect(l.indexAt(const Duration(seconds: 6)), 1);
      expect(l.indexAt(const Duration(seconds: 30)), 2);
    });

    test('returns null for empty input', () => expect(parseLyrics('  \n'), isNull));
  });

  group('sorting', () {
    final tracks = [
      _t('1', 'beta', artist: 'Zed', album: 'B', year: 2020, added: DateTime(2024)),
      _t('2', 'Alpha', artist: 'Amy', album: 'C', year: 2022, added: DateTime(2023)),
      _t('3', 'gamma', album: 'A', added: DateTime(2025)),
    ];

    test('ascending / descending ignore case', () {
      expect(sortTracks(tracks, SortOption.ascending).map((t) => t.key), ['2', '1', '3']);
      expect(sortTracks(tracks, SortOption.descending).map((t) => t.key), ['3', '1', '2']);
    });

    test('unknown artist sorts last', () {
      expect(sortTracks(tracks, SortOption.artist).map((t) => t.key), ['2', '1', '3']);
    });

    test('newest first for date added and year', () {
      expect(sortTracks(tracks, SortOption.dateAdded).first.key, '3');
      expect(sortTracks(tracks, SortOption.year).first.key, '2');
    });

    test('every section offers ascending and descending', () {
      for (final s in LibrarySection.values) {
        expect(s.options, containsAll([SortOption.ascending, SortOption.descending]));
      }
    });
  });

  group('grouping', () {
    test('demo catalog groups into 3 albums, 3 artists and 1 folder', () {
      final tracks = DemoCatalog.tracks;
      expect(Grouping.albums(tracks).length, 3);
      expect(Grouping.artists(tracks).length, 3);
      final folders = Grouping.folders(tracks);
      expect(folders.single.id, Track.demoFolderPath);
      expect(folders.single.songCount, tracks.length);
    });

    test('album collection reports its artist and track count', () {
      final city = Grouping.albums(DemoCatalog.tracks).firstWhere((a) => a.name == 'City Lights');
      expect(city.subtitle, 'Navo Ensemble');
      expect(city.songCount, 2);
      expect(city.year, 2026);
    });
  });

  test('search normalisation folds Uzbek apostrophes and ё', () {
    expect(normalizeForSearch("Oʻzbek"), normalizeForSearch("o'zbek"));
    expect(normalizeForSearch('Ёлка'), 'елка');
  });

  test('playlist survives a storage round trip', () {
    final p = Playlist(id: 'x', name: 'Kechki', trackKeys: const ['a', 'b'], createdAt: DateTime(2026, 1, 2));
    final back = Playlist.fromMap(p.toMap());
    expect(back.name, 'Kechki');
    expect(back.trackKeys, ['a', 'b']);
    expect(back.createdAt, p.createdAt);
  });
}
