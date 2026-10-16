# Vendored packages

## on_audio_query_plus_android (1.3.0, BSD-3-Clause)

Copied from pub.dev with two fixes, marked `Navo patch` in the source:

1. `controllers/PermissionController.kt` — on Android 13+ only `READ_MEDIA_AUDIO`
   is required (upstream also demands `READ_MEDIA_IMAGES`).
2. `OnAudioQueryPlugin.kt` — return after replying `MissingPermissions`;
   upstream continues and replies a second time, which crashes the app
   with `IllegalStateException: Reply already submitted`.

Remove the `dependency_overrides` entry in `pubspec.yaml` once upstream ships these fixes.
