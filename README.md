# 🕌 Eslamy

A Flutter Islamic companion app: Quran reading and audio, prayer times and
Qibla, Hadith, daily Duas & Azkar, a Hifz (memorization) tracker, Hijri
calendar, a Hajj & Umrah guide, and a nearby-mosque locator — in Arabic,
English, and Italian.

## ✨ Features

- **Digital Mushaf** — browse by Surah, Juz, Hizb, or page; tajweed-colored
  text, per-ayah and full-surah audio playback with reciter selection,
  translations, and Al-Muyassar tafsir. Playback continues in the
  background with a persistent "now playing" mini-player and (on Android)
  a floating bubble.
- **Prayer Times & Qibla** — location-based prayer times with Adhan
  notifications, a compass-based Qibla direction, and a nearby-mosque
  locator (OpenStreetMap/Overpass, with an on-device cache so a flaky free
  API degrades to "last known results" instead of an empty screen).
- **Hadith** — browse hadith books with search, and save favorites locally.
- **Duas & Azkar**, **Tasbih counter**, **Hijri calendar**, **Hajj & Umrah
  guide**.
- **Hifz tracker** — mark Surahs memorized and track progress toward all
  114, plus a daily streak.
- **Settings** — light/dark/system theme, Arabic/English/Italian, an
  app-wide text-size slider, and a schedulable daily Wird reminder.
- Fully localized UI (RTL-aware) in Arabic, English, and Italian.

## 🛠️ Tech Stack

- **Flutter** / **Riverpod** for state management
- **Dio** for networking, **sqflite** + **shared_preferences** for local
  storage
- **just_audio** / **audio_service** for background Quran playback
- **Firebase** (Messaging + Crashlytics)
- **geolocator** / **flutter_compass** for prayer times, Qibla, and the
  mosque locator
- **flutter_local_notifications** + **workmanager** (Android) for Adhan
  alerts that survive a reboot

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.2+) and Dart SDK
- Xcode (iOS) / Android Studio (Android)
- Firebase project config: `ios/Runner/GoogleService-Info.plist` and
  `android/app/google-services.json` (not checked in — get these from the
  project's Firebase console)

### Installation

```bash
flutter pub get
flutter gen-l10n   # regenerate localization sources after editing lib/l10n/*.arb
flutter run
```

## 📱 App Structure

Feature-first layout under `lib/features/<feature>/`, each with its own
`models/`, `service/`, and `presentation/{controllers,pages,widgets}/`.
Cross-cutting code lives in `lib/core/` (localization, navigation, network,
notifications, theme) and `lib/shared/widgets/`.

```
lib/
├── core/                # localization, navigation, network, notifications, theme
├── features/
│   ├── quran/           # Mushaf, audio playback, tajweed, translations
│   ├── prayer_times/     # prayer times + Qibla
│   ├── mosque_locator/   # nearby mosques (Overpass + local cache)
│   ├── hadith/           # hadith books + search
│   ├── favorites/        # saved hadiths (SQLite)
│   ├── duas/             # duas & azkar
│   ├── tasbih/            # tasbih counter
│   ├── hifz/              # memorization tracker
│   ├── hijri_calendar/
│   ├── hajj_umrah/
│   ├── streaks/
│   ├── settings/          # theme, language, text size, Wird schedule
│   ├── home/, splash/, error/
└── main.dart
```

## 🧪 Testing

```bash
flutter analyze
flutter test
```

Test coverage is currently focused on pure logic (Overpass response
parsing, the mosque-locator cache, tajweed text parsing) rather than full
widget/integration coverage — see `test/` for what exists today.

## 🔭 Roadmap ideas

- [ ] Cloud sync for favorites / hifz progress
- [ ] Push notifications for new content
- [ ] Wider widget/integration test coverage

## 📄 License

No license file is currently included (`pubspec.yaml` marks the package
`publish_to: 'none'`, i.e. private). Add a `LICENSE` file once a license is
chosen.
