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
./build-app.sh                 # dist/Stretchy.app + zip (universal)
SIGN_IDENTITY="Developer ID Application: …" NOTARIZE=1 ./build-app.sh
```

The old cross-platform Tauri version lives on the `tauri-legacy` branch.

## License

MIT
