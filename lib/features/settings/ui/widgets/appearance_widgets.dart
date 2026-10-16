import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/navo_theme.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/equalizer_bars.dart';
import '../../../../shared/widgets/track_artwork.dart';
import '../../../library/data/demo_catalog.dart';
import '../../state/settings_providers.dart';
import '../settings_labels.dart';

/// Live preview of the current appearance: a song row, a button, chips and
/// the progress bar, drawn with the real theme tokens.
class AppearancePreview extends StatelessWidget {
  const AppearancePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final navo = context.navo;
    final track = DemoCatalog.tracks.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, Insets.xs),
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: navo.surface,
        borderRadius: navo.radius(Radii.lg),
        border: Border.all(color: navo.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.preview.toUpperCase(),
            style: context.text.labelSmall?.copyWith(color: navo.accent, letterSpacing: 1),
          ),
          SizedBox(height: Insets.md * navo.densityScale),
          Row(
            children: [
              if (navo.showListArtwork) ...[
                TrackArtwork(
                  track: track,
                  size: navo.listArtSize,
                  radius: navo.listArtRadius,
                  circle: navo.listArtCircle,
                ),
                const SizedBox(width: Insets.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: context.text.bodyLarge?.copyWith(color: navo.accent)),
                    const SizedBox(height: 2),
                    Text(track.artist ?? '', style: context.text.bodySmall),
                  ],
                ),
              ),
              const EqualizerBars(animating: true, size: 18),
            ],
          ),
          SizedBox(height: Insets.lg * navo.densityScale),
          ClipRRect(
            borderRadius: navo.radius(Radii.pill),
            child: LinearProgressIndicator(value: 0.4, minHeight: 4, backgroundColor: navo.surfaceHigh),
          ),
          const SizedBox(height: Insets.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(label: context.l10n.shuffle, icon: Icons.shuffle_rounded, onPressed: () {}),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: SecondaryButton(label: context.l10n.play, icon: Icons.play_arrow_rounded, onPressed: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Preset swatches for the accent colour.
class AccentPresetPicker extends ConsumerWidget {
  const AccentPresetPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appearanceProvider.select((a) => a.accentPreset));
    final navo = context.navo;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, Insets.md),
      child: Wrap(
        spacing: Insets.md,
        runSpacing: Insets.md,
        children: [
          for (var i = 0; i < AppColors.accentPresets.length; i++)
            Semantics(
              button: true,
              selected: i == selected,
              label: '${context.l10n.accentPreset} ${i + 1}',
              child: InkResponse(
                radius: 26,
                onTap: () => ref.read(settingsProvider.notifier).appearance((a) => a.copyWith(accentPreset: i)),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentPresets[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: i == selected ? navo.textPrimary : Colors.transparent, width: 3),
                  ),
                  // A tick, not just colour, marks the selection.
                  child: i == selected ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hue / saturation / brightness sliders for a custom accent.
class CustomAccentPicker extends ConsumerWidget {
  const CustomAccentPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = Color(ref.watch(appearanceProvider.select((a) => a.customAccent)));
    final hsl = HSLColor.fromColor(value);
    void set(HSLColor c) =>
        ref.read(settingsProvider.notifier).appearance((a) => a.copyWith(customAccent: c.toColor().toARGB32()));

    Widget slider(String label, double v, double max, ValueChanged<double> onChanged, List<Color> track) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label, style: context.text.bodySmall)),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: track),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: value,
                  ),
                  child: Slider(value: v, max: max, label: label, onChanged: onChanged),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: value,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: value.withValues(alpha: 0.5), blurRadius: 16)],
            ),
          ),
        ),
        slider(l10n.hue, hsl.hue, 360, (v) => set(hsl.withHue(v)), [
          for (var h = 0; h <= 360; h += 60) HSLColor.fromAHSL(1, h.toDouble(), 0.9, 0.55).toColor(),
        ]),
        slider(l10n.saturation, hsl.saturation, 1, (v) => set(hsl.withSaturation(v)), [
          hsl.withSaturation(0).toColor(),
          hsl.withSaturation(1).toColor(),
        ]),
        slider(l10n.lightness, hsl.lightness, 1, (v) => set(hsl.withLightness(v.clamp(0.15, 0.85))), [
          hsl.withLightness(0.15).toColor(),
          hsl.withLightness(0.5).toColor(),
          hsl.withLightness(0.85).toColor(),
        ]),
        const SizedBox(height: Insets.sm),
      ],
    );
  }
}

/// Reorder / hide sheet for the bottom tabs or the Home tabs.
Future<void> showTabOrderSheet(BuildContext context, {required bool homeTabs}) =>
    showAppSheet<void>(context, (_) => _TabOrderSheet(homeTabs: homeTabs));

class _TabOrderSheet extends ConsumerWidget {
  const _TabOrderSheet({required this.homeTabs});

  final bool homeTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final a = ref.watch(appearanceProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final navo = context.navo;

    final List<Object> order = homeTabs ? a.homeTabOrder : a.navOrder;
    String label(Object t) => t is NavTab ? navTabLabel(l10n, t) : homeTabLabel(l10n, t as HomeTab);

    void reorder(int from, int to) {
      final list = [...order];
      list.insert(to, list.removeAt(from));
      notifier.appearance(
        (x) => homeTabs ? x.copyWith(homeTabOrder: list.cast<HomeTab>()) : x.copyWith(navOrder: list.cast<NavTab>()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetTitle(homeTabs ? l10n.homeTabs : l10n.navTabs),
        if (!homeTabs)
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.page + 4, 0, Insets.page, Insets.sm),
            child: Text(l10n.navTabsHint, style: context.text.bodySmall),
          ),
        Flexible(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + Insets.md),
            itemCount: order.length,
            onReorderItem: reorder,
            itemBuilder: (_, i) => Builder(
              // Reorderable lists need the key on the outermost item widget.
              key: ValueKey(order[i]),
              builder: (context) {
                final t = order[i];
                final locked = t == NavTab.settings;
                final shown = homeTabs || locked || !a.hiddenNavTabs.contains(t);
                return ListTile(
                  key: ValueKey(t),
                  leading: homeTabs
                      ? null
                      : Checkbox(
                          value: shown,
                          onChanged: locked
                              ? null
                              : (v) => notifier.appearance(
                                  (x) => x.copyWith(
                                    hiddenNavTabs: v == true
                                        ? (x.hiddenNavTabs.toList()..remove(t))
                                        : [...x.hiddenNavTabs, t as NavTab],
                                  ),
                                ),
                        ),
                  title: Text(label(t), style: context.text.bodyLarge),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.all(Insets.md),
                      child: Icon(Icons.drag_handle_rounded, color: navo.textSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
