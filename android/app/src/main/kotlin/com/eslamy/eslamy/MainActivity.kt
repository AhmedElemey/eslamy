package com.eslamy.eslamy

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// audio_service requires the launcher Activity to be (or extend)
// AudioServiceActivity so a notification/media-button tap reuses the same
// Flutter engine instead of spinning up a second one.
class MainActivity : AudioServiceActivity() {
    private val bubbleChannelName = "com.eslamy.eslamy/bubble"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bubbleChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasOverlayPermission" -> result.success(canDrawOverlays())
                    "requestOverlayPermission" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName"),
                            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }
                    "showBubble" -> {
                        ContextCompat.startForegroundService(
                            this,
                            Intent(this, BubbleOverlayService::class.java),
                        )
                        result.success(null)
                    }
                    "hideBubble" -> {
                        stopService(Intent(this, BubbleOverlayService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun canDrawOverlays(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
}
