import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Fade + slight upward slide, used for most in-app navigation.
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  FadeThroughRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: AppDurations.medium,
        reverseTransitionDuration: AppDurations.fast,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: AppCurves.standard);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// Slides a full-screen page up from the bottom (used for the player).
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  SlideUpRoute({required WidgetBuilder builder, super.settings})
    : super(
        opaque: false,
        transitionDuration: AppDurations.slow,
        reverseTransitionDuration: AppDurations.medium,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppCurves.emphasized,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          );
        },
      );
}

extension NavigatorX on BuildContext {
  Future<T?> pushPage<T>(WidgetBuilder builder) => Navigator.of(this).push<T>(FadeThroughRoute<T>(builder: builder));
}
