package uz.feruzbek.navo

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.Intent
import android.media.MediaRouter2
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.MediaStore
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter UI and a small "navo/device" channel for things the
 * plugins don't cover: ringtones, deleting media and the output switcher.
 */
class MainActivity : AudioServiceActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sdkInt" -> result.success(Build.VERSION.SDK_INT)
            "setRingtone" -> setRingtone(call.argument<Number>("id")!!.toLong(), result)
            "deleteAudio" -> deleteAudio(ids(call), result)
            "requestWrite" -> requestWrite(ids(call), result)
            "writeAudio" -> writeAudio(call.argument<Number>("id")!!.toLong(), call.argument<String>("path")!!, result)
            "scanFile" -> scanFile(call.argument<String>("path")!!, result)
            "updateWidget" -> {
                NavoWidgetProvider.update(
                    this,
                    call.argument<String>("title") ?: "",
                    call.argument<String>("artist") ?: "",
                    call.argument<Boolean>("playing") ?: false,
                    call.argument<String>("art"),
                )
                result.success(true)
            }
            "showOutputSwitcher" -> result.success(showOutputSwitcher())
            "manufacturer" -> result.success(Build.MANUFACTURER.lowercase())
            "isIgnoringBatteryOptimizations" -> {
                val pm = getSystemService(POWER_SERVICE) as PowerManager
                result.success(pm.isIgnoringBatteryOptimizations(packageName))
            }
            "openBatterySettings" -> result.success(openBatterySettings())
            else -> result.notImplemented()
        }
    }

    private fun ids(call: MethodCall): List<Long> =
        call.argument<List<Number>>("ids")?.map { it.toLong() } ?: listOf(call.argument<Number>("id")!!.toLong())

    private fun audioUri(id: Long): Uri =
        ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)

    /** Returns "ok", or "needs_permission" after opening the system settings page. */
    private fun setRingtone(id: Long, result: MethodChannel.Result) {
        if (!Settings.System.canWrite(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS, Uri.parse("package:$packageName"))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success("needs_permission")
            return
        }
        try {
            RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE, audioUri(id))
            result.success("ok")
        } catch (e: Exception) {
            result.error("ringtone_failed", e.message, null)
        }
    }

    // A system confirmation (delete / write access) waiting for its result.
    private var pending: MethodChannel.Result? = null
    private var afterGrant: (() -> Any?)? = null

    private fun ask(intentSender: android.content.IntentSender, result: MethodChannel.Result, then: (() -> Any?)?) {
        pending = result
        afterGrant = then
        startIntentSenderForResult(intentSender, CONFIRM_REQUEST, null, 0, 0, 0)
    }

    /** Deletes [ids]; true when everything was removed, false if the user declined. */
    private fun deleteAudio(ids: List<Long>, result: MethodChannel.Result) {
        val uris = ids.map(::audioUri)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                ask(MediaStore.createDeleteRequest(contentResolver, uris).intentSender, result, null)
                return
            }
            var deleted = 0
            for (uri in uris) {
                try {
                    deleted += contentResolver.delete(uri, null, null)
                } catch (e: SecurityException) {
                    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q && e is RecoverableSecurityException) {
                        // Android 10 asks per file; the rest of a batch is retried by the app.
                        ask(e.userAction.actionIntent.intentSender, result) { contentResolver.delete(uri, null, null) > 0 }
                        return
                    }
                    throw e
                }
            }
            result.success(deleted == uris.size)
        } catch (e: Exception) {
            result.error("delete_failed", e.message, null)
        }
    }

    /** Asks for write access to [ids] (Android 11+); true when granted. */
    private fun requestWrite(ids: List<Long>, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(true)
            return
        }
        try {
            ask(MediaStore.createWriteRequest(contentResolver, ids.map(::audioUri)).intentSender, result, null)
        } catch (e: Exception) {
            result.error("write_failed", e.message, null)
        }
    }

    /** Replaces the media file [id] with the bytes of [path] (an edited copy). */
    private fun writeAudio(id: Long, path: String, result: MethodChannel.Result) {
        val uri = audioUri(id)
        val write = {
            contentResolver.openOutputStream(uri, "wt")!!.use { out ->
                java.io.File(path).inputStream().use { it.copyTo(out) }
            }
            true
        }
        try {
            result.success(write())
        } catch (e: SecurityException) {
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q && e is RecoverableSecurityException) {
                ask(e.userAction.actionIntent.intentSender, result, write)
            } else {
                result.error("write_failed", e.message, null)
            }
        } catch (e: Exception) {
            result.error("write_failed", e.message, null)
        }
    }

    private fun scanFile(path: String, result: MethodChannel.Result) {
        android.media.MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, _ ->
            runOnUiThread { result.success(true) }
        }
    }

    @Deprecated("Uses the platform activity-result API, which is fine for these one-off requests.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CONFIRM_REQUEST) return
        val result = pending ?: return
        val then = afterGrant
        pending = null
        afterGrant = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(false)
            return
        }
        try {
            result.success(then?.invoke() ?: true)
        } catch (e: Exception) {
            result.error("confirm_failed", e.message, null)
        }
    }

    private fun showOutputSwitcher(): Boolean {
        if (Build.VERSION.SDK_INT >= 34) {
            return MediaRouter2.getInstance(this).showSystemOutputSwitcher()
        }
        // Android 11–13: ask System UI for its media output dialog.
        return try {
            val intent = Intent("com.android.systemui.action.LAUNCH_MEDIA_OUTPUT_DIALOG")
                .setPackage("com.android.systemui")
                .putExtra("package_name", packageName)
            sendBroadcast(intent)
            true
        } catch (e: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    /** Opens the most specific battery / autostart page available. */
    private fun openBatterySettings(): Boolean {
        val candidates = mutableListOf<Intent>()
        if (Build.MANUFACTURER.equals("xiaomi", ignoreCase = true)) {
            candidates += Intent().setClassName(
                "com.miui.powerkeeper",
                "com.miui.powerkeeper.ui.HiddenAppsConfigActivity",
            ).putExtra("package_name", packageName).putExtra("package_label", "Navo")
        }
        candidates += Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
        for (intent in candidates) {
            try {
                startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (_: Exception) {
                // Try the next one.
            }
        }
        return false
    }

    companion object {
        private const val CHANNEL = "navo/device"
        private const val CONFIRM_REQUEST = 4021
    }
}
