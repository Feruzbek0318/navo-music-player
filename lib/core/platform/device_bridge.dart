import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RingtoneResult { ok, needsPermission, failed }

/// Calls into `MainActivity.kt` for features no plugin covers.
class DeviceBridge {
  static const _channel = MethodChannel('navo/device');

  int? _sdkInt;

  bool get isAndroid => Platform.isAndroid;

  Future<int> androidSdkInt() async {
    if (!isAndroid) return 0;
    return _sdkInt ??= await _channel.invokeMethod<int>('sdkInt') ?? 0;
  }

  Future<RingtoneResult> setRingtone(int mediaId) async {
    if (!isAndroid) return RingtoneResult.failed;
    try {
      final r = await _channel.invokeMethod<String>('setRingtone', {'id': mediaId});
      return r == 'ok' ? RingtoneResult.ok : RingtoneResult.needsPermission;
    } on PlatformException {
      return RingtoneResult.failed;
    }
  }

  /// Returns true if the files were removed (the system asks the user first).
  Future<bool> deleteAudio(List<int> mediaIds) async {
    if (!isAndroid || mediaIds.isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('deleteAudio', {'ids': mediaIds}) ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Asks for permission to modify these media files (Android 11+).
  Future<bool> requestWrite(List<int> mediaIds) => _invoke<bool>('requestWrite', {'ids': mediaIds}, false);

  /// Overwrites media file [mediaId] with the file at [path].
  Future<bool> writeAudio(int mediaId, String path) =>
      _invoke<bool>('writeAudio', {'id': mediaId, 'path': path}, false);

  /// Asks the media scanner to re-read [path].
  Future<bool> scanFile(String path) => _invoke<bool>('scanFile', {'path': path}, false);

  /// Pushes the now-playing state to the home-screen widget.
  Future<void> updateWidget({required String title, required String artist, required bool playing, String? artPath}) =>
      _invoke<bool>('updateWidget', {'title': title, 'artist': artist, 'playing': playing, 'art': artPath}, false);

  Future<T> _invoke<T>(String method, Map<String, Object?> args, T fallback) async {
    if (!isAndroid) return fallback;
    try {
      return await _channel.invokeMethod<T>(method, args) ?? fallback;
    } on PlatformException catch (e) {
      debugPrint('$method failed: ${e.message}');
      return fallback;
    }
  }

  Future<String> manufacturer() => _call<String>('manufacturer', '');

  Future<bool> isIgnoringBatteryOptimizations() => _call<bool>('isIgnoringBatteryOptimizations', true);

  Future<bool> openBatterySettings() => _call<bool>('openBatterySettings', false);

  Future<T> _call<T>(String method, T fallback) async {
    if (!isAndroid) return fallback;
    try {
      return await _channel.invokeMethod<T>(method) ?? fallback;
    } on PlatformException {
      return fallback;
    } on MissingPluginException {
      return fallback;
    }
  }

  Future<bool> showOutputSwitcher() async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('showOutputSwitcher') ?? false;
    } on PlatformException {
      return false;
    }
  }
}

final deviceBridgeProvider = Provider<DeviceBridge>((ref) => DeviceBridge());
