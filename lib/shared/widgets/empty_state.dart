import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/context_ext.dart';
import 'buttons.dart';
import '../../core/theme/navo_theme.dart';

/// Centered icon + title + message, with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xxxl, vertical: Insets.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: context.navo.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: context.navo.accent),
            ).animate().scale(begin: const Offset(0.8, 0.8), duration: AppDurations.slow, curve: Curves.easeOutBack),
            const SizedBox(height: Insets.xl),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: Insets.sm),
              Text(
                message!,
                style: context.text.bodyMedium?.copyWith(color: context.navo.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: Insets.xxl),
              PrimaryButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: Insets.sm),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ).animate().fadeIn(duration: AppDurations.medium).slideY(begin: 0.05, curve: AppCurves.standard),
      ),
    );
  }
}
