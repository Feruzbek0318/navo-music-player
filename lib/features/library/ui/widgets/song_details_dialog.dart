import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../data/models.dart';
import '../labels.dart';
import '../../../../core/theme/navo_theme.dart';

Future<void> showSongDetails(BuildContext context, Track track) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SongDetailsDialog(track: track),
  );
}

class _SongDetailsDialog extends StatelessWidget {
  const _SongDetailsDialog({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;
    final rows = <(String, String)>[
      (l10n.detailTitle, track.title),
      (l10n.detailArtist, context.artistOf(track)),
      (l10n.detailAlbum, context.albumOf(track)),
      if (track.composer != null) (l10n.detailComposer, track.composer!),
      if (track.genre != null) (l10n.detailGenre, track.genre!),
      if (track.year != null) (l10n.detailYear, '${track.year}'),
      (l10n.detailDuration, formatDuration(track.duration)),
      if (track.extension.isNotEmpty) (l10n.detailFormat, track.extension.toUpperCase()),
      if (track.size > 0) (l10n.detailSize, formatFileSize(track.size, locale)),
      if (track.dateAdded != null) (l10n.detailDateAdded, formatDate(track.dateAdded!, locale)),
      (l10n.detailPath, track.isDemo ? '${l10n.appName} ${l10n.demoTrack}' : (track.path ?? l10n.unknown)),
    ];

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(Insets.xxl, Insets.xxl, Insets.xxl, Insets.sm),
      title: Row(
        children: [
          TrackArtwork(track: track, size: 48),
          const SizedBox(width: Insets.md),
          Expanded(child: Text(l10n.songDetails, style: context.text.titleMedium)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xs + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: context.text.labelSmall),
                      const SizedBox(height: 2),
                      SelectableText(value, style: context.text.bodyMedium?.copyWith(color: context.navo.textPrimary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
    );
  }
}
