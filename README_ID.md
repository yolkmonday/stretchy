# Stretchy

Aplikasi desktop lintas platform yang mengingatkan kamu untuk stretching, dirancang untuk penderita Low Back Pain (LBP).

**Bahasa:** [English](README.md) | [Bahasa Indonesia](#) | [中文](README_ZH.md) | [Bahasa Melayu](README_MS.md) | [日本語](README_JA.md) | [한국어](README_KO.md)

## Cara Kerja

Stretchy memantau aktivitas kamu (keyboard, mouse, trackpad, scroll wheel) secara system-wide. Selama kamu aktif, timer countdown berjalan. Ketika timer habis, kamu akan mendapat pengingat untuk stretching. Jika kamu idle cukup lama, app otomatis mendeteksi bahwa kamu sedang stretching.

```
Aktif (mengetik/mouse) → Timer countdown berjalan
  → Timer habis → Pengingat + notifikasi
    → Idle 2+ menit → Otomatis terdeteksi stretching
    → Klik "Sudah Stretching" → Konfirmasi manual
    → Snooze → Ingatkan lagi 5/10 menit
  → Timer reset → Ulangi
```

## Download

Download rilis terbaru dari [GitHub Releases](https://github.com/yolkmonday/stretchy/releases):

| Platform | File |
|----------|------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (Universal) | `.AppImage` |

## Fitur

- **Deteksi Aktivitas** — Memantau keyboard, mouse, trackpad, dan scroll wheel
- **Deteksi Stretching Otomatis** — Mendeteksi saat kamu stretching berdasarkan waktu idle
- **8 Latihan LBP** — Gerakan stretching dengan instruksi langkah demi langkah
- **Multi-Bahasa** — Inggris, Indonesia, Mandarin, Melayu, Jepang, Korea
- **System Tray** — Berjalan di background dengan ikon status
- **Tema** — Mode Dark, Light, dan System
- **Dapat Dikonfigurasi** — Atur interval pengingat (15-60 mnt) dan batas idle (1-5 mnt)
- **Lintas Platform** — macOS, Windows, Linux

## Gerakan Stretching

| Gerakan | Posisi | Durasi |
|---------|--------|--------|
| Peregangan Kucing-Sapi | Lantai | 30 dtk |
| Lutut ke Dada | Lantai | 30 dtk |
| Rotasi Tulang Belakang Duduk | Kursi | 30 dtk |
| Ekstensi Punggung Berdiri | Berdiri | 20 dtk |
| Pose Anak | Lantai | 45 dtk |
| Peregangan Piriformis | Kursi | 30 dtk |
| Tilt Pelvis | Lantai | 25 dtk |
| Peregangan Fleksor Pinggul | Lantai | 30 dtk |

## Development

### Prasyarat

- [Rust](https://rustup.rs/) (via rustup)
- [Node.js](https://nodejs.org/) (v18+)
- Tauri CLI: `cargo install tauri-cli`
- macOS: Xcode Command Line Tools (`xcode-select --install`)
- Linux: `sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### Jalankan

```bash
npm install
cargo tauri dev
```

### Build

```bash
cargo tauri build
```

## Izin

### macOS
App membutuhkan izin **Accessibility** untuk memantau aktivitas secara system-wide:
System Settings → Privacy & Security → Accessibility → Tambahkan app

### Linux
Install `xprintidle` untuk deteksi idle: `sudo apt install xprintidle`

## Tech Stack

- **Frontend**: React + Vite
- **Backend**: Rust (Tauri)
- **Activity Monitor**: CoreGraphics (macOS), GetLastInputInfo (Windows), xprintidle (Linux)

## Lisensi

MIT
