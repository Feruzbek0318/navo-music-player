import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import '../../shared/widgets/buttons.dart';
import '../settings/state/settings_providers.dart';
import '../shell/app_shell.dart';
import 'onboarding_illustration.dart';
import '../../core/theme/navo_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pages = 3;
  final _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _page = _controller.page ?? 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).set(true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: AppDurations.slow,
        pageBuilder: (_, _, _) => const AppShell(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
  }

  void _next() {
    final current = _page.round();
    if (current >= _pages - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: AppDurations.slow, curve: AppCurves.emphasized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.onboardingTitle1, l10n.onboardingTitle2, l10n.onboardingTitle3];
    final index = _page.round();
    final isLast = index == _pages - 1;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _pages,
                  itemBuilder: (_, i) => SafeArea(
                    bottom: false,
                    child: OnboardingIllustration(page: i, parallax: (i - _page).clamp(-1.0, 1.0)),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: AppDurations.fast,
                      child: TextButton(
                        onPressed: isLast ? null : _finish,
                        child: Text(
                          l10n.skip,
                          style: context.text.labelLarge?.copyWith(color: context.navo.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.navo.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
              boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, -6))],
            ),
            padding: EdgeInsets.fromLTRB(
              Insets.xxl,
              Insets.xxxl,
              Insets.xxl,
              Insets.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 112,
                  child: AnimatedSwitcher(
                    duration: AppDurations.medium,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(a),
                        child: child,
                      ),
                    ),
                    child: Center(
                      key: ValueKey(index),
                      child: Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: context.text.headlineSmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Insets.lg),
                _PageDots(page: _page, count: _pages),
                const SizedBox(height: Insets.xxl),
                PrimaryButton(label: isLast ? l10n.getStarted : l10n.next, onPressed: _next),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.page, required this.count});

  final double page;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8 + 16 * t,
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(context.navo.surfaceHigh, context.navo.accent, t),
            borderRadius: context.navo.radius(Radii.pill),
          ),
        );
      }),
    );
  }
}
