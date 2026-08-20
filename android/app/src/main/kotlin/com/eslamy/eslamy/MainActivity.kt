package com.eslamy.eslamy

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// audio_service requires the launcher Activity to be (or extend)
// AudioServiceActivity so a notification/media-button tap reuses the same
// Flutter engine instead of spinning up a second one.
class MainActivity : AudioServiceActivity() {
    private val bubbleChannelName = "com.eslamy.eslamy/bubble"
    private var bubbleChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bubbleChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bubbleChannelName)
        bubbleChannel?.setMethodCallHandler { call, result ->
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
                    // Best-effort: Android 12+ can reject a foreground-service
                    // start with no Activity currently visible (e.g. playback
                    // resuming from the lock-screen/notification while
                    // backgrounded). The bubble is a nice-to-have, so swallow
                    // that rather than let it surface as an opaque
                    // PlatformException with nothing the caller can act on.
                    try {
                        ContextCompat.startForegroundService(
                            this,
                            Intent(this, BubbleOverlayService::class.java),
                        )
                    } catch (e: Exception) {
                        Log.w("BubbleOverlay", "Failed to start bubble overlay service", e)
                    }
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleOpenNowPlayingIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleOpenNowPlayingIntent(intent)
    }

    /// Overlay bubble tap sets [EXTRA_OPEN_NOW_PLAYING] so Now Playing still
    /// opens when MediaSession `customAction` never reached Dart (controller
    /// not connected, or navigator not ready on a cold start).
    private fun handleOpenNowPlayingIntent(intent: Intent?) {
        if (intent?.getBooleanExtra(EXTRA_OPEN_NOW_PLAYING, false) != true) return
        intent.putExtra(EXTRA_OPEN_NOW_PLAYING, false)
        window.decorView.post {
            bubbleChannel?.invokeMethod("openNowPlaying", null)
        }
    }

    private fun canDrawOverlays(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    companion object {
        const val EXTRA_OPEN_NOW_PLAYING = "open_now_playing"
    }
}
