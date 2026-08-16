package com.eslamy.eslamy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.session.MediaControllerCompat
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import kotlin.math.abs

/**
 * The Quran-playback floating bubble: a plain native `WindowManager` overlay
 * (no second Flutter engine), so it can't hit the Flutter-engine bug that
 * left `flutter_overlay_window`'s secondary-isolate content permanently
 * blank (confirmed via `dumpsys window windows` during earlier testing —
 * the window existed and was marked drawn, but nothing ever rendered inside
 * it; a known unresolved `@pragma('vm:entry-point')` retention issue).
 *
 * Talks back to the running [QuranAudioHandler] through the app's *existing*
 * MediaSession (the one `audio_service`'s AudioService already exposes for
 * lock-screen/notification controls) rather than any custom cross-engine
 * channel — the same mechanism already proven to reliably reach the Dart
 * handler. Tap -> a `customAction("openNowPlaying")` transport command (see
 * `QuranAudioHandler.customAction`) plus bringing MainActivity to front. Drag
 * to the bottom edge -> a standard `stop()` transport command, exactly what
 * the notification's own stop button already sends.
 */
class BubbleOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    private var mediaBrowser: MediaBrowserCompat? = null
    private var mediaController: MediaControllerCompat? = null

    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var initialParamX = 0
    private var initialParamY = 0
    private var isDragging = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        connectMediaBrowser()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        if (bubbleView == null) addBubble()
        return START_STICKY
    }

    override fun onDestroy() {
        removeBubble()
        mediaController = null
        mediaBrowser?.disconnect()
        mediaBrowser = null
        super.onDestroy()
    }

    private fun connectMediaBrowser() {
        mediaBrowser = MediaBrowserCompat(
            this,
            ComponentName(this, "com.ryanheise.audioservice.AudioService"),
            object : MediaBrowserCompat.ConnectionCallback() {
                override fun onConnected() {
                    val browser = mediaBrowser ?: return
                    mediaController = MediaControllerCompat(this@BubbleOverlayService, browser.sessionToken)
                }
            },
            null,
        )
        mediaBrowser?.connect()
    }

    private fun addBubble() {
        val icon = ImageView(this).apply {
            setImageResource(resources.getIdentifier("ic_launcher", "mipmap", packageName))
            setPadding(0, 0, 0, 0)
        }

        val params = WindowManager.LayoutParams(
            BUBBLE_SIZE_PX,
            BUBBLE_SIZE_PX,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = resources.displayMetrics.widthPixels - BUBBLE_SIZE_PX
            y = resources.displayMetrics.heightPixels / 3
        }

        icon.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    initialParamX = params.x
                    initialParamY = params.y
                    isDragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    if (!isDragging && (abs(dx) > TAP_SLOP_PX || abs(dy) > TAP_SLOP_PX)) {
                        isDragging = true
                    }
                    if (isDragging) {
                        params.x = (initialParamX + dx).toInt()
                        params.y = (initialParamY + dy).toInt()
                        windowManager.updateViewLayout(view, params)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (isDragging) {
                        val screenHeight = resources.displayMetrics.heightPixels
                        val droppedNearBottom = params.y + BUBBLE_SIZE_PX >
                            screenHeight - CLOSE_ZONE_PX
                        if (droppedNearBottom) {
                            mediaController?.transportControls?.stop()
                            stopSelf()
                        }
                    } else {
                        onBubbleTapped()
                    }
                    true
                }
                else -> false
            }
        }

        windowManager.addView(icon, params)
        bubbleView = icon
        layoutParams = params
    }

    private fun onBubbleTapped() {
        mediaController?.transportControls?.sendCustomAction("openNowPlaying", null)
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }
        startActivity(intent)
    }

    private fun removeBubble() {
        bubbleView?.let { windowManager.removeView(it) }
        bubbleView = null
        layoutParams = null
    }

    private fun buildNotification(): android.app.Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Quran playback bubble",
                NotificationManager.IMPORTANCE_MIN,
            )
            manager.createNotificationChannel(channel)
        }
        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(resources.getIdentifier("ic_launcher", "mipmap", packageName))
            .setContentTitle("Eslamy")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .build()
    }

    companion object {
        private const val NOTIFICATION_ID = 4821
        private const val CHANNEL_ID = "quran_bubble_channel"
        private const val BUBBLE_SIZE_PX = 150
        private const val TAP_SLOP_PX = 12
        private const val CLOSE_ZONE_PX = 220
    }
}
