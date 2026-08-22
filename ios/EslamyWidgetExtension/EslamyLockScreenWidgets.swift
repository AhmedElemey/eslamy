import WidgetKit
import SwiftUI

/// Timeline provider for a single-kind Lock Screen widget. Unlike the
/// rotating home-screen widget (`EslamyWidget`), each Lock Screen widget
/// always shows one fixed content kind — the user picks which one to add
/// from iOS's own widget gallery (long-press the Lock Screen, tap +, choose
/// "Eslamy") — so there's nothing to rotate here, just a periodic refresh so
/// a prayer countdown or "in N days" string doesn't visibly go stale between
/// app opens. The app also force-reloads immediately via WidgetCenter
/// whenever it has fresher data (see WidgetDataService on the Flutter side);
/// this timeline is only the fallback cadence.
struct EslamySingleKindProvider: TimelineProvider {
    let kind: EslamyWidgetKind

    func placeholder(in context: Context) -> EslamyWidgetEntry {
        EslamyWidgetEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (EslamyWidgetEntry) -> Void) {
        completion(EslamyWidgetEntry(date: Date(), content: content(for: kind)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EslamyWidgetEntry>) -> Void) {
        let now = Date()
        let refreshAt = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now
        let entry = EslamyWidgetEntry(date: now, content: content(for: kind))
        completion(Timeline(entries: [entry], policy: .after(refreshAt)))
    }
}

/// Adaptive view honoring each Lock Screen "accessory" family's very
/// different layout rules. The system renders these in a single tint
/// (vibrant on the Lock Screen, monochrome elsewhere) regardless of the
/// colors set here — no custom backgrounds or brand colors actually apply
/// once placed, so this deliberately uses no explicit foreground colors.
struct EslamyAccessoryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: EslamyWidgetEntry

    @ViewBuilder
    private var adaptive: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 2) {
                Image(systemName: entry.content.kind.systemImageName)
                Text(entry.content.primary)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        case .accessoryInline:
            Label(entry.content.primary, systemImage: entry.content.kind.systemImageName)
                .lineLimit(1)
        default: // .accessoryRectangular
            VStack(alignment: .leading, spacing: 2) {
                Label(entry.content.kicker, systemImage: entry.content.kind.systemImageName)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                Text(entry.content.primary)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if !entry.content.secondary.isEmpty {
                    Text(entry.content.secondary)
                        .font(.system(size: 11))
                        .lineLimit(1)
                }
            }
        }
    }

    var body: some View {
        // Same iOS 17 containerBackground split as EslamyWidgetView — see
        // its comment in EslamyWidget.swift. The color passed here has no
        // visible effect on Lock Screen accessory families specifically
        // (the system fully controls their appearance), but the call is
        // still required on 17+ or WidgetKit logs a warning and substitutes
        // its own opaque background.
        if #available(iOSApplicationExtension 17.0, *) {
            adaptive.containerBackground(.clear, for: .widget)
        } else {
            adaptive
        }
    }
}

/// Four single-purpose Lock Screen widgets — one per content kind — so each
/// appears as its own distinct, individually-addable entry in iOS's widget
/// gallery rather than one widget the user has to reconfigure after adding.

struct EslamyPrayerLockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "EslamyPrayerLockWidget",
            provider: EslamySingleKindProvider(kind: .prayer)
        ) { entry in
            EslamyAccessoryView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("Countdown to your next prayer time.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct EslamyAyahLockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "EslamyAyahLockWidget",
            provider: EslamySingleKindProvider(kind: .ayah)
        ) { entry in
            EslamyAccessoryView(entry: entry)
        }
        .configurationDisplayName("Ayah of the Day")
        .description("Today's verse from the Quran.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct EslamyDuaLockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "EslamyDuaLockWidget",
            provider: EslamySingleKindProvider(kind: .dua)
        ) { entry in
            EslamyAccessoryView(entry: entry)
        }
        .configurationDisplayName("Dua of the Day")
        .description("Today's supplication.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct EslamyHijriLockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "EslamyHijriLockWidget",
            provider: EslamySingleKindProvider(kind: .hijriDate)
        ) { entry in
            EslamyAccessoryView(entry: entry)
        }
        .configurationDisplayName("Hijri Date")
        .description("Today's Islamic date and the next upcoming occasion.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}
