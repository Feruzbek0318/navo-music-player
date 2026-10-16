import '../../library/data/models.dart';

/// Pure bookkeeping for the playing queue, mirrored 1:1 with the player's
/// playlist. Keeps the "current index" consistent when items are inserted,
/// removed or moved, so the handler never indexes out of range.
class QueueBook {
  final List<Track> _tracks = [];
  int? _current;

  List<Track> get tracks => List.unmodifiable(_tracks);
  int get length => _tracks.length;
  bool get isEmpty => _tracks.isEmpty;
  int? get currentIndex => _current;
  Track? get current => _valid(_current) ? _tracks[_current!] : null;

  bool _valid(int? i) => i != null && i >= 0 && i < _tracks.length;

  Track? at(int index) => _valid(index) ? _tracks[index] : null;

  void replace(List<Track> tracks) {
    _tracks
      ..clear()
      ..addAll(tracks);
    _current = null;
  }

  void clear() => replace(const []);

  /// Records the player's current index. Returns true if it changed to a
  /// valid new item.
  bool setCurrent(int? index) {
    if (!_valid(index) || index == _current) return false;
    _current = index;
    return true;
  }

  /// Forgets the current item so the next [setCurrent] reports a change.
  void resetCurrent() => _current = null;

  /// Index where "play next" inserts.
  int get nextInsertIndex => _valid(_current) ? _current! + 1 : _tracks.length;

  void insert(int index, Track track) {
    final i = index.clamp(0, _tracks.length);
    _tracks.insert(i, track);
    if (_current != null && i <= _current!) _current = _current! + 1;
  }

  void add(Track track) => _tracks.add(track);

  /// Returns false if [index] is out of range.
  bool removeAt(int index) {
    if (!_valid(index)) return false;
    _tracks.removeAt(index);
    final c = _current;
    if (c != null) {
      if (index < c) {
        _current = c - 1;
      } else if (index == c) {
        // The player moves to the item that slid into this slot (or none).
        _current = _tracks.isEmpty ? null : c.clamp(0, _tracks.length - 1);
      }
    }
    return true;
  }

  /// Returns false if either index is out of range.
  bool move(int from, int to) {
    if (!_valid(from) || !_valid(to) || from == to) return false;
    final t = _tracks.removeAt(from);
    _tracks.insert(to, t);
    final c = _current;
    if (c == null) return true;
    if (c == from) {
      _current = to;
    } else if (from < c && to >= c) {
      _current = c - 1;
    } else if (from > c && to <= c) {
      _current = c + 1;
    }
    return true;
  }

  /// Indices of items whose key is in [keys], highest first (safe to remove in order).
  List<int> indicesOf(Set<String> keys) => [
    for (var i = _tracks.length - 1; i >= 0; i--)
      if (keys.contains(_tracks[i].key)) i,
  ];

  /// Playback order for the queue view: [order] (shuffle indices) filtered to
  /// valid entries, or natural order.
  List<int> playbackOrder(List<int>? order) {
    if (order == null) return List.generate(_tracks.length, (i) => i);
    return [
      for (final i in order)
        if (_valid(i)) i,
    ];
  }
}
