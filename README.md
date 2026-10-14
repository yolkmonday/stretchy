# Stretchy

Native macOS menu bar app that reminds you to stretch, designed for people with Low Back Pain (LBP).

- Menu bar countdown (`🧘 23m`), no Dock icon
- Full-screen reminder on every display with a guided exercise (8 LBP stretches)
- Countdown only runs while you're active; stepping away for the idle threshold counts as a break and closes the reminder
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
