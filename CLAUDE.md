# Project instructions

## Testing on emulators/simulators

Multiple Claude Code sessions may work on this repo at the same time. To avoid
sessions colliding on the same device (stepping on each other's app state,
hot reloads, or test runs), **each session must use its own dedicated
emulator/simulator instance when testing** — never attach to a device another
session already has booted.

Before launching a device to test something:

1. Check what's currently running:
   - Android: `flutter devices` or `emulator -list-avds` / `adb devices`
   - iOS: `xcrun simctl list devices booted`
2. If a device is already booted (and may be in use by another session), boot
   a **different** emulator/simulator instead of reusing it — pick another
   AVD, or boot an additional iOS Simulator (e.g. a different device model,
   or `xcrun simctl clone`/`boot` a second instance).
3. Use that dedicated device for the rest of the session's testing, and avoid
   killing devices you didn't boot yourself.
