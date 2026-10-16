import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../shared/widgets/tap_scale.dart';
import '../../core/theme/navo_theme.dart';
import '../settings/data/app_settings.dart';
import '../settings/ui/settings_labels.dart';

/// Bottom navigation built from the user's tab order, with a glow behind
/// the active item. Labels can be hidden (they stay as semantics labels).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tabs,
    required this.current,
    required this.onChanged,
    this.showLabels = true,
  });

  final List<NavTab> tabs;
  final NavTab current;
  final ValueChanged<NavTab> onChanged;
  final bool showLabels;

  static (IconData, IconData) iconsFor(NavTab t) => switch (t) {
    NavTab.home => (Icons.home_rounded, Icons.home_outlined),
    NavTab.favorites => (Icons.favorite_rounded, Icons.favorite_border_rounded),
    NavTab.playlists => (Icons.library_music_rounded, Icons.library_music_outlined),
    NavTab.settings => (Icons.settings_rounded, Icons.settings_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.navo.background,
        border: Border(top: BorderSide(color: context.navo.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: showLabels ? Sizes.bottomNavHeight : Sizes.bottomNavHeight - 8,
          child: Row(
            children: [
              for (final t in tabs)
                Expanded(
                  child: _NavItem(
                    selected: t == current,
                    icon: iconsFor(t).$1,
                    outlinedIcon: iconsFor(t).$2,
                    label: navTabLabel(l10n, t),
                    showLabel: showLabels,
                    onTap: () => onChanged(t),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.showLabel,
    required this.onTap,
  });

  final bool showLabel;

  final bool selected;
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.navo.accent : context.navo.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: TapScale(
        onTap: onTap,
        scale: 0.9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: AppDurations.medium,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [context.navo.accent.withValues(alpha: 0.28), context.navo.accent.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Icon(selected ? icon : outlinedIcon, key: ValueKey(selected), color: color, size: 24),
                ),
                if (showLabel) ...[
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: AppDurations.fast,
                    style: context.text.labelSmall!.copyWith(color: color, fontSize: 10),
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
