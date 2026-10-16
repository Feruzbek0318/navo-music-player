import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../library/data/models.dart';
import '../../settings/state/settings_providers.dart';
import '../data/lyrics_repository.dart';
import '../state/player_providers.dart';
import '../../../core/theme/navo_theme.dart';

/// Lyrics card. Synced lyrics highlight and follow the current line; tapping
/// a line seeks to it.
class LyricsView extends ConsumerWidget {
  const LyricsView({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lyrics = ref.watch(lyricsProvider(track));
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.navo.surface.withValues(alpha: 0.85),
        borderRadius: context.navo.radius(Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: switch (lyrics) {
        AsyncData(value: final l?) => _LyricsList(lyrics: l),
        AsyncData() || AsyncError() => Padding(
          padding: const EdgeInsets.all(Insets.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lyrics_outlined, size: 40, color: context.navo.textTertiary),
              const SizedBox(height: Insets.md),
              Text(l10n.noLyrics, style: context.text.titleSmall),
              const SizedBox(height: Insets.sm),
              Text(l10n.noLyricsHint, style: context.text.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _LyricsList extends ConsumerStatefulWidget {
  const _LyricsList({required this.lyrics});

  final Lyrics lyrics;

  @override
  ConsumerState<_LyricsList> createState() => _LyricsListState();
}

class _LyricsListState extends ConsumerState<_LyricsList> {
  late List<GlobalKey> _keys = _makeKeys();
  int _current = -1;
  Timer? _userScrollHold;
  bool _userScrolling = false;

  List<GlobalKey> _makeKeys() => List.generate(widget.lyrics.lines.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(_LyricsList old) {
    super.didUpdateWidget(old);
    if (old.lyrics != widget.lyrics) {
      _keys = _makeKeys();
      _current = -1;
    }
  }

  bool _awake = false;

  @override
  void dispose() {
    _userScrollHold?.cancel();
    if (_awake) WakelockPlus.disable();
    super.dispose();
  }

  /// Keeps the screen on while lyrics are visible, if the user wants that.
  void _syncWakelock(bool wanted) {
    if (wanted == _awake) return;
    _awake = wanted;
    wanted ? WakelockPlus.enable() : WakelockPlus.disable();
  }

  void _follow(int index) {
    if (!ref.read(lyricsSettingsProvider).autoScroll) return;
    if (_userScrolling || index < 0 || index >= _keys.length) return;
    final ctx = _keys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, alignment: 0.35, duration: AppDurations.slow, curve: AppCurves.standard);
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.lyrics;
    final opts = ref.watch(lyricsSettingsProvider);
    _syncWakelock(opts.keepScreenOn);
    final offset = Duration(milliseconds: opts.offsetMs);
    final centered = opts.align == LyricsAlign.center;
    if (lyrics.isSynced) {
      final position = ref.watch(positionProvider).value ?? Duration.zero;
      final index = lyrics.indexAt(position - offset);
      if (index != _current) {
        _current = index;
        WidgetsBinding.instance.addPostFrameCallback((_) => _follow(index));
      }
    }

    final base = context.text.titleMedium!.copyWith(height: 1.5, fontWeight: FontWeight.w600);
    return NotificationListener<UserScrollNotification>(
      onNotification: (_) {
        _userScrolling = true;
        _userScrollHold?.cancel();
        _userScrollHold = Timer(const Duration(seconds: 3), () => _userScrolling = false);
        return false;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl, vertical: Insets.xxl),
        child: Column(
          crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lyrics.lines.length; i++)
              GestureDetector(
                key: _keys[i],
                behavior: HitTestBehavior.opaque,
                onTap: lyrics.lines[i].time == null
                    ? null
                    : () => ref.read(playerControllerProvider).seek(lyrics.lines[i].time! + offset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xs),
                  child: AnimatedDefaultTextStyle(
                    duration: AppDurations.medium,
                    curve: AppCurves.standard,
                    style: base.copyWith(
                      color: !lyrics.isSynced
                          ? context.navo.textPrimary
                          : i == _current
                          ? context.navo.accent
                          : i < _current
                          ? context.navo.accent.withValues(alpha: 0.55)
                          : context.navo.textPrimary,
                      fontSize: i == _current ? opts.fontSize + 3 : opts.fontSize,
                      // The current line is also bolder, not only coloured.
                      fontWeight: i == _current ? FontWeight.w800 : FontWeight.w600,
                    ),
                    child: Text(lyrics.lines[i].text, textAlign: centered ? TextAlign.center : TextAlign.start),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
