import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../router/app_keys.dart';

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  String get localeName => Localizations.localeOf(this).toLanguageTag();

  void showSnack(String message, {String? actionLabel, VoidCallback? onAction}) =>
      showAppSnack(message, actionLabel: actionLabel, onAction: onAction);
}
