import 'package:feruzbek/features/library/data/library_cache.dart';
import 'package:feruzbek/features/library/data/library_filter.dart';
import 'package:feruzbek/features/library/data/models.dart';
import 'package:feruzbek/features/library/data/sorting.dart';
import 'package:feruzbek/features/library/state/selection.dart';
import 'package:feruzbek/features/playlists/data/m3u.dart';
import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Track _t(
  String key, {
  String? artist,
  String? albumArtist,
  String? path,
  int seconds = 180,
  int size = 4000000,
  bool system = false,
  String title = 'Song',
}) => Track(
  key: key,
  title: title,
  artist: artist,
  albumArtist: albumArtist,
  path: path,
  uri: 'content://media/$key',
  duration: Duration(seconds: seconds),
  size: size,
  isSystemSound: system,
  mediaId: key.hashCode,
);

void main() {
  group('LibraryFilter', () {
    final music = _t('m', path: '/sdcard/Music/a.mp3');
    final ringtone = _t('r', path: '/sdcard/Ringtones/r.mp3', system: true);
    final short = _t('s', path: '/sdcard/Music/s.mp3', seconds: 5);
    final tiny = _t('t', path: '/sdcard/Music/t.mp3', size: 10 * 1024);
    final podcast = _t('p', path: '/sdcard/Podcasts/p.mp3');
    final all = [music, ringtone, short, tiny, podcast];

    test('defaults hide system sounds and very short files', () {
      final keys = LibraryFilter.apply(all, const LibrarySettings()).map((t) => t.key);
      expect(keys, ['m', 't', 'p']);
    });

    test('minimum size and duration', () {
      const s = LibrarySettings(minSizeKb: 100, minDurationSeconds: 0, hideShortSounds: false);
      expect(LibraryFilter.apply(all, s).map((t) => t.key), ['m', 'r', 's', 'p']);
    });

    test('excluded and "only these" folders', () {
      expect(LibraryFilter.apply(all, const LibrarySettings(excludedFolders: ['/sdcard/Podcasts'])).map((t) => t.key), [
        'm',
        't',
      ]);
      expect(LibraryFilter.apply(all, const LibrarySettings(includedFolders: ['/sdcard/Podcasts'])).map((t) => t.key), [
        'p',
      ]);
    });

    test('a folder prefix does not match a sibling with a longer name', () {
      final sibling = _t('x', path: '/sdcard/Music2/x.mp3');
      expect(LibraryFilter.accepts(sibling, const LibrarySettings(excludedFolders: ['/sdcard/Music'])), isTrue);
    });

    test('demo tracks are never filtered', () {
      const demo = Track(key: 'demo:a', title: 'A', uri: 'asset:///a.mp3', duration: Duration(seconds: 1));
      expect(LibraryFilter.accepts(demo, const LibrarySettings(minDurationSeconds: 600)), isTrue);
    });
  });

  group('artist splitting', () {
    List<String> split(String a) => _t('k', artist: a).artistNames(split: true);

    test('splits common separators', () {
      expect(split('Drake feat. Rihanna'), ['Drake', 'Rihanna']);
      expect(split('A ft. B'), ['A', 'B']);
      expect(split('A & B'), ['A', 'B']);
      expect(split('A; B;C'), ['A', 'B', 'C']);
      expect(split('A x B'), ['A', 'B']);
    });

    test('keeps names that only look like separators', () {
      expect(split('AC/DC'), ['AC/DC']);
      expect(split('Tyler, The Creator'), ['Tyler, The Creator']);
      expect(split('Malcolm X'), ['Malcolm X']);
    });

    test('grouping counts a song under every split artist', () {
      final tracks = [_t('1', artist: 'A feat. B'), _t('2', artist: 'B')];
      final artists = Grouping.artists(tracks, split: true);
      final b = artists.firstWhere((a) => a.name == 'B');
      expect(b.songCount, 2);
      expect(Grouping.artists(tracks).length, 2);
    });

    test('album-artist grouping and artist ids', () {
      final t = _t('1', artist: 'Guest feat. Star', albumArtist: 'Star');
      expect(Grouping.artistIdFor(t, byAlbumArtist: true), 'star');
      expect(Grouping.artistIdFor(t, split: true), 'guest');
      expect(Grouping.artists([t], byAlbumArtist: true).single.name, 'Star');
    });
  });

  group('LibraryCache', () {
    test('round-trips tracks', () {
      final tracks = [
        Track(
          key: 'd:1',
          mediaId: 1,
          title: 'One',
          artist: 'Artist',
          albumArtist: 'AA',
          album: 'Album',
          albumId: 9,
          uri: 'content://media/1',
          path: '/sdcard/Music/1.mp3',
          duration: const Duration(seconds: 61),
          year: 2020,
          dateAdded: DateTime.fromMillisecondsSinceEpoch(1000000),
          size: 123,
          extension: 'mp3',
          isSystemSound: true,
        ),
      ];
      final back = LibraryCache.decode(LibraryCache.encodeForTest(tracks))!;
      expect(back.single.toJson(), tracks.single.toJson());
    });

    test('ignores caches from another format version', () {
      expect(LibraryCache.decode('{"v": 999, "tracks": []}'), isNull);
    });
  });

  group('M3U', () {
    final a = _t('a', artist: 'Artist', title: 'Alpha', path: '/sdcard/Music/alpha.mp3');
    final b = _t('b', artist: 'Band', title: 'Beta', path: '/sdcard/Music/Sub/beta song.flac');
    final c = _t('c', title: 'Gamma', path: '/sdcard/Music/gamma.ogg');
    final library = [a, b, c];

    test('export then import gives the same order', () {
      final text = M3u.export([b, a]);
      expect(text, startsWith('#EXTM3U'));
      expect(text, contains('#EXTINF:180,Band - Beta'));
      expect(M3u.match(text, library).map((t) => t.key), ['b', 'a']);
    });

    test('matches by file name when paths differ and by EXTINF title', () {
      const text =
          '\uFEFF#EXTM3U\n'
          'D:\\Music\\beta%20song.flac\n'
          '#EXTINF:200,Unknown - Gamma\n'
          'missing/file.mp3\n'
          '#EXTINF:100,Artist - Alpha\n'
          'also-missing.mp3\n'
          'nothing.mp3\n';
      expect(M3u.match(text, library).map((t) => t.key), ['b', 'a']);
    });

    test('skips duplicates and comments', () {
      const text = '#EXTM3U\n# a comment\n/sdcard/Music/alpha.mp3\n/sdcard/Music/alpha.mp3\n';
      expect(M3u.match(text, library).map((t) => t.key), ['a']);
    });
  });

  group('selection', () {
    test('start, toggle, select all and clear', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(selectionProvider.notifier);
      final scope = [_t('1'), _t('2'), _t('3')];
      n.start(scope[1], scope);
      expect(c.read(selectionProvider).active, isTrue);
      n.toggle(scope[0]);
      expect(c.read(selectionProvider).tracks.map((t) => t.key), ['1', '2']);
      n.toggle(scope[1]);
      expect(c.read(selectionProvider).selected, {'1'});
      n.selectAll();
      expect(c.read(selectionProvider).selected.length, 3);
      n.clear();
      expect(c.read(selectionProvider).active, isFalse);
    });
  });
}
