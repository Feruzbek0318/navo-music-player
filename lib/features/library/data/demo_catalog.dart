import 'models.dart';

/// Original demo tracks bundled in `assets/demo/` (CC0, see LICENSE.txt there).
abstract final class DemoCatalog {
  static final DateTime _added = DateTime(2026, 10, 1);

  static Track _demo(
    String id,
    String title,
    String artist,
    String album,
    Duration duration,
    String genre, {
    required int size,
    bool lyrics = true,
    int day = 0,
  }) => Track(
    key: 'demo:$id',
    title: title,
    artist: artist,
    album: album,
    uri: 'asset:///assets/demo/$id.mp3',
    duration: duration,
    genre: genre,
    year: 2026,
    composer: 'Navo',
    dateAdded: _added.add(Duration(days: day)),
    dateModified: _added.add(Duration(days: day)),
    size: size,
    extension: 'mp3',
    assetArtwork: 'assets/demo/$id.jpg',
    assetLyrics: lyrics ? 'assets/demo/$id.lrc' : null,
  );

  static final tracks = <Track>[
    _demo(
      'tashkent_nights',
      'Tashkent Nights',
      'Navo Ensemble',
      'City Lights',
      const Duration(milliseconds: 78800),
      'Synthwave',
      size: 1262028,
      day: 3,
    ),
    _demo(
      'morning_chai',
      'Morning Chai',
      'Lola Beats',
      'Slow Mornings',
      const Duration(milliseconds: 75846),
      'Lo-fi',
      size: 1214791,
      day: 2,
    ),
    _demo(
      'silk_road_drift',
      'Silk Road Drift',
      'Navo Ensemble',
      'City Lights',
      const Duration(milliseconds: 70571),
      'Ambient',
      size: 1130369,
      lyrics: false,
      day: 1,
    ),
    _demo(
      'pixel_garden',
      'Pixel Garden',
      '8-Bit Bahor',
      'Pixel Garden',
      const Duration(milliseconds: 70571),
      'Chiptune',
      size: 1130366,
    ),
  ];
}
