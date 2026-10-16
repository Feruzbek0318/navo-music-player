# Navo release rules.
# audio_service / just_audio ship consumer rules, but these classes are
# reached via reflection-like lookups (MediaBrowserService, receivers), so
# keep them explicitly to be safe.
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_session.** { *; }
-keep class uz.feruzbek.navo.MainActivity { *; }
