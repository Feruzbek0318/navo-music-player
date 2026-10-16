import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/app_settings.dart';

typedef L10nText = String Function(AppLocalizations l);
typedef Visible = bool Function(AppSettings s, WidgetRef ref);

/// One entry in the settings registry. Items describe how to read and write
/// their value, so the same definition drives the group screen, search
/// results and tests.
sealed class SettingItem {
  const SettingItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.keywords,
    this.visible,
    this.advanced = false,
  });

  final L10nText title;
  final L10nText? subtitle;
  final IconData? icon;

  /// Extra search terms (all languages are searched via [title] already).
  final L10nText? keywords;
  final Visible? visible;

  /// Rarely changed; shown under "Advanced" in its group (search finds it).
  final bool advanced;

  bool isVisible(AppSettings s, WidgetRef ref) => visible?.call(s, ref) ?? true;
}

/// Section caption inside a group.
class HeaderItem extends SettingItem {
  const HeaderItem({required super.title});
}

class SwitchItem extends SettingItem {
  const SwitchItem({
    required super.title,
    super.subtitle,
    super.icon,
    super.keywords,
    super.visible,
    super.advanced,
    required this.read,
    required this.write,
  });

  final bool Function(AppSettings s) read;
  final AppSettings Function(AppSettings s, bool v) write;
}

class ChoiceItem<T> extends SettingItem {
  const ChoiceItem({
    required super.title,
    super.subtitle,
    super.icon,
    super.keywords,
    super.visible,
    super.advanced,
    required this.options,
    required this.label,
    required this.read,
    required this.write,
    this.enabled,
  });

  final List<T> options;
  final String Function(AppLocalizations l, T value) label;
  final T Function(AppSettings s) read;
  final AppSettings Function(AppSettings s, T v) write;

  /// Optionally disables some options (shown greyed out).
  final bool Function(T value, WidgetRef ref)? enabled;

  String currentLabel(AppLocalizations l, AppSettings s) => label(l, read(s));

  // Index-based API: lets the UI work with any ChoiceItem without knowing T
  // (calling the T-typed function fields through ChoiceItem<Object?> would
  // fail Dart's runtime type checks).
  List<String> labels(AppLocalizations l) => [for (final o in options) label(l, o)];
  int selectedIndex(AppSettings s) => options.indexOf(read(s));
  AppSettings writeIndex(AppSettings s, int i) => write(s, options[i]);
  bool isEnabledAt(int i, WidgetRef ref) => enabled?.call(options[i], ref) ?? true;
}

class SliderItem extends SettingItem {
  const SliderItem({
    required super.title,
    super.subtitle,
    super.icon,
    super.keywords,
    super.visible,
    super.advanced,
    required this.min,
    required this.max,
    this.divisions,
    required this.read,
    required this.write,
    required this.format,
  });

  final double min;
  final double max;
  final int? divisions;
  final double Function(AppSettings s) read;
  final AppSettings Function(AppSettings s, double v) write;
  final String Function(AppLocalizations l, double v) format;
}

/// Opens a screen, sheet or runs a command.
class ActionItem extends SettingItem {
  const ActionItem({
    required super.title,
    super.subtitle,
    super.icon,
    super.keywords,
    super.visible,
    super.advanced,
    required this.onTap,
    this.value,
    this.destructive = false,
  });

  final void Function(BuildContext context, WidgetRef ref) onTap;
  final String? Function(AppLocalizations l, AppSettings s, WidgetRef ref)? value;
  final bool destructive;
}

/// Free-form widget (preview card, colour picker, statement text).
class CustomItem extends SettingItem {
  const CustomItem({required super.title, super.keywords, super.visible, required this.builder});

  final WidgetBuilder builder;
}

enum SettingsGroupId {
  appearance,
  player,
  playback,
  audio,
  library,
  lyrics,
  notifications,
  gestures,
  language,
  storage,
  accessibility,
  privacy,
  about,
}

class SettingsGroup {
  const SettingsGroup({
    required this.id,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.items,
    this.reset,
  });

  final SettingsGroupId id;
  final IconData icon;
  final L10nText title;
  final L10nText? subtitle;
  final List<SettingItem> items;

  /// Returns settings with this group's values restored; `null` hides
  /// the reset action (nothing to reset).
  final AppSettings Function(AppSettings s)? reset;
}
