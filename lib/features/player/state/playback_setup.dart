import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/platform/device_bridge.dart';
import '../../../core/storage/local_store.dart';

enum NotificationAccess { granted, denied, permanentlyDenied }

/// One-time setup the first time something plays: the Android 13+
/// notification permission (needed for the media notification on many
/// devices) and a battery-optimisation hint on OEMs that kill background apps.
class PlaybackSetup {
  PlaybackSetup(this._ref);

  final Ref _ref;

  /// Manufacturers known to stop background playback aggressively.
  static const _aggressiveOems = {
    'xiaomi',
    'redmi',
    'poco',
    'huawei',
    'honor',
    'oppo',
    'realme',
    'vivo',
    'oneplus',
    'meizu',
    'tecno',
    'infinix',
  };

  DeviceBridge get _bridge => _ref.read(deviceBridgeProvider);

  Future<NotificationAccess> ensureNotifications() async {
    if (!_bridge.isAndroid || await _bridge.androidSdkInt() < 33) return NotificationAccess.granted;
    var status = await Permission.notification.status;
    if (status.isDenied) status = await Permission.notification.request();
    if (status.isGranted || status.isLimited || status.isProvisional) return NotificationAccess.granted;
    return status.isPermanentlyDenied ? NotificationAccess.permanentlyDenied : NotificationAccess.denied;
  }

  Future<bool> shouldShowBatteryHint() async {
    if (!_bridge.isAndroid) return false;
    final store = _ref.read(localStoreProvider);
    if (store.setting<bool>(StoreKeys.batteryHintShown) ?? false) return false;
    if (!_aggressiveOems.contains(await _bridge.manufacturer())) return false;
    return !await _bridge.isIgnoringBatteryOptimizations();
  }

  Future<void> markBatteryHintShown() => _ref.read(localStoreProvider).putSetting(StoreKeys.batteryHintShown, true);

  Future<bool> openBatterySettings() => _bridge.openBatterySettings();
}

final playbackSetupProvider = Provider<PlaybackSetup>((ref) => PlaybackSetup(ref));
