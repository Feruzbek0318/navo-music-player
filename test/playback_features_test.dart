import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:feruzbek/core/platform/shake_detector.dart';
import 'package:feruzbek/features/library/data/models.dart';
import 'package:feruzbek/features/player/data/audio_effects.dart';
import 'package:feruzbek/features/player/data/navo_audio_handler.dart';
import 'package:feruzbek/features/player/data/replay_gain.dart';
import 'package:feruzbek/features/player/data/smart_shuffle.dart';
import 'package:feruzbek/features/settings/data/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_player.dart';

Track _t(String k) => Track(key: k, title: k, uri: 'file:///$k.mp3', duration: const Duration(minutes: 3));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePlayer player;
  late NavoAudioHandler handler;
  Future<void> settle([int ms = 30]) => Future<void>.delayed(Duration(milliseconds: ms));

  setUp(() {
    player = FakePlayer();
    handler = NavoAudioHandler(artworkUriFor: (_) async => null, player: player);
  });

  group('A–B repeat', () {
    test('sets A, then B, jumps back to A at B, then clears', () async {
      await handler.playTracks([_t('a')]);
      player.emitPosition(const Duration(seconds: 10));
      handler.toggleAbPoint();
      expect(handler.ab.a, const Duration(seconds: 10));
      player.emitPosition(const Duration(seconds: 20));
      handler.toggleAbPoint();
      expect(handler.ab.active, isTrue);
      player.emitPosition(const Duration(seconds: 21));
      await settle();
      expect(player.calls.last, 'seek:10:null');
      handler.toggleAbPoint();
      expect(handler.ab, AbRepeat.off);
    });

    test('B before A is ignored and a new track clears A–B', () async {
      await handler.playTracks([_t('a'), _t('b')]);
      player.emitPosition(const Duration(seconds: 30));
      handler.toggleAbPoint();
      player.emitPosition(const Duration(seconds: 5));
      handler.toggleAbPoint(); // B earlier than A → clears instead
      expect(handler.ab, AbRepeat.off);
      handler.toggleAbPoint();
      await handler.skipToNext();
      await settle();
      expect(handler.ab, AbRepeat.off);
    });
  });

  group('headset button', () {
    test('single, double and triple presses follow the mapping', () async {
      await handler.playTracks([_t('a'), _t('b'), _t('c')]);
      await handler.applyConfig(
        const PlaybackConfig(
          singlePress: HeadsetAction.playPause,
          doublePress: HeadsetAction.next,
          triplePress: HeadsetAction.previous,
        ),
      );
      await settle();
      expect(player.playing, isTrue);
      await handler.click();
      await settle(600);
      expect(player.playing, isFalse);

      await handler.click();
      await handler.click();
      await settle(600);
      expect(handler.queueView.current?.key, 'b');

      await handler.click();
      await handler.click();
      await handler.click();
      await settle(600);
      expect(handler.queueView.current?.key, 'a');
    });

    test('dedicated next/previous buttons are not remapped', () async {
      await handler.playTracks([_t('a'), _t('b')]);
      await handler.applyConfig(const PlaybackConfig(doublePress: HeadsetAction.none));
      await handler.click(MediaButton.next);
      await settle();
      expect(handler.queueView.current?.key, 'b');
    });
  });

  test('notification controls follow settings', () async {
    await handler.playTracks([_t('a')]);
    await handler.applyConfig(const PlaybackConfig(showCloseButton: false, compactSkipButtons: false));
    final s = handler.playbackState.value;
    expect(s.controls, isNot(contains(MediaControl.stop)));
    expect(s.androidCompactActionIndices, [1]);
    await handler.applyConfig(const PlaybackConfig());
    expect(handler.playbackState.value.controls, contains(MediaControl.stop));
    expect(handler.playbackState.value.androidCompactActionIndices, [0, 1, 2]);
  });

  test('restore loads the saved queue and position without playing', () async {
    await handler.restore([_t('a'), _t('b')], index: 1, position: const Duration(seconds: 42));
    await settle();
    expect(handler.queueView.current?.key, 'b');
    expect(player.lastInitialPosition, const Duration(seconds: 42));
    expect(player.playing, isFalse);
  });

  test('undo puts a removed track back in place', () async {
    await handler.playTracks([_t('a'), _t('b'), _t('c')]);
    await handler.removeAt(1);
    await handler.insertAt(1, _t('b'));
    await settle();
    expect(handler.queueView.tracks.map((t) => t.key), ['a', 'b', 'c']);
  });

  test('clear upcoming keeps only the current track', () async {
    await handler.playTracks([_t('a'), _t('b'), _t('c')], startIndex: 1);
    await handler.clearUpcoming();
    await settle();
    expect(handler.queueView.tracks.map((t) => t.key), ['b']);
  });

  test('snapshots report keys, index and position', () async {
    QueueSnapshot? last;
    handler.onSnapshot = (s) => last = s;
    await handler.playTracks([_t('a'), _t('b')], startIndex: 1);
    await settle();
    expect(last?.keys, ['a', 'b']);
    expect(last?.index, 1);
  });

  test('ReplayGain lowers loud tracks through the player volume', () async {
    handler.replayGainFor = (t) async => t.key == 'loud' ? 0.5 : null;
    await handler.setVolume(0.8);
    await handler.playTracks([_t('loud'), _t('quiet')]);
    await settle();
    expect(player.lastVolume, closeTo(0.4, 1e-9));
    await handler.skipToNext();
    await settle();
    expect(player.lastVolume, closeTo(0.8, 1e-9));
  });

  test('pitch and skip silence reach the player', () async {
    await handler.setPitch(1.2);
    await handler.applyConfig(const PlaybackConfig(skipSilence: true));
    expect(player.lastPitch, 1.2);
    expect(player.skipSilence, isTrue);
  });

  group('equalizer presets', () {
    test('interpolates between reference frequencies on a log scale', () {
      expect(EqPresets.gainAt([0, 10, 0, 0, 0], 230), 10);
      final mid = EqPresets.gainAt([0, 10, 0, 0, 0], sqrt(60 * 230));
      expect(mid, closeTo(5, 0.01));
      expect(EqPresets.gainAt([1, 2, 3, 4, 5], 20), 1);
      expect(EqPresets.gainAt([1, 2, 3, 4, 5], 20000), 5);
    });

    const bands = [
      EqBand(centerHz: 60, minDb: -15, maxDb: 15),
      EqBand(centerHz: 230, minDb: -15, maxDb: 15),
      EqBand(centerHz: 910, minDb: -15, maxDb: 15),
      EqBand(centerHz: 3600, minDb: -15, maxDb: 15),
      EqBand(centerHz: 14000, minDb: -15, maxDb: 15),
    ];

    test('built-in presets map onto device bands', () {
      final gains = AudioEffects.targetGains(const AudioSettings(eqEnabled: true, eqPreset: 'bass'), bands);
      expect(gains, [6, 4, 0, 0, 0]);
    });

    test('custom presets and manual bands are used per band', () {
      const s = AudioSettings(
        eqEnabled: true,
        eqPreset: 'Mine',
        customPresets: {
          'Mine': [1, 2, 3, 4, 5],
        },
      );
      expect(AudioEffects.targetGains(s, bands), [1, 2, 3, 4, 5]);
      const manual = AudioSettings(eqEnabled: true, eqPreset: 'custom', bandGains: [-3, 0, 3]);
      expect(AudioEffects.targetGains(manual, bands), [-3, 0, 3, 0, 0]);
    });

    test('bass boost lifts low bands even with the EQ off, and clamps', () {
      final gains = AudioEffects.targetGains(const AudioSettings(bassBoost: 1), bands);
      expect(gains[0], 8);
      expect(gains[2], 0);
      final clamped = AudioEffects.targetGains(
        const AudioSettings(eqEnabled: true, eqPreset: 'bass', bassBoost: 1),
        const [EqBand(centerHz: 60, minDb: -10, maxDb: 10)],
      );
      expect(clamped.single, 10);
    });
  });

  group('smart shuffle', () {
    test('puts recently played last and keeps a permutation', () {
      final recent = {0: 0, 1: 1}; // index → rank
      final order = SmartShuffleOrder(recentRank: (i) => recent[i], random: Random(1));
      order.insert(0, 6);
      order.shuffle(initialIndex: 3);
      expect(order.indices.first, 3);
      expect(order.indices.sublist(order.indices.length - 2), [1, 0]);
      expect(order.indices.toSet(), {0, 1, 2, 3, 4, 5});
    });

    test('insert and removeRange keep indices consistent', () {
      final order = SmartShuffleOrder(recentRank: (_) => null, random: Random(2))..insert(0, 4);
      order.shuffle();
      order.insert(2, 2);
      expect(order.indices.toSet(), {0, 1, 2, 3, 4, 5});
      order.removeRange(1, 3);
      expect(order.indices.toSet(), {0, 1, 2, 3});
    });
  });

  group('ReplayGain parsing', () {
    test('reads gains in common formats', () {
      expect(ReplayGainRepository.parseGain('-7.35 dB'), -7.35);
      expect(ReplayGainRepository.parseGain('+2,5 dB'), 2.5);
      expect(ReplayGainRepository.parseGain('nonsense'), isNull);
    });

    test('turns gains into a bounded volume factor', () {
      expect(ReplayGainRepository.factorForGain(-6), closeTo(1, 1e-9));
      expect(ReplayGainRepository.factorForGain(-12), closeTo(0.501, 0.001));
      expect(ReplayGainRepository.factorForGain(3), 1);
      expect(ReplayGainRepository.factorForGain(-40), 0.25);
    });
  });

  group('shake detector', () {
    test('two strong readings close together make one shake', () {
      var shakes = 0;
      final d = ShakeDetector(onShake: () => shakes++);
      final t0 = DateTime(2026);
      d.onReading(30, 0, 0, t0);
      d.onReading(30, 0, 0, t0.add(const Duration(milliseconds: 200)));
      expect(shakes, 1);
      // Cool-down.
      d.onReading(30, 0, 0, t0.add(const Duration(milliseconds: 400)));
      d.onReading(30, 0, 0, t0.add(const Duration(milliseconds: 500)));
      expect(shakes, 1);
    });

    test('weak movement and sensitivity', () {
      var shakes = 0;
      final d = ShakeDetector(onShake: () => shakes++, sensitivity: 0);
      final t0 = DateTime(2026);
      d.onReading(15, 0, 0, t0);
      d.onReading(15, 0, 0, t0.add(const Duration(milliseconds: 100)));
      expect(shakes, 0);
      expect(ShakeDetector.thresholdFor(1), lessThan(ShakeDetector.thresholdFor(0)));
    });
  });

  test('PlaybackConfig mirrors settings', () {
    const s = AppSettings(
      playback: PlaybackSettings(crossfadeSeconds: 5, shuffleStyle: ShuffleStyle.random),
      notifications: NotificationSettings(showCloseButton: false, triplePress: HeadsetAction.none),
    );
    final c = PlaybackConfig.fromSettings(s);
    expect(c.crossfade, const Duration(seconds: 5));
    expect(c.avoidRecentInShuffle, isFalse);
    expect(c.showCloseButton, isFalse);
    expect(c.triplePress, HeadsetAction.none);
  });
}
