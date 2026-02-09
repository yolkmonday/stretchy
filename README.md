# Stretchy

A cross-platform desktop app that reminds you to stretch, designed for people with Low Back Pain (LBP).

**Language / Bahasa:** [English](#) | [Bahasa Indonesia](README_ID.md) | [中文](README_ZH.md) | [Bahasa Melayu](README_MS.md) | [日本語](README_JA.md) | [한국어](README_KO.md)

## How It Works

Stretchy monitors your activity (keyboard, mouse, trackpad, scroll wheel) system-wide. While you're active, a countdown timer runs. When the timer reaches zero, you get a reminder to stretch. If you go idle long enough, the app auto-detects that you're stretching.

```
Active (typing/mouse) → Timer countdown runs
  → Timer reaches 0 → Reminder + notification
    → Idle for 2+ min → Auto-detected as stretching
    → Click "Done Stretching" → Manual confirm
    → Snooze → Remind again in 5/10 min
  → Timer resets → Repeat
```

## Download

Download the latest release from [GitHub Releases](https://github.com/yolkmonday/stretchy/releases):

| Platform | File |
|----------|------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (Universal) | `.AppImage` |

## Features

- **Activity Detection** — Monitors keyboard, mouse, trackpad, and scroll wheel
- **Auto Stretch Detection** — Detects when you're stretching based on idle time
- **8 LBP Exercises** — Guided stretching exercises with step-by-step instructions
- **Multi-Language** — English, Indonesian, Chinese, Malay, Japanese, Korean
- **System Tray** — Runs in the background with status icons
- **Themes** — Dark, Light, and System modes
- **Configurable** — Adjust reminder interval (15-60 min) and idle threshold (1-5 min)
- **Cross-Platform** — macOS, Windows, Linux

## Stretching Exercises

| Exercise | Position | Duration |
|----------|----------|----------|
| Cat-Cow Stretch | Floor | 30 sec |
| Knee-to-Chest | Floor | 30 sec |
| Seated Spinal Twist | Chair | 30 sec |
| Standing Back Extension | Standing | 20 sec |
| Child's Pose | Floor | 45 sec |
| Piriformis Stretch | Chair | 30 sec |
| Pelvic Tilt | Floor | 25 sec |
| Hip Flexor Stretch | Floor | 30 sec |

## Development

### Prerequisites

- [Rust](https://rustup.rs/) (via rustup)
- [Node.js](https://nodejs.org/) (v18+)
- Tauri CLI: `cargo install tauri-cli`
- macOS: Xcode Command Line Tools (`xcode-select --install`)
- Linux: `sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### Run

```bash
npm install
cargo tauri dev
```

### Build

```bash
cargo tauri build
```

## Permissions

### macOS
The app needs **Accessibility** permission for system-wide activity monitoring:
System Settings → Privacy & Security → Accessibility → Add the app

### Linux
Install `xprintidle` for idle detection: `sudo apt install xprintidle`

## Tech Stack

- **Frontend**: React + Vite
- **Backend**: Rust (Tauri)
- **Activity Monitor**: CoreGraphics (macOS), GetLastInputInfo (Windows), xprintidle (Linux)

## License

MIT
