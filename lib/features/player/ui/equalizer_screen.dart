import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/navo_theme.dart';
import '../../../core/utils/context_ext.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../playlists/ui/playlist_name_dialog.dart';
import '../../settings/state/settings_providers.dart';
import '../../settings/ui/settings_labels.dart';
import '../data/audio_effects.dart';
import '../state/player_providers.dart';

String eqPresetLabel(AppLocalizations l, String id) => switch (id) {
  'normal' => l.eqNormal,
  'bass' => l.eqBass,
  'treble' => l.eqTreble,
  'rock' => l.eqRock,
  'pop' => l.eqPop,
  'jazz' => l.eqJazz,
  'classical' => l.eqClassical,
  'vocal' => l.eqVocal,
  'custom' => l.eqCustom,
  _ => id,
};

/// Device bands, loaded once the player has opened a file.
final eqBandsProvider = FutureProvider.autoDispose<List<EqBand>?>((ref) async {
  final effects = ref.watch(audioHandlerProvider).effects;
  if (effects == null || !effects.supported) return null;
  return effects.bands();
});

class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final audio = ref.watch(audioSettingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final effects = ref.watch(audioHandlerProvider).effects;
    final bands = ref.watch(eqBandsProvider);

    Widget body;
    if (effects == null || !effects.supported) {
      body = EmptyState(icon: Icons.equalizer_rounded, title: l10n.eqUnavailable);
    } else {
      body = ListView(
        padding: EdgeInsets.only(bottom: Insets.xxl + MediaQuery.paddingOf(context).bottom),
        children: [
          SwitchListTile(
            secondary: Icon(Icons.equalizer_rounded, color: context.navo.accent),
            title: Text(l10n.eqEnabled, style: context.text.bodyLarge),
            value: audio.eqEnabled,
            onChanged: (v) => notifier.audio((a) => a.copyWith(eqEnabled: v)),
          ),
          _PresetChips(audio: audio),
          switch (bands) {
            AsyncData(value: final b?) when b.isNotEmpty => _BandSliders(bands: b, audio: audio),
            AsyncLoading() => const Padding(
              padding: EdgeInsets.all(Insets.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            _ => Padding(
              padding: const EdgeInsets.all(Insets.xl),
              child: Text(l10n.eqStartPlayback, style: context.text.bodySmall, textAlign: TextAlign.center),
            ),
          },
          const Divider(indent: Insets.page, endIndent: Insets.page),
          _EffectSlider(
            icon: Icons.speaker_rounded,
            label: l10n.bassBoost,
            value: audio.bassBoost,
            onChanged: (v) => notifier.audio((a) => a.copyWith(bassBoost: v)),
          ),
          _EffectSlider(
            icon: Icons.volume_up_rounded,
            label: l10n.loudnessBoost,
            value: audio.loudness,
            onChanged: (v) => notifier.audio((a) => a.copyWith(loudness: v)),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.equalizer)),
      body: body,
    );
  }
}

class _PresetChips extends ConsumerWidget {
  const _PresetChips({required this.audio});

  final AudioSettings audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(settingsProvider.notifier);
    final bands = ref.watch(eqBandsProvider).value;
    final ids = [...EqPresets.builtIn.keys, ...audio.customPresets.keys];

    Future<void> savePreset() async {
      if (bands == null) return;
      final name = await showPlaylistNameDialog(context, rename: false, title: l10n.savePreset, hint: l10n.presetName);
      if (name == null) return;
      final gains = AudioEffects.baseGains(audio, bands);
      notifier.audio(
        (a) => a.copyWith(eqEnabled: true, eqPreset: name, customPresets: {...a.customPresets, name: gains}),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.presets, style: context.text.titleSmall),
          const SizedBox(height: Insets.sm),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (final id in ids)
                InputChip(
                  label: Text(eqPresetLabel(l10n, id)),
                  selected: audio.eqPreset == id,
                  onSelected: (_) => notifier.audio((a) => a.copyWith(eqEnabled: true, eqPreset: id)),
                  // Custom presets can be deleted; built-ins can't.
                  onDeleted: audio.customPresets.containsKey(id)
                      ? () => notifier.audio(
                          (a) => a.copyWith(
                            customPresets: {...a.customPresets}..remove(id),
                            eqPreset: a.eqPreset == id ? 'normal' : a.eqPreset,
                          ),
                        )
                      : null,
                  deleteButtonTooltipMessage: l10n.deletePreset,
                ),
              if (audio.eqPreset == 'custom') InputChip(label: Text(l10n.eqCustom), selected: true, onSelected: (_) {}),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.savePreset),
                onPressed: bands == null ? null : savePreset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BandSliders extends ConsumerWidget {
  const _BandSliders({required this.bands, required this.audio});

  final List<EqBand> bands;
  final AudioSettings audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gains = AudioEffects.baseGains(audio, bands);
    final notifier = ref.read(settingsProvider.notifier);
    String freq(double hz) =>
        hz >= 1000 ? l10n.khz((hz / 1000).toStringAsFixed(hz >= 10000 ? 0 : 1)) : l10n.hz(hz.round().toString());

    return Opacity(
      opacity: audio.eqEnabled ? 1 : 0.45,
      child: SizedBox(
        height: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < bands.length; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.db(gains[i].toStringAsFixed(0)), style: context.text.labelSmall),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          value: gains[i].clamp(bands[i].minDb, bands[i].maxDb),
                          min: bands[i].minDb,
                          max: bands[i].maxDb,
                          semanticFormatterCallback: (v) =>
                              '${freq(bands[i].centerHz)} ${l10n.db(v.toStringAsFixed(0))}',
                          onChanged: audio.eqEnabled
                              ? (v) => notifier.audio(
                                  (a) => a.copyWith(eqPreset: 'custom', bandGains: [...gains]..[i] = v),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Text(freq(bands[i].centerHz), style: context.text.labelSmall, maxLines: 1),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EffectSlider extends StatelessWidget {
  const _EffectSlider({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.navo.accent),
              const SizedBox(width: Insets.lg),
              Expanded(child: Text(label, style: context.text.bodyLarge)),
              Text(
                value == 0 ? l10n.off : percent(l10n, value),
                style: context.text.labelMedium?.copyWith(color: context.navo.accent),
              ),
              const SizedBox(width: Insets.sm),
            ],
          ),
          Slider(
            value: value,
            divisions: 20,
            label: percent(l10n, value),
            semanticFormatterCallback: (v) => percent(l10n, v),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
