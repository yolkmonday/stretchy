# Stretchy

Native macOS menu bar app that reminds you to stretch, designed for people with Low Back Pain (LBP).

- Menu bar countdown (`🧘 23m`), no Dock icon
- Full-screen reminder with a guided, illustrated exercise: 17 desk-friendly stretches covering the whole body (neck, shoulders, chest, wrists, upper/lower back, hips, thighs, calves), rotated so each reminder targets a different area
- 10 s get-ready preview, then paced counts per move (breathing cues, reps, per-side)
- Presence detection, no permissions needed:
  - typing / mouse / trackpad = sitting, timer runs
  - video playing or microphone in use (calls) = still sitting even without input
  - in a call when a reminder is due = held until the call ends
  - screen locked / display asleep, or no activity for the idle threshold = away; counts as a break and resets the timer
- Snooze 5/10 min (Esc = 5 min), pause, launch at login
- English / Bahasa Indonesia (follows system language)
- No Accessibility permission needed

Requires macOS 14+.

## Build

```bash
swift run                      # dev
.build/debug/Stretchy --selftest
./build-app.sh                 # dist/Stretchy.app + .dmg + .pkg (universal)
SIGN_IDENTITY="Developer ID Application: …" NOTARIZE=1 ./build-app.sh
```

## Release

Push a tag (`git tag v0.6.0 && git push origin v0.6.0`). `.github/workflows/release.yml` builds, signs, notarizes and publishes the `.dmg` + `.pkg`, then bumps the `yolkmonday/tap/stretchy` cask.

Secrets: `APPLE_CERTIFICATE` (base64 p12), `APPLE_CERTIFICATE_PASSWORD`, `APPLE_ID`, `APPLE_PASSWORD` (app-specific), `APPLE_TEAM_ID`, `HOMEBREW_TAP_TOKEN` (optional, push access to `homebrew-tap`). The `.pkg` is signed and notarized only if the p12 also holds a "Developer ID Installer" cert.

The old cross-platform Tauri version lives on the `tauri-legacy` branch.

## License

MIT
