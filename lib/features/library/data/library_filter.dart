import '../../settings/data/app_settings.dart';
import 'models.dart';

/// Applies the library settings (folders, minimum duration and size, system
/// sounds) to scanned tracks. Demo tracks are never filtered.
abstract final class LibraryFilter {
  static bool _under(String path, String folder) {
    final f = folder.endsWith('/') ? folder : '$folder/';
    return path == folder || path.startsWith(f);
  }

  static bool accepts(Track t, LibrarySettings s) {
    if (t.isDemo) return true;
    if (s.hideShortSounds && t.isSystemSound) return false;
    if (t.duration < Duration(seconds: s.minDurationSeconds)) return false;
    if (s.minSizeKb > 0 && t.size > 0 && t.size < s.minSizeKb * 1024) return false;
    final path = t.path;
    if (path != null) {
      if (s.includedFolders.isNotEmpty && !s.includedFolders.any((f) => _under(path, f))) return false;
      if (s.excludedFolders.any((f) => _under(path, f))) return false;
    }
    return true;
  }

  static List<Track> apply(List<Track> tracks, LibrarySettings s) =>
      tracks.where((t) => accepts(t, s)).toList(growable: false);
}
