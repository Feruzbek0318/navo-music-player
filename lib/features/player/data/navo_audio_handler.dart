import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../library/data/models.dart';
import '../../settings/data/app_settings.dart';
import 'audio_effects.dart';
import 'queue_book.dart';
import 'smart_shuffle.dart';

/// Snapshot of the queue in playback order (respects shuffle).
@immutable
class QueueView {
  const QueueView({required this.tracks, required this.sourceIndices, required this.currentPosition});

  static const empty = QueueView(tracks: [], sourceIndices: [], currentPosition: -1);

  /// Tracks in the order they will play.
  final List<Track> tracks;

  /// For each entry in [tracks], its index in the underlying playlist.
  final List<int> sourceIndices;

  /// Index into [tracks] of the current item, or -1.
  final int currentPosition;

  Track? get current => currentPosition >= 0 && currentPosition < tracks.length ? tracks[currentPosition] : null;
}

/// A track that couldn't be played and was skipped.
@immutable
class PlaybackFailure {
  const PlaybackFailure(this.track, this.error);

  final Track? track;
  final Object error;
}

/// What to persist so the queue survives an app restart.
@immutable
class QueueSnapshot {
  const QueueSnapshot({required this.keys, required this.index, required this.position});

  final List<String> keys;
  final int index;
  final Duration position;
}

/// A–B repeat points; both null when off.
@immutable
class AbRepeat {
  const AbRepeat([this.a, this.b]);

  static const off = AbRepeat();

  final Duration? a;
  final Duration? b;

  bool get active => a != null && b != null;
}

/// Library access for Android Auto and other media browsers.
abstract interface class MediaBrowserSource {
  Future<List<MediaItem>> children(String parentId);

  /// The queue and start index for a playable media id.
  Future<(List<Track>, int)?> resolve(String mediaId);

  Future<List<MediaItem>> search(String query);
}

/// Behaviour the user can change in settings.
@immutable
class PlaybackConfig {
  const PlaybackConfig({
    this.crossfade = Duration.zero,
    this.fadeOnPlayPause = false,
    this.skipSilence = false,
    this.pauseOnDisconnect = true,
    this.resumeOnHeadset = false,
    this.resumeAfterCall = true,
    this.avoidRecentInShuffle = false,
    this.showCloseButton = true,
    this.showFavoriteButton = true,
    this.compactSkipButtons = true,
    this.showArtwork = true,
    this.singlePress = HeadsetAction.playPause,
    this.doublePress = HeadsetAction.next,
    this.triplePress = HeadsetAction.previous,
  });

  factory PlaybackConfig.fromSettings(AppSettings s) => PlaybackConfig(
    crossfade: Duration(seconds: s.playback.crossfadeSeconds),
    fadeOnPlayPause: s.playback.fadeOnPlayPause,
    skipSilence: s.playback.skipSilence,
    pauseOnDisconnect: s.playback.pauseOnDisconnect,
    resumeOnHeadset: s.playback.resumeOnHeadset,
    resumeAfterCall: s.playback.resumeAfterCall,
    avoidRecentInShuffle: s.playback.shuffleStyle == ShuffleStyle.avoidRecent,
    showCloseButton: s.notifications.showCloseButton,
    showFavoriteButton: s.notifications.showFavoriteButton,
    compactSkipButtons: s.notifications.compactSkipButtons,
    showArtwork: s.notifications.showArtwork,
    singlePress: s.notifications.singlePress,
    doublePress: s.notifications.doublePress,
    triplePress: s.notifications.triplePress,
  );

  final Duration crossfade;
  final bool fadeOnPlayPause;
  final bool skipSilence;
  final bool pauseOnDisconnect;
  final bool resumeOnHeadset;
  final bool resumeAfterCall;
  final bool avoidRecentInShuffle;
  final bool showCloseButton;
  final bool showFavoriteButton;
  final bool compactSkipButtons;
  final bool showArtwork;
  final HeadsetAction singlePress;
  final HeadsetAction doublePress;
  final HeadsetAction triplePress;
}

/// Bridges just_audio to audio_service so playback continues in the
/// background and shows lock-screen / notification controls.
///
/// Every queue mutation runs through [_serial], so rapid taps can't
/// interleave `setAudioSources` / insert / remove calls on the player.
/// Output volume is the product of the user volume, ReplayGain, ducking and
/// the fade envelope, applied in one place ([_applyVolume]).
class NavoAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  NavoAudioHandler({required this.artworkUriFor, AudioPlayer? player, this.effects})
    : _player = player ?? AudioPlayer(handleInterruptions: false, audioPipeline: effects?.pipeline) {
    _init();
  }

  /// Resolves a `file://` artwork URI for the notification.
  final Future<Uri?> Function(Track track) artworkUriFor;

  /// Equalizer / loudness (Android); null in tests.
  final AudioEffects? effects;

  /// Linear ReplayGain factor for a track (null = no normalisation).
  Future<double?> Function(Track track)? replayGainFor;

  /// How recently a key was played (0 = most recent), for smart shuffle.
  int? Function(String key)? recentRankFor;

  /// Called when the queue or position should be persisted.
  void Function(QueueSnapshot snapshot)? onSnapshot;

  /// Whether a track is a favourite (drives the notification heart).
  bool Function(Track track)? isFavorite;

  /// Toggles a favourite from the notification heart.
  Future<void> Function(Track track)? onToggleFavorite;

  /// Browse tree for Android Auto (set by the app).
  MediaBrowserSource? browser;

  final AudioPlayer _player;
  final _book = QueueBook();
  final _queueView = BehaviorSubject<QueueView>.seeded(QueueView.empty);
  final _trackStarted = StreamController<Track>.broadcast();
  final _failures = StreamController<PlaybackFailure>.broadcast();
  final _userVolume = BehaviorSubject<double>.seeded(1);
  final _ab = BehaviorSubject<AbRepeat>.seeded(AbRepeat.off);
  final _subs = <StreamSubscription<Object?>>[];

  Future<void> _tail = Future.value();
  int _loadGeneration = 0;
  int _consecutiveFailures = 0;
  PlaybackConfig _config = const PlaybackConfig();

  double _norm = 1;
  double _duck = 1;
  double _fade = 1;
  Timer? _ramp;
  bool _resumeAfterInterruption = false;
  bool _pausedByUnplug = false;
  int _presses = 0;
  Timer? _pressTimer;
  DateTime _lastSnapshot = DateTime.fromMillisecondsSinceEpoch(0);

  /// Sleep timer "end of current song": pause when the track finishes.
  bool pauseAtTrackEnd = false;

  Stream<QueueView> get queueViewStream => _queueView.stream;
  QueueView get queueView => _queueView.value;
  List<Track> get queueTracks => _book.tracks;

  /// Emits every time a new track starts playing (for listening history).
  Stream<Track> get trackStarted => _trackStarted.stream;

  /// Emits when a track fails to load or play.
  Stream<PlaybackFailure> get failures => _failures.stream;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<double> get pitchStream => _player.pitchStream;

  /// The volume the user chose (not including fades or normalisation).
  Stream<double> get volumeStream => _userVolume.stream;
  Stream<AbRepeat> get abStream => _ab.stream;
  AbRepeat get ab => _ab.value;
  PlaybackConfig get config => _config;

  Future<void> _init() async {
    // Subscribe synchronously so no early event is missed.
    _subs
      ..add(_player.playbackEventStream.listen(_broadcastState, onError: _onPlaybackError))
      ..add(
        _player.playingStream.listen((playing) {
          _broadcastState(_player.playbackEvent);
          if (!playing) _snapshot(force: true);
        }),
      )
      ..add(_player.loopModeStream.listen((_) => _broadcastState(_player.playbackEvent)))
      ..add(_player.shuffleModeEnabledStream.listen((_) => _broadcastState(_player.playbackEvent)))
      ..add(_player.sequenceStateStream.listen(_onSequenceState, onError: (Object _) {}))
      ..add(_player.positionStream.listen(_onPosition, onError: (Object _) {}))
      ..add(
        _player.positionDiscontinuityStream.listen((d) {
          if (d.reason != PositionDiscontinuityReason.autoAdvance) return;
          _consecutiveFailures = 0;
          if (pauseAtTrackEnd) {
            pauseAtTrackEnd = false;
            _guard(() async {
              await _player.pause();
              await _player.seek(Duration.zero);
            });
          }
        }),
      );

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _subs
        ..add(session.interruptionEventStream.listen(_onInterruption))
        ..add(session.becomingNoisyEventStream.listen((_) => _onUnplugged()))
        ..add(session.devicesChangedEventStream.listen(_onDevicesChanged));
    } catch (e) {
      debugPrint('Audio session setup failed: $e');
    }
  }

  /// Applies changed settings without interrupting playback.
  Future<void> applyConfig(PlaybackConfig c) async {
    final shuffleChanged = c.avoidRecentInShuffle != _config.avoidRecentInShuffle;
    _config = c;
    _broadcastState(_player.playbackEvent);
    await _guard(() => _player.setSkipSilenceEnabled(c.skipSilence));
    if (shuffleChanged) debugPrint('Shuffle style takes effect from the next queue.');
    final current = _book.current;
    if (current != null) unawaited(_publishMediaItem(current));
  }

  // ---------------------------------------------------------------------------
  // Serialisation and error handling
  // ---------------------------------------------------------------------------

  /// Runs [op] after every previously queued operation has finished.
  Future<T?> _serial<T>(Future<T> Function() op) {
    final completer = Completer<T?>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await op());
      } catch (e, st) {
        debugPrint('Player operation failed: $e\n$st');
        completer.complete(null);
      }
    });
    return completer.future;
  }

  /// Runs a player call, logging instead of throwing.
  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      debugPrint('Player call failed: $e');
    }
  }

  void _onPlaybackError(Object error, StackTrace st) {
    debugPrint('Playback error: $error');
    _failures.add(PlaybackFailure(_book.current, error));
    _consecutiveFailures++;
    // Skip the broken file, but give up once every item has failed in a row.
    if (_consecutiveFailures < _book.length && _player.hasNext) {
      _guard(() async {
        await _player.seekToNext();
        await _player.play();
      });
    } else {
      _guard(_player.pause);
    }
  }

  // ---------------------------------------------------------------------------
  // Volume: user × ReplayGain × ducking × fade
  // ---------------------------------------------------------------------------

  Future<void> _applyVolume() =>
      _guard(() => _player.setVolume((_userVolume.value * _norm * _duck * _fade).clamp(0.0, 1.0)));

  /// Animates the fade envelope to [target] over [duration].
  Future<void> _rampTo(double target, Duration duration) {
    _ramp?.cancel();
    if (duration <= Duration.zero) {
      _fade = target;
      return _applyVolume();
    }
    final done = Completer<void>();
    final start = _fade;
    final sw = Stopwatch()..start();
    _ramp = Timer.periodic(const Duration(milliseconds: 40), (t) {
      final p = (sw.elapsedMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      _fade = start + (target - start) * p;
      _applyVolume();
      if (p >= 1) {
        t.cancel();
        if (!done.isCompleted) done.complete();
      }
    });
    return done.future;
  }

  void _onPosition(Duration position) {
    // A–B repeat.
    final ab = _ab.value;
    if (ab.active && position >= ab.b!) {
      _guard(() => _player.seek(ab.a));
      return;
    }
    // Fade out before the end of the track when crossfade is on.
    final cf = _config.crossfade;
    final duration = _player.duration;
    if (cf > Duration.zero && duration != null && _player.playing && _ramp?.isActive != true) {
      final remaining = duration - position;
      final continues = _player.hasNext || _player.loopMode != LoopMode.off;
      if (continues && remaining <= cf && remaining > Duration.zero) {
        _fade = remaining.inMilliseconds / cf.inMilliseconds;
        _applyVolume();
      }
    }
    if (_player.playing) _snapshot();
  }

  // ---------------------------------------------------------------------------
  // Interruptions, unplugging and headset buttons
  // ---------------------------------------------------------------------------

  void _onInterruption(AudioInterruptionEvent e) {
    if (e.begin) {
      switch (e.type) {
        case AudioInterruptionType.duck:
          _duck = 0.3;
          _applyVolume();
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          _resumeAfterInterruption = _player.playing && _config.resumeAfterCall;
          if (_player.playing) _guard(_player.pause);
      }
    } else {
      switch (e.type) {
        case AudioInterruptionType.duck:
          _duck = 1;
          _applyVolume();
        case AudioInterruptionType.pause:
          if (_resumeAfterInterruption) play();
          _resumeAfterInterruption = false;
        case AudioInterruptionType.unknown:
          _resumeAfterInterruption = false;
      }
    }
  }

  void _onUnplugged() {
    if (!_config.pauseOnDisconnect || !_player.playing) return;
    _pausedByUnplug = true;
    _guard(_player.pause);
  }

  static bool _isHeadset(AudioDevice d) {
    final n = d.type.name.toLowerCase();
    return d.isOutput && (n.contains('headset') || n.contains('headphone') || n.contains('bluetooth'));
  }

  void _onDevicesChanged(AudioDevicesChangedEvent e) {
    if (_config.pauseOnDisconnect && e.devicesRemoved.any(_isHeadset)) _onUnplugged();
    if (_config.resumeOnHeadset && _pausedByUnplug && e.devicesAdded.any(_isHeadset)) {
      _pausedByUnplug = false;
      play();
    }
  }

  /// Single / double / triple presses of the headset button, mapped by the user.
  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    if (button != MediaButton.media) return super.click(button);
    _presses++;
    _pressTimer?.cancel();
    _pressTimer = Timer(const Duration(milliseconds: 450), () {
      final action = switch (_presses) {
        1 => _config.singlePress,
        2 => _config.doublePress,
        _ => _config.triplePress,
      };
      _presses = 0;
      switch (action) {
        case HeadsetAction.playPause:
          _player.playing ? pause() : play();
        case HeadsetAction.next:
          skipToNext();
        case HeadsetAction.previous:
          skipToPrevious();
        case HeadsetAction.none:
          break;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // State broadcasting
  // ---------------------------------------------------------------------------

  void _onSequenceState(SequenceState? state) {
    if (state == null) return;
    final order = _book.playbackOrder(state.shuffleModeEnabled ? state.shuffleIndices : null);
    final current = state.currentIndex;
    _queueView.add(
      QueueView(
        tracks: [for (final i in order) _book.at(i)!],
        sourceIndices: order,
        currentPosition: current == null ? -1 : order.indexOf(current),
      ),
    );

    // Ignore events from a playlist that has since been replaced: the
    // player's item must be the same track our book has at that index.
    final tag = state.currentSource?.tag;
    final matches = tag is MediaItem && current != null && _book.at(current)?.key == tag.id;
    if (matches && _book.setCurrent(current)) {
      final track = _book.current!;
      _publishMediaItem(track);
      _trackStarted.add(track);
      _onTrackChanged(track);
    }
  }

  void _onTrackChanged(Track track) {
    if (_ab.value != AbRepeat.off) _ab.add(AbRepeat.off);
    // Fade in after a crossfade-out.
    final cf = _config.crossfade;
    if (cf > Duration.zero && _fade < 1) unawaited(_rampTo(1, cf ~/ 2));
    unawaited(_updateNormalisation(track));
    _snapshot(force: true);
  }

  Future<void> _updateNormalisation(Track track) async {
    final lookup = replayGainFor;
    double next = 1;
    if (lookup != null) {
      try {
        next = await lookup(track) ?? 1;
      } catch (_) {}
    }
    if (_book.current?.key != track.key) return;
    _norm = next;
    await _applyVolume();
  }

  Future<void> _publishMediaItem(Track track) async {
    final item = _mediaItem(track);
    mediaItem.add(item);
    if (!_config.showArtwork) return;
    try {
      final art = await artworkUriFor(track);
      if (art != null && mediaItem.value?.id == track.key) {
        mediaItem.add(item.copyWith(artUri: art));
      }
    } catch (e) {
      debugPrint('Artwork for notification failed: $e');
    }
  }

  MediaItem _mediaItem(Track t) => MediaItem(
    id: t.key,
    title: t.title,
    artist: t.artist,
    album: t.album,
    duration: t.duration > Duration.zero ? t.duration : null,
    genre: t.genre,
  );

  AudioSource _source(Track t) {
    final tag = _mediaItem(t);
    if (t.uri.startsWith('asset:///')) {
      return AudioSource.asset(t.uri.replaceFirst('asset:///', ''), tag: tag);
    }
    return AudioSource.uri(Uri.parse(t.uri), tag: tag);
  }

  ShuffleOrder _shuffleOrder() => _config.avoidRecentInShuffle
      ? SmartShuffleOrder(
          recentRank: (i) {
            final t = _book.at(i);
            return t == null ? null : recentRankFor?.call(t.key);
          },
        )
      : DefaultShuffleOrder();

  void _syncQueue() {
    queue.add(_book.tracks.map(_mediaItem).toList());
    _snapshot(force: true);
  }

  void _snapshot({bool force = false}) {
    final cb = onSnapshot;
    if (cb == null) return;
    final now = DateTime.now();
    if (!force && now.difference(_lastSnapshot) < const Duration(seconds: 10)) return;
    _lastSnapshot = now;
    cb(
      QueueSnapshot(
        keys: [for (final t in _book.tracks) t.key],
        index: _book.currentIndex ?? 0,
        position: _player.position,
      ),
    );
  }

  static const _favoriteAction = 'favorite';

  /// Re-publishes controls, e.g. after the favourites list changed.
  void refreshControls() => _broadcastState(_player.playbackEvent);

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final c = _config;
    final track = _book.current;
    final controls = [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
      if (c.showFavoriteButton && track != null && isFavorite != null)
        isFavorite!(track)
            ? const MediaControl(
                androidIcon: 'drawable/ic_notif_favorite',
                label: 'Unfavorite',
                action: MediaAction.custom,
                customAction: CustomMediaAction(name: _favoriteAction),
              )
            : const MediaControl(
                androidIcon: 'drawable/ic_notif_favorite_border',
                label: 'Favorite',
                action: MediaAction.custom,
                customAction: CustomMediaAction(name: _favoriteAction),
              ),
      if (c.showCloseButton) MediaControl.stop,
    ];
    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: c.compactSkipButtons ? const [0, 1, 2] : const [1],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.all: AudioServiceRepeatMode.all,
          LoopMode.one: AudioServiceRepeatMode.one,
        }[_player.loopMode]!,
        shuffleMode: _player.shuffleModeEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Queue building
  // ---------------------------------------------------------------------------

  /// Replaces the queue with [tracks] and starts playing at [startIndex].
  /// A newer call supersedes one that is still waiting or loading.
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0, bool shuffle = false}) {
    if (tracks.isEmpty) return Future.value();
    final generation = ++_loadGeneration;
    return _serial(() => _load(tracks, startIndex, shuffle, generation));
  }

  /// Restores a saved queue without (necessarily) starting playback.
  Future<void> restore(List<Track> tracks, {required int index, Duration position = Duration.zero, bool play = false}) {
    if (tracks.isEmpty) return Future.value();
    final generation = ++_loadGeneration;
    return _serial(() => _load(tracks, index, false, generation, position: position, autoPlay: play));
  }

  Future<void> _load(
    List<Track> tracks,
    int startIndex,
    bool shuffle,
    int generation, {
    Duration position = Duration.zero,
    bool autoPlay = true,
  }) async {
    if (generation != _loadGeneration) return; // superseded while waiting
    _consecutiveFailures = 0;
    _book.replace(tracks);
    _syncQueue();
    var start = startIndex.clamp(0, tracks.length - 1);
    await _player.setShuffleModeEnabled(shuffle);
    // If the chosen file can't be opened, try the following ones.
    for (var attempt = 0; attempt < tracks.length; attempt++) {
      if (generation != _loadGeneration) return;
      try {
        await _player.setAudioSources(
          tracks.map(_source).toList(),
          initialIndex: shuffle ? null : start,
          initialPosition: attempt == 0 && !shuffle ? position : null,
          shuffleOrder: _shuffleOrder(),
        );
        if (shuffle) {
          await _player.shuffle();
          final first = _player.effectiveIndices.isNotEmpty ? _player.effectiveIndices.first : 0;
          await _player.seek(Duration.zero, index: first);
        }
        break;
      } on PlayerInterruptedException {
        return; // a newer load replaced this one
      } catch (e) {
        _failures.add(PlaybackFailure(tracks[start], e));
        if (attempt == tracks.length - 1) {
          _book.clear();
          _syncQueue();
          _queueView.add(QueueView.empty);
          return;
        }
        start = (start + 1) % tracks.length;
      }
    }
    if (generation == _loadGeneration && autoPlay) unawaited(play());
  }

  /// Inserts [track] right after the current one (or starts playing it).
  Future<void> playNext(Track track) => _serial(() async {
    if (_book.isEmpty) return _load([track], 0, false, ++_loadGeneration);
    final index = _book.nextInsertIndex;
    _book.insert(index, track);
    _syncQueue();
    await _player.insertAudioSource(index, _source(track));
  });

  Future<void> addToQueue(Track track) => _serial(() async {
    if (_book.isEmpty) return _load([track], 0, false, ++_loadGeneration);
    _book.add(track);
    _syncQueue();
    await _player.addAudioSource(_source(track));
  });

  /// Puts [track] back at playlist index [index] (undo of a removal).
  Future<void> insertAt(int index, Track track) => _serial(() async {
    if (_book.isEmpty) return _load([track], 0, false, ++_loadGeneration, autoPlay: false);
    final i = index.clamp(0, _book.length);
    _book.insert(i, track);
    _syncQueue();
    await _player.insertAudioSource(i, _source(track));
  });

  /// Removes the playlist item at [sourceIndex].
  Future<void> removeAt(int sourceIndex) => _serial(() => _removeAt(sourceIndex));

  Future<void> _removeAt(int sourceIndex) async {
    if (_book.at(sourceIndex) == null) return;
    if (_book.length == 1) return _stopInternal();
    final wasCurrent = sourceIndex == _book.currentIndex;
    _book.removeAt(sourceIndex);
    if (wasCurrent) _book.resetCurrent(); // announce the track that slides in
    _syncQueue();
    await _player.removeAudioSourceAt(sourceIndex);
  }

  /// Removes everything except the current track.
  Future<void> clearUpcoming() => _serial(() async {
    final current = _book.currentIndex;
    if (current == null) return;
    for (var i = _book.length - 1; i >= 0; i--) {
      if (i != _book.currentIndex) await _removeAt(i);
    }
  });

  /// Moves an item within the playback order shown in the queue view.
  Future<void> moveInView(int from, int to) => _serial(() async {
    if (_player.shuffleModeEnabled) {
      // Reordering a shuffled view would fight the shuffle order; turn it
      // off first so the list reflects what the user sees.
      await _player.setShuffleModeEnabled(false);
      return;
    }
    if (!_book.move(from, to)) return;
    _syncQueue();
    await _player.moveAudioSource(from, to);
  });

  /// Plays the item at [position] in the queue view.
  Future<void> playFromView(int position) => _serial(() async {
    final view = _queueView.value;
    if (position < 0 || position >= view.sourceIndices.length) return;
    await _player.seek(Duration.zero, index: view.sourceIndices[position]);
    if (!_player.playing) unawaited(play());
  });

  /// Drops [keys] from the queue (e.g. after blocking or deleting a song).
  Future<void> removeKeys(Set<String> keys) => _serial(() async {
    for (final i in _book.indicesOf(keys)) {
      await _removeAt(i);
    }
  });

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() => _guard(() async {
    if (_book.isEmpty) return;
    _pausedByUnplug = false;
    // Reload after a failed load (the player is idle with sources cleared).
    if (_player.processingState == ProcessingState.idle) {
      await _player.setAudioSources(
        _book.tracks.map(_source).toList(),
        initialIndex: _book.currentIndex ?? 0,
        shuffleOrder: _shuffleOrder(),
      );
    }
    if (_config.fadeOnPlayPause && !_player.playing) {
      _ramp?.cancel();
      _fade = 0;
      await _applyVolume();
      unawaited(_player.play());
      await _rampTo(1, const Duration(milliseconds: 350));
    } else {
      if (_fade < 1 && _ramp?.isActive != true) {
        _fade = 1;
        await _applyVolume();
      }
      await _player.play();
    }
  });

  @override
  Future<void> pause() => _guard(() async {
    if (_config.fadeOnPlayPause && _player.playing) {
      await _rampTo(0, const Duration(milliseconds: 250));
      await _player.pause();
      _fade = 1;
      await _applyVolume();
    } else {
      await _player.pause();
    }
  });

  @override
  Future<void> seek(Duration position) => _guard(() => _player.seek(position));

  @override
  Future<void> skipToNext() => _guard(() async {
    if (_player.hasNext) await _player.seekToNext();
  });

  /// Restarts the track if more than 3 s in, otherwise goes back one.
  @override
  Future<void> skipToPrevious() => _guard(() async {
    if (_player.position > const Duration(seconds: 3) || !_player.hasPrevious) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
  });

  @override
  Future<void> skipToQueueItem(int index) => _guard(() async {
    if (_book.at(index) == null) return;
    await _player.seek(Duration.zero, index: index);
  });

  @override
  Future<void> fastForward() => _seekBy(const Duration(seconds: 10));

  @override
  Future<void> rewind() => _seekBy(const Duration(seconds: -10));

  Future<void> _seekBy(Duration delta) => _guard(() async {
    final duration = _player.duration ?? Duration.zero;
    var target = _player.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    await _player.seek(target);
  });

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) => _guard(
    () => _player.setLoopMode(switch (repeatMode) {
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => LoopMode.all,
      AudioServiceRepeatMode.none => LoopMode.off,
    }),
  );

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) => _serial(() async {
    final enable = shuffleMode != AudioServiceShuffleMode.none;
    if (enable && !_book.isEmpty) await _player.shuffle();
    await _player.setShuffleModeEnabled(enable);
  });

  @override
  Future<void> setSpeed(double speed) => _guard(() => _player.setSpeed(speed.clamp(0.5, 2.0)));

  Future<void> setPitch(double pitch) => _guard(() => _player.setPitch(pitch.clamp(0.5, 2.0)));

  Future<void> setVolume(double volume) {
    _userVolume.add(volume.clamp(0, 1));
    return _applyVolume();
  }

  /// Sets A at the current position, then B; a third call clears.
  void toggleAbPoint() {
    final pos = _player.position;
    final ab = _ab.value;
    if (ab.a == null) {
      _ab.add(AbRepeat(pos));
    } else if (ab.b == null && pos > ab.a! + const Duration(milliseconds: 500)) {
      _ab.add(AbRepeat(ab.a, pos));
      _guard(() => _player.seek(ab.a));
    } else {
      _ab.add(AbRepeat.off);
    }
  }

  void clearAb() => _ab.add(AbRepeat.off);

  /// Lowers the volume over [duration] and pauses (sleep timer).
  Future<void> fadeOutAndPause({Duration duration = const Duration(seconds: 4)}) => _guard(() async {
    if (duration > Duration.zero) await _rampTo(0, duration);
    await _player.pause();
    _fade = 1;
    await _applyVolume();
  });

  @override
  Future<void> stop() => _serial(_stopInternal);

  Future<void> _stopInternal() async {
    _loadGeneration++;
    _ramp?.cancel();
    _fade = 1;
    await _guard(_player.stop);
    _book.clear();
    _syncQueue();
    _queueView.add(QueueView.empty);
    _ab.add(AbRepeat.off);
    mediaItem.add(null);
    await super.stop();
  }

  // ---------------------------------------------------------------------------
  // Media browsing (Android Auto)
  // ---------------------------------------------------------------------------

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    try {
      return await browser?.children(parentMediaId) ?? const [];
    } catch (e) {
      debugPrint('Browse failed: $e');
      return const [];
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    final resolved = await browser?.resolve(mediaId);
    if (resolved != null) await playTracks(resolved.$1, startIndex: resolved.$2);
  }

  @override
  Future<List<MediaItem>> search(String query, [Map<String, dynamic>? extras]) async =>
      await browser?.search(query) ?? const [];

  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) async {
    final results = await search(query);
    if (results.isNotEmpty) await playFromMediaId(results.first.id);
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name != _favoriteAction) return super.customAction(name, extras);
    final track = _book.current;
    if (track == null) return null;
    await onToggleFavorite?.call(track);
    refreshControls();
    return null;
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) await stop();
  }
}
