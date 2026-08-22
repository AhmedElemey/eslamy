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

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val enabled = enabledKinds(widgetData)
        appWidgetIds.forEach { widgetId ->
            val kind = nextKind(context, widgetId, enabled)
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
