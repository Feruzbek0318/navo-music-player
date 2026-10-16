import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// In-memory stand-in for [AudioPlayer] that models the playlist, current
/// index, loop and shuffle behaviour the handler relies on.
class FakePlayer implements AudioPlayer {
  final List<AudioSource> _sources = [];
  int? _index;
  bool _playing = false;
  LoopMode _loop = LoopMode.off;
  bool _shuffle = false;
  List<int> _shuffleIndices = [];
  Duration _position = Duration.zero;
  ProcessingState _state = ProcessingState.idle;

  /// URIs (by `toString()`) that fail to load, like an unreadable file.
  final Set<String> failingUris = {};
  final List<String> calls = [];
  double lastVolume = 1;
  Duration? lastInitialPosition;
  double lastPitch = 1;
  bool skipSilence = false;
  final _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);

  /// Simulates playback reaching [d].
  void emitPosition(Duration d) {
    _position = d;
    _positionSubject.add(d);
  }

  final _events = BehaviorSubject<PlaybackEvent>.seeded(PlaybackEvent());
  final _playingSubject = BehaviorSubject<bool>.seeded(false);
  final _loopSubject = BehaviorSubject<LoopMode>.seeded(LoopMode.off);
  final _shuffleSubject = BehaviorSubject<bool>.seeded(false);
  final _sequence = BehaviorSubject<SequenceState>();
  final _discontinuity = StreamController<PositionDiscontinuity>.broadcast();

  List<IndexedAudioSource> get _indexed => _sources.cast<IndexedAudioSource>();

  void _emit() {
    _sequence.add(
      SequenceState(
        sequence: _indexed,
        currentIndex: _index,
        shuffleIndices: _shuffleIndices,
        shuffleModeEnabled: _shuffle,
        loopMode: _loop,
      ),
    );
    _events.add(PlaybackEvent(processingState: _state, currentIndex: _index));
  }

  String _uriOf(AudioSource s) => s is UriAudioSource ? s.uri.toString() : '';

  List<int> get _order => _shuffle ? _shuffleIndices : List.generate(_sources.length, (i) => i);

  /// Simulates the current track reaching its end.
  void finishTrack() {
    final prev = _events.value;
    if (_loop == LoopMode.one) {
      _position = Duration.zero;
    } else if (hasNext) {
      _index = nextIndex;
    } else {
      _playing = false;
      _state = ProcessingState.completed;
    }
    _emit();
    _discontinuity.add(PositionDiscontinuity(PositionDiscontinuityReason.autoAdvance, prev, _events.value));
  }

  /// Simulates a decoding error on the current item.
  void failCurrent() => _events.addError(PlayerException(0, 'decode error', _index));

  // --- state -----------------------------------------------------------------

  @override
  bool get playing => _playing;
  @override
  ProcessingState get processingState => _state;
  @override
  Duration get position => _position;
  @override
  Duration get bufferedPosition => Duration.zero;
  @override
  Duration? get duration => const Duration(minutes: 3);
  @override
  double get speed => 1;
  @override
  double get volume => 1;
  @override
  LoopMode get loopMode => _loop;
  @override
  bool get shuffleModeEnabled => _shuffle;
  @override
  int? get currentIndex => _index;
  @override
  List<int> get effectiveIndices => _order;
  @override
  PlaybackEvent get playbackEvent => _events.value;

  @override
  int? get nextIndex {
    final i = _index;
    if (i == null) return null;
    final pos = _order.indexOf(i);
    if (pos + 1 < _order.length) return _order[pos + 1];
    return _loop == LoopMode.all && _order.isNotEmpty ? _order.first : null;
  }

  @override
  int? get previousIndex {
    final i = _index;
    if (i == null) return null;
    final pos = _order.indexOf(i);
    if (pos > 0) return _order[pos - 1];
    return _loop == LoopMode.all && _order.isNotEmpty ? _order.last : null;
  }

  @override
  bool get hasNext => nextIndex != null;
  @override
  bool get hasPrevious => previousIndex != null;

  // --- streams ---------------------------------------------------------------

  @override
  Stream<PlaybackEvent> get playbackEventStream => _events.stream;
  @override
  Stream<bool> get playingStream => _playingSubject.stream;
  @override
  Stream<LoopMode> get loopModeStream => _loopSubject.stream;
  @override
  Stream<bool> get shuffleModeEnabledStream => _shuffleSubject.stream;
  @override
  Stream<SequenceState> get sequenceStateStream => _sequence.stream;
  @override
  Stream<PositionDiscontinuity> get positionDiscontinuityStream => _discontinuity.stream;
  @override
  Stream<Duration> get positionStream => _positionSubject.stream;
  @override
  Stream<double> get pitchStream => Stream.value(lastPitch);
  @override
  Stream<double> get speedStream => Stream.value(1);
  @override
  Stream<double> get volumeStream => Stream.value(1);

  // --- commands --------------------------------------------------------------

  @override
  Future<Duration?> setAudioSources(
    List<AudioSource> sources, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
    ShuffleOrder? shuffleOrder,
  }) async {
    calls.add('setAudioSources:$initialIndex');
    lastInitialPosition = initialPosition;
    final start = initialIndex ?? 0;
    if (sources.isNotEmpty && failingUris.contains(_uriOf(sources[start]))) {
      _sources.clear();
      _index = null;
      _state = ProcessingState.idle;
      _emit();
      throw PlayerException(0, 'cannot open', start);
    }
    _sources
      ..clear()
      ..addAll(sources);
    _shuffleIndices = List.generate(sources.length, (i) => i);
    _index = sources.isEmpty ? null : start;
    _position = Duration.zero;
    _state = ProcessingState.ready;
    _emit();
    return const Duration(minutes: 3);
  }

  @override
  Future<void> play() async {
    calls.add('play');
    _playing = true;
    _playingSubject.add(true);
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    _playing = false;
    _playingSubject.add(false);
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _playing = false;
    _state = ProcessingState.idle;
    _playingSubject.add(false);
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    calls.add('seek:${position?.inSeconds}:$index');
    if (index != null && index >= 0 && index < _sources.length) _index = index;
    _position = position ?? Duration.zero;
    _positionSubject.add(_position);
    _emit();
  }

  @override
  Future<void> seekToNext() async {
    if (hasNext) await seek(Duration.zero, index: nextIndex);
  }

  @override
  Future<void> seekToPrevious() async {
    if (hasPrevious) await seek(Duration.zero, index: previousIndex);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _loop = mode;
    _loopSubject.add(mode);
    _emit();
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    _shuffle = enabled;
    _shuffleSubject.add(enabled);
    _emit();
  }

  @override
  Future<void> shuffle() async {
    // Deterministic "shuffle": reverse order.
    _shuffleIndices = List.generate(_sources.length, (i) => _sources.length - 1 - i);
    _emit();
  }

  @override
  Future<void> insertAudioSource(int index, AudioSource audioSource) async {
    _sources.insert(index, audioSource);
    if (_index != null && index <= _index!) _index = _index! + 1;
    _shuffleIndices = List.generate(_sources.length, (i) => i);
    _emit();
  }

  @override
  Future<void> addAudioSource(AudioSource audioSource) async {
    _sources.add(audioSource);
    _shuffleIndices = List.generate(_sources.length, (i) => i);
    _emit();
  }

  @override
  Future<void> removeAudioSourceAt(int index) async {
    _sources.removeAt(index);
    if (_index != null) {
      if (index < _index!) {
        _index = _index! - 1;
      } else if (index == _index) {
        _index = _sources.isEmpty ? null : _index!.clamp(0, _sources.length - 1);
      }
    }
    _shuffleIndices = List.generate(_sources.length, (i) => i);
    _emit();
  }

  @override
  Future<void> moveAudioSource(int currentIndex, int newIndex) async {
    final s = _sources.removeAt(currentIndex);
    _sources.insert(newIndex, s);
    _emit();
  }

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setVolume(double volume) async => lastVolume = volume;

  @override
  Future<void> setPitch(double pitch) async => lastPitch = pitch;

  @override
  Future<void> setSkipSilenceEnabled(bool enabled) async => skipSilence = enabled;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
