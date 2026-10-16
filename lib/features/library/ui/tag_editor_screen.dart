import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/track_artwork.dart';
import '../data/models.dart';
import '../data/tag_editor.dart';
import '../state/library_providers.dart';

final tagEditorProvider = Provider<TagEditor>((ref) => TagEditor(ref.watch(deviceBridgeProvider)));

class TagEditorScreen extends ConsumerStatefulWidget {
  const TagEditorScreen({super.key, required this.track});

  final Track track;

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.track.title);
  late final _artist = TextEditingController(text: widget.track.artist ?? '');
  late final _album = TextEditingController(text: widget.track.album ?? '');
  late final _year = TextEditingController(text: widget.track.year?.toString() ?? '');
  Uint8List? _artwork;
  String _mime = 'image/jpeg';
  bool _artworkChanged = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _pickArtwork() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.xFile.readAsBytes();
    setState(() {
      _artwork = bytes;
      _mime = (file.extension ?? '').toLowerCase() == 'png' ? 'image/png' : 'image/jpeg';
      _artworkChanged = true;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    final result = await ref
        .read(tagEditorProvider)
        .save(
          widget.track,
          TagEdit(
            title: _title.text,
            artist: _artist.text,
            album: _album.text,
            year: int.tryParse(_year.text.trim()),
            artwork: _artwork,
            artworkMime: _mime,
            artworkChanged: _artworkChanged,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case TagSaveResult.saved:
        await ref.read(musicRepositoryProvider).evictArtwork(widget.track);
        ref.invalidate(artworkBytesProvider);
        await ref.read(deviceTracksProvider.notifier).rescan();
        if (!mounted) return;
        context.showSnack(l10n.tagsSaved);
        Navigator.pop(context);
      case TagSaveResult.cancelled:
        break;
      case TagSaveResult.unsupported:
        context.showSnack(l10n.tagsNotSupported);
      case TagSaveResult.failed:
        context.showSnack(l10n.tagsFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navo = context.navo;
    Widget field(TextEditingController c, String label, {TextInputType? type, String? Function(String?)? validator}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: Insets.lg),
          child: TextFormField(
            controller: c,
            keyboardType: type,
            textInputAction: TextInputAction.next,
            style: context.text.bodyLarge,
            validator: validator,
            decoration: InputDecoration(labelText: label),
          ),
        );

    final Widget cover = _artworkChanged
        ? (_artwork == null
              ? const ArtworkPlaceholder(seed: 0)
              : Image.memory(_artwork!, fit: BoxFit.cover, gaplessPlayback: true))
        : TrackArtwork(track: widget.track, size: 140, radius: Radii.lg);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTags)),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Insets.page,
            Insets.md,
            Insets.page,
            Insets.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: navo.radius(Radii.lg),
                child: SizedBox.square(dimension: 140, child: cover),
              ),
            ),
            const SizedBox(height: Insets.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Insets.sm,
              children: [
                TextButton.icon(
                  onPressed: _pickArtwork,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l10n.changeArtwork),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _artwork = null;
                    _artworkChanged = true;
                  }),
                  style: TextButton.styleFrom(foregroundColor: navo.danger),
                  icon: const Icon(Icons.hide_image_outlined),
                  label: Text(l10n.removeArtwork),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
            field(_title, l10n.detailTitle, validator: (v) => (v ?? '').trim().isEmpty ? l10n.playlistNameEmpty : null),
            field(_artist, l10n.detailArtist),
            field(_album, l10n.detailAlbum),
            field(
              _year,
              l10n.detailYear,
              type: TextInputType.number,
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                final y = int.tryParse(t);
                return y == null || y < 1000 || y > 2100 ? l10n.yearInvalid : null;
              },
            ),
            const SizedBox(height: Insets.md),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(label: l10n.save, icon: Icons.check_rounded, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
