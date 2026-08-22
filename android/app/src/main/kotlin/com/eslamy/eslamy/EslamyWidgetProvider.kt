package com.eslamy.eslamy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget that rotates between three "kinds" of content — next
 * prayer, ayah of the day, dua of the day — all written by the Flutter app
 * (see WidgetDataService) into the shared preferences [HomeWidgetProvider]
 * hands us. Each Android-triggered refresh (roughly every 30 min, per
 * eslamy_widget_info.xml's updatePeriodMillis) advances to the next kind on
 * its own, so the widget keeps rotating even if the app is never reopened.
 */
class EslamyWidgetProvider : HomeWidgetProvider() {

    private enum class Kind { PRAYER, AYAH, DUA }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val kind = nextKind(context, widgetId)
            val views = RemoteViews(context.packageName, R.layout.eslamy_widget_layout).apply {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.eslamy_widget_root, pendingIntent)

                val (kicker, primary, secondary) = contentFor(kind, widgetData)
                setTextViewText(R.id.eslamy_widget_kicker, kicker)
                setTextViewText(R.id.eslamy_widget_primary, primary)
                setTextViewText(R.id.eslamy_widget_secondary, secondary)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun nextKind(context: Context, widgetId: Int): Kind {
        val prefs = context.getSharedPreferences("eslamy_widget_rotation", Context.MODE_PRIVATE)
        val key = "kind_index_$widgetId"
        val nextIndex = (prefs.getInt(key, -1) + 1) % Kind.entries.size
        prefs.edit().putInt(key, nextIndex).apply()
        return Kind.entries[nextIndex]
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
    }
}
