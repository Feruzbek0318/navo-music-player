import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_helpers.dart';
import '../../data/music_repository.dart';
import '../../state/library_providers.dart';
import '../../../../core/theme/navo_theme.dart';

/// Renders an [AsyncValue] with the shared loading / error / empty states.
class LibraryAsyncView<T> extends ConsumerWidget {
  const LibraryAsyncView({
    super.key,
    required this.value,
    required this.isEmpty,
    required this.builder,
    required this.emptyIcon,
    required this.emptyTitle,
  });

  final AsyncValue<T> value;
  final bool Function(T data) isEmpty;
  final Widget Function(T data) builder;
  final IconData emptyIcon;
  final String emptyTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return switch (value) {
      AsyncData(:final value) when isEmpty(value) => _EmptyLibrary(icon: emptyIcon, title: emptyTitle),
      AsyncData(:final value) => builder(value),
      AsyncError() => EmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.errorTitle,
        actionLabel: l10n.retry,
        onAction: () => rescanLibrary(ref),
      ),
      _ => const SongListSkeleton(),
    };
  }
}

class _EmptyLibrary extends ConsumerWidget {
  const _EmptyLibrary({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final permission = ref.watch(libraryPermissionProvider).value;
    if (MusicRepository.supportsDeviceLibrary && permission != LibraryPermission.granted) {
      return _PermissionState(permission: permission);
    }
    return EmptyState(
      icon: icon,
      title: title,
      message: l10n.noSongsMessage,
      actionLabel: l10n.rescanLibrary,
      onAction: () => rescanLibrary(ref),
    );
  }
}

class _PermissionState extends ConsumerWidget {
  const _PermissionState({required this.permission});

  final LibraryPermission? permission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final permanent = permission == LibraryPermission.permanentlyDenied;
    return EmptyState(
      icon: Icons.library_music_outlined,
      title: l10n.permissionTitle,
      message: permanent ? l10n.permissionDeniedMessage : l10n.permissionMessage,
      actionLabel: permanent ? l10n.openSettings : l10n.allowAccess,
      onAction: () => permanent ? openAppSettings() : ref.read(libraryPermissionProvider.notifier).request(),
    );
  }
}

/// Compact card asking for library access while demo tracks are shown.
class PermissionBanner extends ConsumerWidget {
  const PermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!MusicRepository.supportsDeviceLibrary) return const SizedBox.shrink();
    final permission = ref.watch(libraryPermissionProvider).value;
    if (permission == null || permission == LibraryPermission.granted) return const SizedBox.shrink();
    final l10n = context.l10n;
    final permanent = permission == LibraryPermission.permanentlyDenied;

    return Container(
      margin: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, Insets.xs),
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: context.navo.surface,
        borderRadius: context.navo.cardRadius,
        border: Border.all(color: context.navo.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_open_rounded, color: context.navo.accent, size: 28),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.permissionTitle, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  permanent ? l10n.permissionDeniedMessage : l10n.permissionMessage,
                  style: context.text.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 124),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.navo.accent,
                foregroundColor: context.navo.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: Insets.md),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => permanent ? openAppSettings() : ref.read(libraryPermissionProvider.notifier).request(),
              child: Text(permanent ? l10n.openSettings : l10n.allowAccess, maxLines: 2, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
