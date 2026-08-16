# Privacy Policy — Eslamy

_Last updated: [fill in date before publishing]_

This is a starting-point draft based on what the app actually does as of
this commit. **It has not been reviewed by a lawyer** — read it against the
real data flows before publishing it, and update it any time a new
data-collecting feature (e.g. analytics, accounts, cloud sync) is added.

## Who this covers

Eslamy ("the app") is developed by [your name / company]. Contact:
ahmedtahaelelemy@gmail.com.

## Data the app collects

### Location
Used to calculate prayer times, the Qibla direction, and nearby mosques.
Your coordinates are sent, per request, to:
- [Aladhan API](https://aladhan.com/prayer-times-api) (prayer times, Qibla)
- [Overpass API](https://overpass-api.de) / OpenStreetMap (nearby mosques)

Location is not stored on any server the app controls. On-device, the last
known position and the last successful mosque search are cached locally
(see "Local storage") so the app still has something to show if a lookup
fails.

### Push notification token
The app registers a Firebase Cloud Messaging token with Firebase so it can
receive push notifications. This token identifies the device/app install,
not a named individual.

### Crash and error reports
The app uses Firebase Crashlytics to send crash reports and non-fatal
error details (stack traces, device model, OS version, app version) when
something goes wrong, so issues can be fixed. This is disabled in debug
builds.

### Local storage (stays on your device)
The following never leaves your device unless you explicitly export/share
it: favorited hadiths, Hifz (memorization) progress, streak history, and
app settings (theme, language, text size, selected reciter, notification
preferences).

## Third-party services

| Service | Purpose | Data sent |
|---|---|---|
| Aladhan API | Prayer times, Qibla direction | Latitude/longitude |
| Overpass API (OpenStreetMap) | Nearby mosque search | Latitude/longitude |
| hadithapi.com | Hadith content | None (read-only content fetch) |
| Firebase Cloud Messaging | Push notifications | Device push token |
| Firebase Crashlytics | Crash/error reporting | Crash reports, device/app metadata |

Each of these is a separate service with its own privacy policy; the app
does not control how they handle data once it's sent.

## What the app does not do

- No account creation or sign-in.
- No sale of personal data.
- No advertising SDKs.
- No analytics beyond crash/error reporting.

## Permissions requested

- **Location (while using the app)** — prayer times, Qibla, mosque
  locator.
- **Notifications** — Adhan (prayer time) alerts.
- **"Display over other apps" (Android only)** — the floating Quran
  playback bubble; only requested the first time you start audio playback,
  and only if you allow it.

## Your choices

- Location, notification, and overlay permissions can be revoked at any
  time from your device's system settings; the relevant features degrade
  gracefully (e.g. a manual-location fallback for prayer times) rather
  than crashing.
- Favorites and Hifz progress can be cleared from within the app.

## Changes to this policy

This file will be updated when data collection changes; check the
"Last updated" date above.
