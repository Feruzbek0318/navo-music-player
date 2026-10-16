import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/navo_theme.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../state/settings_providers.dart';
import '../settings_items.dart';

/// Renders any [SettingItem] bound to the live settings.
class SettingTile extends ConsumerWidget {
  const SettingTile({super.key, required this.item, this.caption});

  final SettingItem item;

  /// Shown above the title in search results (the group name).
  final String? caption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!item.isVisible(s, ref)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final navo = context.navo;
    final notifier = ref.read(settingsProvider.notifier);
    final icon = item.icon == null ? null : Icon(item.icon, color: navo.accent);

    Widget titleWith(String title) => caption == null
        ? Text(title, style: context.text.bodyLarge)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(caption!, style: context.text.labelSmall?.copyWith(color: navo.accent)),
              Text(title, style: context.text.bodyLarge),
            ],
          );

    final subtitle = item.subtitle?.call(l10n);

    switch (item) {
      case HeaderItem():
        return Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xxl, Insets.page, Insets.sm),
          child: Semantics(
            header: true,
            child: Text(
              item.title(l10n).toUpperCase(),
              style: context.text.labelSmall?.copyWith(color: navo.accent, letterSpacing: 1),
            ),
          ),
        );
      case SwitchItem(:final read, :final write):
        return SwitchListTile(
          secondary: icon,
          title: titleWith(item.title(l10n)),
          subtitle: subtitle == null ? null : Text(subtitle),
          value: read(s),
          onChanged: (v) => notifier.update((x) => write(x, v)),
        );
      case final ChoiceItem<dynamic> c:
        return ListTile(
          leading: icon,
          title: titleWith(c.title(l10n)),
          subtitle: Text(c.currentLabel(l10n, s)),
          trailing: Icon(Icons.chevron_right_rounded, color: navo.textSecondary),
          onTap: () => showAppSheet<void>(context, (_) => _ChoiceSheet(item: c)),
        );
      case SliderItem(:final read, :final write, :final min, :final max, :final divisions, :final format):
        final v = read(s).clamp(min, max);
        return Padding(
          padding: EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page - Insets.sm, Insets.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[icon, const SizedBox(width: Insets.lg)],
                  Expanded(child: titleWith(item.title(l10n))),
                  Text(format(l10n, v), style: context.text.labelMedium?.copyWith(color: navo.accent)),
                  const SizedBox(width: Insets.sm),
                ],
              ),
              if (subtitle != null) Text(subtitle, style: context.text.bodySmall),
              Slider(
                value: v,
                min: min,
                max: max,
                divisions: divisions,
                label: format(l10n, v),
                semanticFormatterCallback: (x) => format(l10n, x),
                onChanged: (x) => notifier.update((st) => write(st, x)),
              ),
            ],
          ),
        );
      case ActionItem(:final onTap, :final value, :final destructive):
        final valueText = value?.call(l10n, s, ref);
        final color = destructive ? navo.danger : null;
        return ListTile(
          leading: item.icon == null ? null : Icon(item.icon, color: color ?? navo.accent),
          title: caption == null
              ? Text(item.title(l10n), style: context.text.bodyLarge?.copyWith(color: color))
              : titleWith(item.title(l10n)),
          subtitle: valueText != null || subtitle != null ? Text(valueText ?? subtitle!) : null,
          trailing: destructive ? null : Icon(Icons.chevron_right_rounded, color: navo.textSecondary),
          onTap: () => onTap(context, ref),
        );
      case CustomItem(:final builder):
        return builder(context);
    }
  }
}

class _ChoiceSheet extends ConsumerWidget {
  const _ChoiceSheet({required this.item});

  final ChoiceItem<dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(settingsProvider);
    final labels = item.labels(l10n);
    return SafeArea(
      child: SingleChildScrollView(
        child: RadioGroup<int>(
          groupValue: item.selectedIndex(s),
          onChanged: (i) {
            if (i == null) return;
            ref.read(settingsProvider.notifier).update((x) => item.writeIndex(x, i));
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetTitle(item.title(l10n)),
              for (var i = 0; i < labels.length; i++)
                RadioListTile<int>(
                  value: i,
                  enabled: item.isEnabledAt(i, ref),
                  title: Text(labels[i], style: context.text.bodyLarge),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              const SizedBox(height: Insets.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks before resetting; returns true when confirmed.
Future<bool> confirmReset(BuildContext context, {required String title, required String message}) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          style: TextButton.styleFrom(foregroundColor: context.navo.danger),
          child: Text(l10n.reset),
        ),
      ],
    ),
  );
  return ok ?? false;
}
