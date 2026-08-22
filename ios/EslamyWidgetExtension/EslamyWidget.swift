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

    /// Matches WidgetContentKind.storageKey on the Flutter side — the token
    /// used inside the `widget_enabled_kinds` CSV list written by
    /// WidgetDataService.pushEnabledKinds.
    var storageKey: String {
        switch self {
        case .prayer: return "prayer"
        case .ayah: return "ayah"
        case .dua: return "dua"
        case .hijriDate: return "hijri"
        }
    }
}

/// The kinds the user has switched on in-app (WidgetCustomizationPage),
/// falling back to every kind if the preference hasn't synced yet (e.g.
/// right after install) or came back empty/unparseable.
func enabledKinds() -> [EslamyWidgetKind] {
    let defaults = UserDefaults(suiteName: appGroupId)
    guard let raw = defaults?.string(forKey: "widget_enabled_kinds"), !raw.isEmpty else {
        return EslamyWidgetKind.allCases
    }
    let tokens = Set(raw.split(separator: ",").map(String.init))
    let kinds = EslamyWidgetKind.allCases.filter { tokens.contains($0.storageKey) }
    return kinds.isEmpty ? EslamyWidgetKind.allCases : kinds
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

/// One column of the Prayer card's schedule row — mirrors
/// WidgetContentBuilder.prayerSchedule / PrayerScheduleEntry on the Flutter
/// side and eslamy_widget_prayer_layout.xml's 5-cell row on Android.
struct EslamyPrayerScheduleEntry {
    let name: String
    let time: String
    let isNext: Bool
}

/// Reads the structured schedule WidgetDataService.pushPrayerSchedule wrote
/// (widget_prayer_names/times/next_index — comma-joined, same order),
/// empty until the app has synced at least once.
func prayerSchedule() -> [EslamyPrayerScheduleEntry] {
    let defaults = UserDefaults(suiteName: appGroupId)
    guard let namesRaw = defaults?.string(forKey: "widget_prayer_names"), !namesRaw.isEmpty,
          let timesRaw = defaults?.string(forKey: "widget_prayer_times"), !timesRaw.isEmpty else {
        return []
    }
    let names = namesRaw.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
    let times = timesRaw.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
    let nextIndex = defaults?.integer(forKey: "widget_prayer_next_index") ?? -1
    return zip(names, times).enumerated().map { i, pair in
        EslamyPrayerScheduleEntry(name: pair.0, time: pair.1, isNext: i == nextIndex)
    }
}

/// Today's real Gregorian date (e.g. "Sat 22 Aug"), see
/// WidgetContentBuilder.prayerDateCompact on the Flutter side.
func prayerDate() -> String {
    UserDefaults(suiteName: appGroupId)?.string(forKey: "widget_prayer_date") ?? ""
}

struct EslamyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> EslamyWidgetEntry {
        EslamyWidgetEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (EslamyWidgetEntry) -> Void) {
        completion(EslamyWidgetEntry(date: Date(), content: content(for: .ayah)))
    }

    /// Rotates through the user's enabled kinds (WidgetCustomizationPage)
    /// every 3 hours across the next 24h, so the widget keeps cycling on its
    /// own even if the app is never reopened. Each precomputed entry
    /// re-reads whatever Flutter most recently wrote to the App Group at the
    /// time this timeline is built; the app also calls
    /// WidgetCenter.reloadTimelines (via HomeWidget.updateWidget) whenever
    /// it has fresher data — including a changed enabled-kinds selection —
    /// which regenerates this timeline immediately instead of waiting.
    func getTimeline(in context: Context, completion: @escaping (Timeline<EslamyWidgetEntry>) -> Void) {
        let now = Date()
        let hoursPerSlot = 3
        let slotCount = 24 / hoursPerSlot
        let kinds = enabledKinds()
        let entries: [EslamyWidgetEntry] = (0..<slotCount).map { i in
            let date = Calendar.current.date(byAdding: .hour, value: i * hoursPerSlot, to: now) ?? now
            let kind = kinds[i % kinds.count]
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

    /// Light parchment card background behind [EslamyPrayerCardView] — see
    /// eslamy_widget_prayer_card_background.xml on Android for the same
    /// #FFFCF6 fill.
    private var prayerCardBackground: Color {
        Color(red: 1.0, green: 0.988, blue: 0.965)
    }

    var body: some View {
        // iOS 17 deprecated a plain view background behind widget content in
        // favor of containerBackground (needed for the new removable-
        // background home screen); older OS versions don't have that API at
        // all, hence the availability split rather than always calling it.
        //
        // The Prayer kind gets its own light-card layout (matching
        // eslamy_widget_prayer_layout.xml / EslamyWidgetProvider.kt on
        // Android and _PrayerWidgetPreview in the Flutter in-app preview)
        // instead of the shared teal gradient card every other kind uses.
        if entry.content.kind == .prayer {
            let card = EslamyPrayerCardView(
                content: entry.content,
                schedule: prayerSchedule(),
                date: prayerDate()
            )
            if #available(iOSApplicationExtension 17.0, *) {
                card.containerBackground(for: .widget) { prayerCardBackground }
            } else {
                card.background(prayerCardBackground)
            }
        } else if #available(iOSApplicationExtension 17.0, *) {
            foreground.containerBackground(for: .widget) { gradient }
        } else {
            foreground.background(gradient)
        }
    }
}

/// Mirrors eslamy_widget_prayer_layout.xml / EslamyWidgetProvider.kt on
/// Android and _PrayerWidgetPreview in widget_customization_page.dart: light
/// parchment card, muted header (icon/kicker/date), bold ink next-prayer
/// line, and a schedule band with a dark teal pill on the current prayer.
/// Used only for [EslamyWidgetKind.prayer] — every other kind keeps the
/// shared teal gradient card above.
struct EslamyPrayerCardView: View {
    var content: EslamyWidgetContent
    var schedule: [EslamyPrayerScheduleEntry]
    var date: String

    private let muted = Color(red: 0.420, green: 0.451, blue: 0.435)
    private let ink = Color(red: 0.110, green: 0.165, blue: 0.149)
    private let band = Color(red: 0.945, green: 0.922, blue: 0.878)
    private let activePill = Color(red: 0.043, green: 0.239, blue: 0.196)
    private let border = Color(red: 0.902, green: 0.875, blue: 0.824)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: content.kind.systemImageName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(muted)
                Text(content.kicker)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(muted)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(muted)
                    .lineLimit(1)
            }
            Text(content.primary)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ink)
                .lineLimit(1)
            if !schedule.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(schedule.enumerated()), id: \.offset) { _, entry in
                        VStack(spacing: 3) {
                            Text(entry.name)
                                .font(.system(size: 10))
                                .foregroundColor(entry.isNext ? ink : muted)
                                .lineLimit(1)
                            Text(entry.time)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(entry.isNext ? .white : ink)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(entry.isNext ? activePill : Color.clear)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 16).fill(band))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(border, lineWidth: 1))
    }
}

struct EslamyWidget: Widget {
    let kind: String = "EslamyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EslamyWidgetProvider()) { entry in
            EslamyWidgetView(entry: entry)
        }
        .configurationDisplayName("Eslamy")
        .description("Rotates between the content kinds enabled in the app: next prayer, ayah of the day, dua of the day, and today's Hijri date.")
        .supportedFamilies([.systemMedium])
    }
}
