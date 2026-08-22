import WidgetKit
import SwiftUI

// Must match WidgetDataService.appGroupId on the Flutter side and the
// com.apple.security.application-groups entry in both entitlements files.
// Internal (not private): shared with the Lock Screen widgets defined in
// EslamyLockScreenWidgets.swift, in the same extension target.
let appGroupId = "group.com.eslamy.eslamy"

enum EslamyWidgetKind: Int, CaseIterable {
    case prayer, ayah, dua, hijriDate

    var systemImageName: String {
        switch self {
        case .prayer: return "clock.fill"
        case .ayah: return "book.closed.fill"
        case .dua: return "hands.sparkles.fill"
        case .hijriDate: return "calendar"
        }
    }
}

struct EslamyWidgetContent {
    var kind: EslamyWidgetKind
    var kicker: String
    var primary: String
    var secondary: String

    static let placeholder = EslamyWidgetContent(
        kind: .ayah,
        kicker: "ESLAMY",
        primary: "Open the app to load today's content",
        secondary: ""
    )
}

struct EslamyWidgetEntry: TimelineEntry {
    let date: Date
    let content: EslamyWidgetContent
}

/// Reads whatever the Flutter app (WidgetDataService) last wrote to the
/// shared App Group storage for each content kind. Internal (not private):
/// also called from the single-kind Lock Screen widgets.
func content(for kind: EslamyWidgetKind) -> EslamyWidgetContent {
    let defaults = UserDefaults(suiteName: appGroupId)
    func string(_ key: String, _ fallback: String) -> String {
        defaults?.string(forKey: key) ?? fallback
    }
    switch kind {
    case .prayer:
        return EslamyWidgetContent(
            kind: kind,
            kicker: string("widget_prayer_kicker", "NEXT PRAYER"),
            primary: string("widget_prayer_primary", "—"),
            secondary: string("widget_prayer_secondary", "")
        )
    case .ayah:
        return EslamyWidgetContent(
            kind: kind,
            kicker: string("widget_ayah_kicker", "AYAH OF THE DAY"),
            primary: string("widget_ayah_primary", "—"),
            secondary: string("widget_ayah_secondary", "")
        )
    case .dua:
        return EslamyWidgetContent(
            kind: kind,
            kicker: string("widget_dua_kicker", "DUA OF THE DAY"),
            primary: string("widget_dua_primary", "—"),
            secondary: string("widget_dua_secondary", "")
        )
    case .hijriDate:
        return EslamyWidgetContent(
            kind: kind,
            kicker: string("widget_hijri_kicker", "TODAY'S HIJRI DATE"),
            primary: string("widget_hijri_primary", "—"),
            secondary: string("widget_hijri_secondary", "")
        )
    }
}

struct EslamyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> EslamyWidgetEntry {
        EslamyWidgetEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (EslamyWidgetEntry) -> Void) {
        completion(EslamyWidgetEntry(date: Date(), content: content(for: .ayah)))
    }

    /// Rotates prayer -> ayah -> dua every 3 hours across the next 24h, so
    /// the widget keeps cycling on its own even if the app is never
    /// reopened. Each precomputed entry re-reads whatever Flutter most
    /// recently wrote to the App Group at the time this timeline is built;
    /// the app also calls WidgetCenter.reloadTimelines (via
    /// HomeWidget.updateWidget) whenever it has fresher data, which
    /// regenerates this timeline immediately instead of waiting.
    func getTimeline(in context: Context, completion: @escaping (Timeline<EslamyWidgetEntry>) -> Void) {
        let now = Date()
        let hoursPerSlot = 3
        let slotCount = 24 / hoursPerSlot
        let entries: [EslamyWidgetEntry] = (0..<slotCount).map { i in
            let date = Calendar.current.date(byAdding: .hour, value: i * hoursPerSlot, to: now) ?? now
            let kind = EslamyWidgetKind.allCases[i % EslamyWidgetKind.allCases.count]
            return EslamyWidgetEntry(date: date, content: content(for: kind))
        }
        let timeline = Timeline(entries: entries, policy: .after(entries.last?.date ?? now))
        completion(timeline)
    }
}

struct EslamyWidgetView: View {
    var entry: EslamyWidgetProvider.Entry

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.055, green: 0.486, blue: 0.376),
                Color(red: 0.102, green: 0.608, blue: 0.463),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var foreground: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: entry.content.kind.systemImageName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text(entry.content.kicker)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.91, green: 0.757, blue: 0.439))
                    .lineLimit(1)
                Spacer()
            }
            Spacer(minLength: 0)
            Text(entry.content.primary)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if !entry.content.secondary.isEmpty {
                Text(entry.content.secondary)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    var body: some View {
        // iOS 17 deprecated a plain view background behind widget content in
        // favor of containerBackground (needed for the new removable-
        // background home screen); older OS versions don't have that API at
        // all, hence the availability split rather than always calling it.
        if #available(iOSApplicationExtension 17.0, *) {
            foreground.containerBackground(for: .widget) { gradient }
        } else {
            foreground.background(gradient)
        }
    }
}

struct EslamyWidget: Widget {
    let kind: String = "EslamyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EslamyWidgetProvider()) { entry in
            EslamyWidgetView(entry: entry)
        }
        .configurationDisplayName("Eslamy")
        .description("Rotates between the next prayer, ayah of the day, and dua of the day.")
        .supportedFamilies([.systemMedium])
    }
}
