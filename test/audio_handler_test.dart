import 'package:audio_service/audio_service.dart';
import 'package:feruzbek/features/library/data/models.dart';
import 'package:feruzbek/features/player/data/navo_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_player.dart';

Track _t(String k) => Track(key: k, title: k, uri: 'file:///$k.mp3', duration: const Duration(minutes: 3));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePlayer player;
  late NavoAudioHandler handler;

  setUp(() {
    player = FakePlayer();
    handler = NavoAudioHandler(artworkUriFor: (_) async => null, player: player);
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));
  String? currentKey() => handler.queueView.current?.key;

  group('empty queue', () {
    test('transport calls are no-ops', () async {
      await handler.play();
      await handler.skipToNext();
      await handler.skipToPrevious();
      await handler.skipToQueueItem(3);
      await handler.removeAt(0);
      await handler.playFromView(2);
      await settle();
      expect(handler.queueView.tracks, isEmpty);
      expect(player.calls, isNot(contains('play')));
    });

    test('playTracks with an empty list does nothing', () async {
      await handler.playTracks(const []);
      expect(player.calls, isEmpty);
    });
  });

  group('single song', () {
    test('next stays, previous restarts', () async {
      await handler.playTracks([_t('a')]);
      await settle();
      await handler.skipToNext();
      expect(currentKey(), 'a');
      await handler.skipToPrevious();
      expect(player.calls.last, 'seek:0:null');
    });

    test('removing the only song stops playback', () async {
      await handler.playTracks([_t('a')]);
      await handler.removeAt(0);
      await settle();
      expect(handler.queueView.tracks, isEmpty);
      expect(handler.mediaItem.value, isNull);
      expect(player.calls, contains('stop'));
    });
  });

  group('next / previous', () {
    test('stops at the last item with repeat off', () async {
      await handler.playTracks([_t('a'), _t('b')], startIndex: 1);
      await settle();
      await handler.skipToNext();
      expect(currentKey(), 'b');
    });

    test('wraps around with repeat all', () async {
      await handler.playTracks([_t('a'), _t('b')], startIndex: 1);
      await handler.setRepeatMode(AudioServiceRepeatMode.all);
      await handler.skipToNext();
      await settle();
      expect(currentKey(), 'a');
    });

    test('repeat one replays the same track on completion', () async {
      await handler.playTracks([_t('a'), _t('b')]);
      await handler.setRepeatMode(AudioServiceRepeatMode.one);
      player.finishTrack();
      await settle();
      expect(currentKey(), 'a');
    });

    test('media item follows the current track', () async {
      await handler.playTracks([_t('a'), _t('b'), _t('c')]);
      await settle();
      expect(handler.mediaItem.value?.id, 'a');
      await handler.skipToNext();
      await settle();
      expect(handler.mediaItem.value?.id, 'b');
      expect(handler.playbackState.value.controls, contains(MediaControl.stop));
    });
  });

  group('shuffle', () {
    test('shuffled view follows the shuffle order', () async {
      await handler.playTracks([_t('a'), _t('b'), _t('c')], shuffle: true);
      await settle();
      expect(handler.queueView.tracks.map((t) => t.key), ['c', 'b', 'a']);
      expect(currentKey(), 'c');
    });

    test('turning shuffle off restores natural order', () async {
      await handler.playTracks([_t('a'), _t('b'), _t('c')], shuffle: true);
      await handler.setShuffleMode(AudioServiceShuffleMode.none);
      await settle();
      expect(handler.queueView.tracks.map((t) => t.key), ['a', 'b', 'c']);
    });
  });

  group('rapid actions', () {
    test('overlapping playTracks calls end on the latest request', () async {
      final first = handler.playTracks([_t('a'), _t('b')]);
      final second = handler.playTracks([_t('x'), _t('y'), _t('z')], startIndex: 2);
      await Future.wait([first, second]);
      await settle();
      expect(handler.queueView.tracks.map((t) => t.key), ['x', 'y', 'z']);
      expect(currentKey(), 'z');
      // The superseded request never reached the player.
      expect(player.calls.where((c) => c.startsWith('setAudioSources')).length, 1);
    });

    test('play next while the queue is changing keeps indices valid', () async {
      final f1 = handler.playTracks([_t('a'), _t('b')]);
      final f2 = handler.playNext(_t('n'));
      final f3 = handler.addToQueue(_t('z'));
      final f4 = handler.removeAt(1);
      await Future.wait([f1, f2, f3, f4]);
      await settle();
      expect(handler.queueView.tracks.map((t) => t.key), ['a', 'b', 'z']);
      expect(currentKey(), 'a');
    });
  });

  group('unplayable files', () {
    test('skips a file that fails to open and reports it', () async {
      player.failingUris.add('file:///a.mp3');
      final failures = <PlaybackFailure>[];
      handler.failures.listen(failures.add);
      await handler.playTracks([_t('a'), _t('b')]);
      await settle();
      expect(currentKey(), 'b');
      expect(failures.single.track?.key, 'a');
      expect(player.playing, isTrue);
    });

    test('a decode error mid-playback skips to the next track', () async {
      await handler.playTracks([_t('a'), _t('b')]);
      await settle();
      player.failCurrent();
      await settle();
      expect(currentKey(), 'b');
    });

    test('gives up instead of looping when every file fails', () async {
      player.failingUris.addAll(['file:///a.mp3', 'file:///b.mp3']);
      await handler.playTracks([_t('a'), _t('b')]);
      await settle();
      expect(player.playing, isFalse);
    });
  });

  test('sleep timer end-of-track pauses on completion', () async {
    await handler.playTracks([_t('a'), _t('b')]);
    handler.pauseAtTrackEnd = true;
    player.finishTrack();
    await settle();
    expect(player.playing, isFalse);
    expect(handler.pauseAtTrackEnd, isFalse);
  });
}
