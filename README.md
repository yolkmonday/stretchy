# 🌿 Stretch Reminder for LBP

Aplikasi desktop macOS untuk mengingatkan stretching bagi penderita Low Back Pain (LBP). App ini mendeteksi aktivitas mouse/trackpad secara system-wide — selama mouse masih bergerak, timer berjalan. Ketika user idle (sedang stretching), app mendeteksi dan menghitung sebagai stretching selesai.

## Cara Kerja

```
User aktif (mouse bergerak) → Timer countdown berjalan
  → Timer habis (misal 30 menit) → Reminder muncul + notifikasi macOS
    → User stretching (mouse idle 2+ menit) → Auto-detected ✅
    → User klik "Sudah Stretching" → Manual confirm ✅
    → User klik "Snooze" → Timer mundur 5/10 menit
  → Timer reset → Mulai lagi
```

## Tech Stack

- **Frontend**: React + Vite
- **Backend**: Rust (Tauri)
- **Mouse Monitoring**: `core-graphics` crate (CGEvent API macOS)
- **Notifikasi**: Tauri Notification API + macOS native notification

## Prerequisites

1. **Rust** (via rustup)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Node.js** (v18+)
   ```bash
   brew install node
   ```

3. **Tauri CLI**
   ```bash
   cargo install tauri-cli
   ```

4. **Xcode Command Line Tools** (untuk compile macOS native code)
   ```bash
   xcode-select --install
   ```

## Setup & Run

```bash
# Clone/download project
cd stretch-reminder

# Install frontend dependencies
npm install

# Run in development mode
cargo tauri dev

# Build for production
cargo tauri build
```

## macOS Permissions

App ini butuh permission **Accessibility** untuk monitor mouse secara system-wide:

1. Buka **System Settings → Privacy & Security → Accessibility**
2. Tambahkan app (atau Terminal saat development)
3. Jika diminta, restart app

Tanpa permission ini, app hanya bisa mendeteksi mouse di dalam window-nya sendiri.

## Fitur

### Timer & Monitoring
- ⏱️ Countdown timer dengan interval customizable (15-60 menit)
- 🖱️ Deteksi mouse/trackpad system-wide
- 💤 Deteksi idle otomatis (user sedang stretching)
- 🔔 Notifikasi desktop macOS native

### Stretching Library
- 8 gerakan stretching khusus LBP
- Instruksi step-by-step dalam Bahasa Indonesia
- Info target otot dan manfaat
- Mix gerakan lantai dan kursi

### System Tray
- App berjalan di menu bar
- Quick actions: Pause, Mark stretch done, Quit
- Klik untuk show/hide window

### Riwayat
- Tracking jumlah stretching harian
- Log waktu setiap stretching

## Struktur Project

```
stretch-reminder/
├── src-tauri/
│   ├── src/
│   │   ├── main.rs              # Tauri app, commands, event loop
│   │   └── activity_monitor.rs  # CGEvent mouse monitoring
│   ├── Cargo.toml
│   └── tauri.conf.json
├── src/
│   ├── App.jsx                  # Main React component
│   ├── main.jsx                 # Entry point
│   ├── styles.css               # UI styling
│   └── data/
│       └── exercises.js         # LBP stretching exercises
├── index.html
├── package.json
└── vite.config.js
```

## Gerakan Stretching Included

| Gerakan | Posisi | Durasi |
|---------|--------|--------|
| Cat-Cow Stretch | Lantai | 30 dtk |
| Knee-to-Chest | Lantai | 30 dtk |
| Seated Spinal Twist | Kursi ✅ | 30 dtk |
| Standing Back Extension | Berdiri ✅ | 20 dtk |
| Child's Pose | Lantai | 45 dtk |
| Piriformis Stretch | Kursi ✅ | 30 dtk |
| Pelvic Tilt | Lantai | 25 dtk |
| Hip Flexor Stretch | Lantai | 30 dtk |

✅ = Bisa dilakukan di tempat kerja tanpa tiduran

## Customization

### Ubah Interval
Klik ⚙️ di app → pilih interval (15-60 menit)

### Ubah Idle Threshold
Klik ⚙️ → sesuaikan berapa lama idle dianggap "sedang stretching" (1-5 menit)

### Tambah Gerakan
Edit `src/data/exercises.js` — tambahkan object baru mengikuti format yang ada.

## Troubleshooting

**Mouse monitoring tidak bekerja:**
- Pastikan Accessibility permission sudah diberikan
- Restart app setelah memberikan permission

**Notifikasi tidak muncul:**
- Cek System Settings → Notifications → Stretch Reminder
- Pastikan Do Not Disturb tidak aktif

**Build error core-graphics:**
- Pastikan Xcode CLI tools terinstall: `xcode-select --install`
- Pastikan target macOS: `rustup target add aarch64-apple-darwin` (untuk Apple Silicon)
