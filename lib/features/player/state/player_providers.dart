import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/platform/shake_detector.dart';

import '../../library/data/models.dart';
import '../../library/state/library_providers.dart';
import '../../settings/state/settings_providers.dart';
import '../data/lyrics_repository.dart';
import '../data/replay_gain.dart';
import 'media_browser.dart';
import '../data/navo_audio_handler.dart';

/// Overridden in `main()` with the instance returned by `AudioService.init`.
final audioHandlerProvider = Provider<NavoAudioHandler>(
  (ref) => throw UnimplementedError('audioHandlerProvider must be overridden'),
);

final queueViewProvider = StreamProvider<QueueView>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queueViewStream;
});

final currentTrackProvider = Provider<Track?>((ref) => ref.watch(queueViewProvider).value?.current);

final playbackStateProvider = StreamProvider<PlaybackState>((ref) => ref.watch(audioHandlerProvider).playbackState);

final isPlayingProvider = Provider<bool>((ref) => ref.watch(playbackStateProvider).value?.playing ?? false);

final repeatModeProvider = Provider<AudioServiceRepeatMode>(
  (ref) => ref.watch(playbackStateProvider).value?.repeatMode ?? AudioServiceRepeatMode.none,
);

final shuffleEnabledProvider = Provider<bool>(
  (ref) => ref.watch(playbackStateProvider).value?.shuffleMode == AudioServiceShuffleMode.all,
);

final positionProvider = StreamProvider<Duration>((ref) => ref.watch(audioHandlerProvider).positionStream);

final speedProvider = StreamProvider<double>((ref) => ref.watch(audioHandlerProvider).speedStream);

final volumeProvider = StreamProvider<double>((ref) => ref.watch(audioHandlerProvider).volumeStream);

final pitchProvider = StreamProvider<double>((ref) => ref.watch(audioHandlerProvider).pitchStream);

final abRepeatProvider = StreamProvider<AbRepeat>((ref) => ref.watch(audioHandlerProvider).abStream);

final replayGainRepositoryProvider = Provider<ReplayGainRepository>((ref) => ReplayGainRepository());

/// True when [key] is the current track and playback is running.
final isTrackPlayingProvider = Provider.family<bool, String>((ref, key) {
  return ref.watch(currentTrackProvider)?.key == key && ref.watch(isPlayingProvider);
});

final isCurrentTrackProvider = Provider.family<bool, String>((ref, key) => ref.watch(currentTrackProvider)?.key == key);

final _widgetStateProvider = Provider<(Track?, bool)>(
  (ref) => (ref.watch(currentTrackProvider), ref.watch(isPlayingProvider)),
);

/// All player actions the UI can trigger. Also keeps the audio handler in
/// sync with settings (behaviour, effects, normalisation) and persists the
/// queue.
class PlayerController {
  PlayerController(this._ref) {
    final handler = _ref.read(audioHandlerProvider);
    _subs.add(handler.trackStarted.listen((t) => _ref.read(historyProvider.notifier).record(t.key)));

    final settings = _ref.read(settingsProvider);
    _applySettings(null, settings);
    _ref.listen<AppSettings>(settingsProvider, _applySettings);

    final replayGain = _ref.read(replayGainRepositoryProvider);
    handler.replayGainFor = (t) async =>
        _ref.read(playbackSettingsProvider).normalizeVolume ? replayGain.factorFor(t) : null;
    handler.recentRankFor = (key) {
      final i = _ref.read(historyProvider).recent.take(30).toList().indexOf(key);
      return i < 0 ? null : i;
    };
    handler.isFavorite = (t) => _ref.read(favoritesProvider).contains(t.key);
    handler.onToggleFavorite = (t) => _ref.read(favoritesProvider.notifier).toggle(t.key);
    _ref.listen<List<String>>(favoritesProvider, (_, _) => handler.refreshControls());
    handler.onSnapshot = _saveSnapshot;
    handler.browser = NavoMediaBrowser(_ref);

    if (settings.playback.rememberQueue) unawaited(_restoreQueue(autoPlay: settings.playback.autoPlayOnStart));

    // Keep the home-screen widget in sync with what's playing.
    _ref.listen<(Track?, bool)>(
      _widgetStateProvider,
      (_, next) => unawaited(_updateWidget(next.$1, next.$2)),
      fireImmediately: true,
    );
  }

  Future<void> _updateWidget(Track? track, bool playing) async {
    final bridge = _ref.read(deviceBridgeProvider);
    if (!bridge.isAndroid) return;
    String? art;
    if (track != null) {
      try {
        art = (await _ref.read(musicRepositoryProvider).artworkFileUri(track))?.toFilePath();
      } catch (_) {}
    }
    await bridge.updateWidget(
      title: track?.title ?? 'Navo',
      artist: track?.artist ?? '',
      playing: playing,
      artPath: art,
    );
  }

  void _applySettings(AppSettings? prev, AppSettings next) {
    final h = _ref.read(audioHandlerProvider);
    if (prev == null || prev.playback != next.playback || prev.notifications != next.notifications) {
      h.applyConfig(PlaybackConfig.fromSettings(next));
    }
    final p = next.playback;
    if (prev == null || prev.playback.speed != p.speed) h.setSpeed(p.speed);
    if (prev == null || prev.playback.pitch != p.pitch) h.setPitch(p.pitch);
    if (prev == null || prev.playback.volume != p.volume) h.setVolume(p.volume);
    if (prev == null || prev.audio != next.audio) h.effects?.apply(next.audio);
  }

  void _saveSnapshot(QueueSnapshot s) {
    if (!_ref.read(playbackSettingsProvider).rememberQueue) return;
    _ref.read(userDataRepositoryProvider).saveQueue(s.keys, s.index, s.position.inMilliseconds);
  }

  Future<void> _restoreQueue({required bool autoPlay}) async {
    final (keys, index, positionMs) = _ref.read(userDataRepositoryProvider).savedQueue();
    if (keys.isEmpty) return;
    try {
      final known = await _ref.read(knownTracksProvider.future);
      final byKey = {for (final t in known) t.key: t};
      final tracks = [for (final k in keys) ?byKey[k]];
      if (tracks.isEmpty || _h.queueTracks.isNotEmpty) return;
      // Keep the saved current track if it still exists.
      final currentKey = index < keys.length ? keys[index] : null;
      final start = tracks.indexWhere((t) => t.key == currentKey);
      await _h.restore(
        tracks,
        index: start < 0 ? 0 : start,
        position: start < 0 ? Duration.zero : Duration(milliseconds: positionMs),
        play: autoPlay,
      );
    } catch (e) {
      debugPrint('Queue restore failed: $e');
    }
  }

  final Ref _ref;
  final _subs = <StreamSubscription<Object?>>[];

  NavoAudioHandler get _h => _ref.read(audioHandlerProvider);

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) => _h.playTracks(tracks, startIndex: startIndex);

  Future<void> shuffleAll(List<Track> tracks) => _h.playTracks(tracks, shuffle: true);

  /// Plays [track] from [context], or toggles playback if it is current.
  Future<void> playOrToggle(Track track, List<Track> context) async {
    if (_ref.read(currentTrackProvider)?.key == track.key) return togglePlay();
    final index = context.indexOf(track);
    return index < 0 ? _h.playTracks([track]) : _h.playTracks(context, startIndex: index);
  }

  Future<void> togglePlay() => _ref.read(isPlayingProvider) ? _h.pause() : _h.play();
  Future<void> next() => _h.skipToNext();
  Future<void> previous() => _h.skipToPrevious();
  Future<void> seek(Duration d) => _h.seek(d);
  Future<void> forward10() => _h.fastForward();
  Future<void> rewind10() => _h.rewind();

  Future<void> playNext(Track t) => _h.playNext(t);
  Future<void> addToQueue(Track t) => _h.addToQueue(t);
  Future<void> removeFromQueue(int sourceIndex) => _h.removeAt(sourceIndex);
  Future<void> moveInQueue(int from, int to) => _h.moveInView(from, to);
  Future<void> playFromQueue(int position) => _h.playFromView(position);
  Future<void> dropFromQueue(Set<String> keys) => _h.removeKeys(keys);

  Future<void> cycleRepeat() {
    final next = switch (_ref.read(repeatModeProvider)) {
      AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
      AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
    };
    return _h.setRepeatMode(next);
  }

  Future<void> toggleShuffle() =>
      _h.setShuffleMode(_ref.read(shuffleEnabledProvider) ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all);

  /// Speed and pitch are settings; the settings listener applies them.
  void setSpeed(double speed) => _ref.read(settingsProvider.notifier).playback((p) => p.copyWith(speed: speed));

  void setPitch(double pitch) => _ref.read(settingsProvider.notifier).playback((p) => p.copyWith(pitch: pitch));

  void toggleAb() => _h.toggleAbPoint();
  void clearAb() => _h.clearAb();

  Future<void> clearUpcoming() => _h.clearUpcoming();

  /// Re-inserts a removed queue item (undo).
  Future<void> undoRemove(int sourceIndex, Track track) => _h.insertAt(sourceIndex, track);

  List<Track> get queueTracks => _h.queueTracks;

  /// Adds songs using the user's default (play next or end of queue).
  Future<void> enqueue(List<Track> tracks) async {
    if (_ref.read(playbackSettingsProvider).addMode == AddMode.playNext) {
      for (final t in tracks.reversed) {
        await _h.playNext(t);
      }
    } else {
      for (final t in tracks) {
        await _h.addToQueue(t);
      }
    }
  }

  Future<void> setVolume(double volume) => _h.setVolume(volume);

  void persistVolume(double volume) => _ref.read(settingsProvider.notifier).playback((p) => p.copyWith(volume: volume));

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }
}

final playerControllerProvider = Provider<PlayerController>((ref) {
  final c = PlayerController(ref);
  ref.onDispose(c.dispose);
  return c;
});

// ---------------------------------------------------------------------------
// Sleep timer
// ---------------------------------------------------------------------------

@immutable
class SleepTimerState {
  const SleepTimerState({this.endsAt, this.endOfTrack = false, this.extensions = 0});

  static const off = SleepTimerState();

  final DateTime? endsAt;
  final bool endOfTrack;

  /// Incremented each time a shake extends the timer (drives a snackbar).
  final int extensions;

  bool get isActive => endsAt != null || endOfTrack;
}

class SleepTimerNotifier extends Notifier<SleepTimerState> {
  static const shakeExtension = Duration(minutes: 10);

  Timer? _timer;
  ShakeDetector? _shake;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _shake?.stop();
    });
    return SleepTimerState.off;
  }

  void start(Duration duration, {int extensions = 0}) {
    _cancelInternal();
    final endsAt = DateTime.now().add(duration);
    _timer = Timer(duration, () async {
      _stopShake();
      state = SleepTimerState.off;
      final fade = ref.read(playbackSettingsProvider).sleepFadeOut;
      await ref.read(audioHandlerProvider).fadeOutAndPause(duration: fade ? const Duration(seconds: 6) : Duration.zero);
    });
    state = SleepTimerState(endsAt: endsAt, extensions: extensions);
    final p = ref.read(playbackSettingsProvider);
    if (p.shakeToExtendSleep) {
      _shake = ShakeDetector(sensitivity: ref.read(gestureSettingsProvider).shakeSensitivity, onShake: _extend)
        ..start();
    }
  }

  void _extend() {
    final endsAt = state.endsAt;
    if (endsAt == null) return;
    final remaining = endsAt.difference(DateTime.now());
    start(remaining + shakeExtension, extensions: state.extensions + 1);
  }

  void endOfTrack() {
    _cancelInternal();
    ref.read(audioHandlerProvider).pauseAtTrackEnd = true;
    state = const SleepTimerState(endOfTrack: true);
    // Clear the indicator once the handler has consumed the flag.
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!ref.read(audioHandlerProvider).pauseAtTrackEnd) {
        t.cancel();
        state = SleepTimerState.off;
      }
    });
  }

  void cancel() {
    _cancelInternal();
    state = SleepTimerState.off;
  }

  void _stopShake() {
    _shake?.stop();
    _shake = null;
  }

  void _cancelInternal() {
    _timer?.cancel();
    _timer = null;
    _stopShake();
    ref.read(audioHandlerProvider).pauseAtTrackEnd = false;
  }
}

final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, SleepTimerState>(SleepTimerNotifier.new);

/// Ticks every second while a timed sleep timer is running.
final sleepRemainingProvider = StreamProvider<Duration?>((ref) {
  final endsAt = ref.watch(sleepTimerProvider).endsAt;
  if (endsAt == null) return Stream.value(null);
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => endsAt.difference(DateTime.now()),
  ).map((d) => d.isNegative ? Duration.zero : d);
});

// ---------------------------------------------------------------------------
// Lyrics
// ---------------------------------------------------------------------------

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) => LyricsRepository());

final lyricsProvider = FutureProvider.family<Lyrics?, Track>(
  (ref, track) => ref.read(lyricsRepositoryProvider).lyricsFor(track),
);
