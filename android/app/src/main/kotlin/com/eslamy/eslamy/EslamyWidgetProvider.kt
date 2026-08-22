package com.eslamy.eslamy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget that rotates between the content "kinds" the user has
 * switched on in-app (WidgetCustomizationPage) — next prayer, ayah of the
 * day, dua of the day, today's Hijri date — all written by the Flutter app
 * (see WidgetDataService) into the shared preferences [HomeWidgetProvider]
 * hands us. Each Android-triggered refresh (roughly every 30 min, per
 * eslamy_widget_info.xml's updatePeriodMillis) advances to the next enabled
 * kind on its own, so the widget keeps rotating even if the app is never
 * reopened.
 */
class EslamyWidgetProvider : HomeWidgetProvider() {

    private enum class Kind(val storageKey: String) {
        PRAYER("prayer"),
        AYAH("ayah"),
        DUA("dua"),
        HIJRI("hijri"),
    }

    private val scheduleNameIds = intArrayOf(
        R.id.eslamy_prayer_name_0,
        R.id.eslamy_prayer_name_1,
        R.id.eslamy_prayer_name_2,
        R.id.eslamy_prayer_name_3,
        R.id.eslamy_prayer_name_4,
    )

    private val scheduleTimeIds = intArrayOf(
        R.id.eslamy_prayer_time_0,
        R.id.eslamy_prayer_time_1,
        R.id.eslamy_prayer_time_2,
        R.id.eslamy_prayer_time_3,
        R.id.eslamy_prayer_time_4,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val enabled = enabledKinds(widgetData)
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        appWidgetIds.forEach { widgetId ->
            val kind = nextKind(context, widgetId, enabled)
            // Prayer gets its own richer layout (today's schedule row) —
            // RemoteViews lets a provider swap in a completely different
            // layout resource per update, it's only the plain 3-line kinds
            // that share eslamy_widget_layout by relabeling its TextViews.
            val views = if (kind == Kind.PRAYER) {
                buildPrayerViews(context, widgetData)
            } else {
                RemoteViews(context.packageName, R.layout.eslamy_widget_layout).apply {
                    val (kicker, primary, secondary) = contentFor(kind, widgetData)
                    setTextViewText(R.id.eslamy_widget_kicker, kicker)
                    setTextViewText(R.id.eslamy_widget_primary, primary)
                    setTextViewText(R.id.eslamy_widget_secondary, secondary)
                }
            }
            views.setOnClickPendingIntent(R.id.eslamy_widget_root, pendingIntent)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** Populates eslamy_widget_prayer_layout: the next-prayer header plus a fixed 5-column
     * schedule row (Fajr..Isha, no Sunrise — see WidgetContentBuilder.prayerSchedule on the
     * Flutter side), with the current/next prayer's name+time emphasized (dark pill, darker
     * label) against the lighter, muted styling of the other four. */
    private fun buildPrayerViews(context: Context, data: SharedPreferences): RemoteViews {
        return RemoteViews(context.packageName, R.layout.eslamy_widget_prayer_layout).apply {
            setTextViewText(
                R.id.eslamy_prayer_kicker,
                data.getString("widget_prayer_kicker", null) ?: "NEXT PRAYER",
            )
            setTextViewText(
                R.id.eslamy_prayer_next_line,
                data.getString("widget_prayer_primary", null) ?: "—",
            )

            val names = (data.getString("widget_prayer_names", null) ?: "").split(",")
            val times = (data.getString("widget_prayer_times", null) ?: "").split(",")
            val nextIndex = data.getInt("widget_prayer_next_index", -1)

            scheduleNameIds.forEachIndexed { i, nameId ->
                setTextViewText(nameId, names.getOrNull(i) ?: "")
                val timeId = scheduleTimeIds[i]
                setTextViewText(timeId, times.getOrNull(i) ?: "")
                if (i == nextIndex) {
                    setInt(timeId, "setBackgroundResource", R.drawable.eslamy_widget_pill_active)
                    setTextColor(timeId, 0xFFFFFFFF.toInt())
                    setTextColor(nameId, 0xFF1C2A26.toInt())
                } else {
                    setInt(timeId, "setBackgroundResource", 0)
                    setTextColor(timeId, 0xFF1C2A26.toInt())
                    setTextColor(nameId, 0xFF6B736F.toInt())
                }
            }
        }
    }

    /** The `widget_enabled_kinds` CSV written by WidgetDataService.pushEnabledKinds, falling
     * back to every kind if it's missing/empty/unparseable (e.g. before the app has ever
     * synced the preference). */
    private fun enabledKinds(widgetData: SharedPreferences): List<Kind> {
        val raw = widgetData.getString("widget_enabled_kinds", null) ?: return Kind.entries
        val kinds = raw.split(",").mapNotNull { key -> Kind.entries.find { it.storageKey == key } }
        return kinds.ifEmpty { Kind.entries }
    }

    private fun nextKind(context: Context, widgetId: Int, enabledKinds: List<Kind>): Kind {
        val prefs = context.getSharedPreferences("eslamy_widget_rotation", Context.MODE_PRIVATE)
        val key = "kind_index_$widgetId"
        val nextIndex = (prefs.getInt(key, -1) + 1) % enabledKinds.size
        prefs.edit().putInt(key, nextIndex).apply()
        return enabledKinds[nextIndex]
    }

    private fun contentFor(
        kind: Kind,
        data: SharedPreferences,
    ): Triple<String, String, String> = when (kind) {
        Kind.PRAYER -> Triple(
            data.getString("widget_prayer_kicker", null) ?: "NEXT PRAYER",
            data.getString("widget_prayer_primary", null) ?: "—",
            data.getString("widget_prayer_secondary", null) ?: "",
        )
        Kind.AYAH -> Triple(
            data.getString("widget_ayah_kicker", null) ?: "AYAH OF THE DAY",
            data.getString("widget_ayah_primary", null) ?: "—",
            data.getString("widget_ayah_secondary", null) ?: "",
        )
        Kind.DUA -> Triple(
            data.getString("widget_dua_kicker", null) ?: "DUA OF THE DAY",
            data.getString("widget_dua_primary", null) ?: "—",
            data.getString("widget_dua_secondary", null) ?: "",
        )
        Kind.HIJRI -> Triple(
            data.getString("widget_hijri_kicker", null) ?: "TODAY'S HIJRI DATE",
            data.getString("widget_hijri_primary", null) ?: "—",
            data.getString("widget_hijri_secondary", null) ?: "",
        )
    }
}
