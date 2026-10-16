import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'app.dart';
import 'core/platform/device_bridge.dart';
import 'core/storage/local_store.dart';
import 'features/library/data/music_repository.dart';
import 'features/player/data/audio_effects.dart';
import 'features/player/data/navo_audio_handler.dart';
import 'features/player/state/player_providers.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/state/settings_providers.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  // Uncaught errors are logged instead of taking the app down. Player
  // failures are reported to the user separately (see AppShell).
  runZonedGuarded(_bootstrap, (error, stack) => _report('zone', error, stack));
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _report('flutter', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _report('platform', error, stack);
    return true;
  };
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // just_audio has no native Windows/Linux backend; media_kit provides one.
  JustAudioMediaKit.ensureInitialized(linux: true, windows: true);

  final store = await LocalStore.open();
  final bridge = DeviceBridge();
  final music = MusicRepository(bridge);

  // The notification channel name is shown in system settings, so localise it.
  final settings = SettingsRepository(store).load();
  final locale = resolveLocale(
    settings.languageCode == null ? null : Locale(settings.languageCode!),
    PlatformDispatcher.instance.locales,
  );
  final l10n = lookupAppLocalizations(locale);

  // A single handler for the whole app, created before the UI.
  NavoAudioHandler buildHandler() => NavoAudioHandler(
    artworkUriFor: music.artworkFileUri,
    effects: AudioEffects(),
  );
  // audio_service has no Windows/Linux implementation; there the handler
  // runs without system media controls.
  final handler = Platform.isWindows || Platform.isLinux
      ? buildHandler()
      : await AudioService.init<NavoAudioHandler>(
          builder: buildHandler,
          config: AudioServiceConfig(
            androidNotificationChannelId: 'uz.feruzbek.navo.playback',
            androidNotificationChannelName: l10n.notificationChannelName,
            androidNotificationIcon: 'drawable/ic_stat_navo',
            androidNotificationOngoing: true,
            androidStopForegroundOnPause: true,
            fastForwardInterval: const Duration(seconds: 10),
            rewindInterval: const Duration(seconds: 10),
          ),
        );

  final container = ProviderContainer(
    overrides: [
      localStoreProvider.overrideWithValue(store),
      deviceBridgeProvider.overrideWithValue(bridge),
      audioHandlerProvider.overrideWithValue(handler),
    ],
  );
  // Keep the player controller active for the app's lifetime. Riverpod pauses
  // providers nobody listens to, which would also pause the controller's own
  // listeners (settings → player, widget sync) while the UI is in the
  // background.
  container.listen(playerControllerProvider, (_, _) {}, fireImmediately: true);

  runApp(
    UncontrolledProviderScope(container: container, child: const NavoApp()),
  );
}

void _report(String source, Object error, StackTrace? stack) {
  debugPrint('[$source] Uncaught error: $error');
  if (stack != null && kDebugMode) debugPrintStack(stackTrace: stack);
}
