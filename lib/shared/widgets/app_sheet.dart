import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../core/theme/navo_theme.dart';

/// Opens a rounded bottom sheet that scrolls when content is tall.
Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: context.navo.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.medium, reverseDuration: AppDurations.fast),
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: builder(context),
    ),
  );
}

/// Icon + label row used in option sheets.
class SheetAction extends StatelessWidget {
  const SheetAction({super.key, required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.navo.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.page + 4, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(width: Insets.lg),
            Expanded(
              child: Text(label, style: context.text.bodyMedium?.copyWith(color: c)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Title row for sheets that aren't headed by a song.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page + 4, 0, Insets.md, Insets.md),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}
