import 'package:flutter/material.dart';

import '../../core/utils/context_ext.dart';

/// The Navo mark, optionally followed by the wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 28, this.showName = true, this.nameStyle});

  final double size;
  final bool showName;
  final TextStyle? nameStyle;

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      'assets/images/logo_mark.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
    if (!showName) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.32),
        Text(context.l10n.appName, style: nameStyle ?? context.text.titleLarge),
      ],
    );
  }
}
