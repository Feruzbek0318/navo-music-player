import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:feruzbek/core/storage/local_store.dart';
import 'package:feruzbek/features/library/data/demo_catalog.dart';
import 'package:feruzbek/features/library/state/library_providers.dart';
import 'package:feruzbek/features/player/state/media_browser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// Android Auto browse tree built from the demo library.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late ProviderContainer c;
  late NavoMediaBrowser browser;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('navo_browse');
    final store = await LocalStore.openAt(dir.path);
    c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store), deviceTracksProvider.overrideWith(_NoDeviceTracks.new)],
    );
    final ref = c.read(_refProvider);
    browser = NavoMediaBrowser(ref);
  });

  tearDown(() async {
    c.dispose();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('root lists the browsable categories', () async {
    final root = await browser.children(AudioService.browsableRootId);
    expect(root.map((i) => i.id), [
      'cat:songs',
      'cat:favorites',
      'cat:recent',
      'cat:playlists',
      'cat:albums',
      'cat:artists',
    ]);
    expect(root.every((i) => i.playable == false), isTrue);
  });

  test('songs are playable and resolve to their list and index', () async {
    final songs = await browser.children('cat:songs');
    expect(songs, hasLength(DemoCatalog.tracks.length));
    expect(songs.every((i) => i.playable == true), isTrue);
    final resolved = await browser.resolve(songs[2].id);
    expect(resolved, isNotNull);
    expect(resolved!.$1[resolved.$2].title, songs[2].title);
  });

  test('albums and artists drill down to their songs', () async {
    final albums = await browser.children('cat:albums');
    final city = albums.firstWhere((a) => a.title == 'City Lights');
    final inAlbum = await browser.children(city.id);
    expect(inAlbum.map((s) => s.title).toSet(), {'Silk Road Drift', 'Tashkent Nights'});

    final artists = await browser.children('cat:artists');
    final ensemble = artists.firstWhere((a) => a.title == 'Navo Ensemble');
    expect(await browser.children(ensemble.id), hasLength(2));
  });

  test('search finds songs by title or artist; bad ids resolve to null', () async {
    expect((await browser.search('pixel')).single.title, 'Pixel Garden');
    expect(await browser.search('lola'), hasLength(1));
    expect(await browser.resolve('nonsense'), isNull);
    expect(await browser.resolve('play:songs|demo:missing'), isNull);
  });
}

/// Gives the browser a real [Ref] from the container.
final _refProvider = Provider<Ref>((ref) => ref);

class _NoDeviceTracks extends DeviceLibraryNotifier {
  @override
  Future<List<Never>> build() async => const [];
}
