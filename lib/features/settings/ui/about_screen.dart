import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/tap_scale.dart';
import '../../../core/theme/navo_theme.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Opens [uri] in an external app (Telegram, YouTube, browser).
Future<void> openExternalLink(BuildContext context, Uri uri) async {
  final failed = context.l10n.linkOpenFailed;
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) context.showSnack(failed);
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(packageInfoProvider).value;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Insets.page, Insets.lg, Insets.page, Insets.xxl + bottomInset),
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: context.navo.accentGlow(strength: 1.6)),
              child: const AppLogo(size: 96, showName: false),
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: AppDurations.slow),
          const SizedBox(height: Insets.xl),
          Text(l10n.appName, style: context.text.headlineMedium, textAlign: TextAlign.center),
          if (info != null) ...[
            const SizedBox(height: Insets.xs),
            Text(l10n.versionLabel(info.version), style: context.text.bodySmall, textAlign: TextAlign.center),
          ],
          const SizedBox(height: Insets.sm),
          Text(
            l10n.appTagline,
            style: context.text.bodyMedium?.copyWith(color: context.navo.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Insets.xxl),
          _Card(
            padding: const EdgeInsets.all(Insets.xl),
            child: Column(
              children: [
                Text(l10n.designedBy, style: context.text.titleSmall, textAlign: TextAlign.center),
                const SizedBox(height: Insets.xs),
                Text(
                  l10n.aboutBio,
                  style: context.text.bodyMedium?.copyWith(color: context.navo.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: AppDurations.fast, duration: AppDurations.medium).slideY(begin: 0.1),
          const SizedBox(height: Insets.lg),
          _Card(
            child: Column(
              children: [
                _ContactTile(
                  icon: FontAwesomeIcons.telegram,
                  color: const Color(0xFF29A9EB),
                  title: l10n.contactTelegram,
                  subtitle: '@${AppInfo.telegramHandle}',
                  uri: AppInfo.telegramUri,
                ),
                const Divider(indent: 64),
                _ContactTile(
                  icon: FontAwesomeIcons.youtube,
                  color: const Color(0xFFFF0033),
                  title: l10n.contactYouTube,
                  subtitle: l10n.youtubeChannel,
                  uri: AppInfo.youtubeUri,
                ),
              ],
            ),
          ).animate().fadeIn(delay: AppDurations.medium, duration: AppDurations.medium).slideY(begin: 0.1),
          const SizedBox(height: Insets.xxl),
          Center(
            child: TapScale(
              onTap: () => openExternalLink(context, Uri.https('flutter.dev')),
              child: Padding(
                padding: const EdgeInsets.all(Insets.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FlutterLogo(size: 18),
                    const SizedBox(width: Insets.sm),
                    Text(l10n.madeWithFlutter, style: context.text.labelMedium),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: info?.version,
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(Insets.md),
                  child: AppLogo(size: 48, showName: false),
                ),
                applicationLegalese: l10n.copyright(AppInfo.year),
              ),
              child: Text(l10n.openSourceLicenses),
            ),
          ),
          const SizedBox(height: Insets.xs),
          Text(l10n.copyright(AppInfo.year), style: context.text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: context.navo.surface, borderRadius: context.navo.radius(Radii.lg)),
      child: child,
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.uri,
  });

  final FaIconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: FaIcon(icon, color: color, size: 20),
      ),
      title: Text(title, style: context.text.bodyLarge),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.open_in_new_rounded, size: 18, color: context.navo.textSecondary),
      onTap: () => openExternalLink(context, uri),
    );
  }
}
