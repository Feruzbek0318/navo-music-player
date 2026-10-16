import 'package:flutter/material.dart';

import '../../../core/utils/context_ext.dart';

/// Asks for a name (playlist, preset…). Returns `null` when cancelled.
Future<String?> showPlaylistNameDialog(
  BuildContext context, {
  String? initial,
  required bool rename,
  String? title,
  String? hint,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PlaylistNameDialog(initial: initial, rename: rename, title: title, hint: hint),
  );
}

class _PlaylistNameDialog extends StatefulWidget {
  const _PlaylistNameDialog({this.initial, required this.rename, this.title, this.hint});

  final String? initial;
  final bool rename;
  final String? title;
  final String? hint;

  @override
  State<_PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<_PlaylistNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.playlistNameEmpty);
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title ?? (widget.rename ? l10n.renamePlaylist : l10n.newPlaylist)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        style: context.text.bodyLarge,
        decoration: InputDecoration(hintText: widget.hint ?? l10n.playlistName, errorText: _error, counterText: ''),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(onPressed: _submit, child: Text(widget.rename ? l10n.save : l10n.create)),
      ],
    );
  }
}
