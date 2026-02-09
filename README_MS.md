# Stretchy

Aplikasi desktop merentas platform yang mengingatkan anda untuk melakukan regangan, direka khas untuk penghidap sakit belakang bawah (LBP).

**Bahasa:** [English](README.md) | [Bahasa Indonesia](README_ID.md) | [中文](README_ZH.md) | [Bahasa Melayu](#) | [日本語](README_JA.md) | [한국어](README_KO.md)

## Cara Ia Berfungsi

Stretchy memantau aktiviti anda (papan kekunci, tetikus, pad jejak, roda tatal) secara keseluruhan sistem. Semasa anda aktif, pemasa undur berjalan. Apabila pemasa tamat, anda akan mendapat peringatan untuk melakukan regangan. Jika anda idle cukup lama, aplikasi mengesan secara automatik bahawa anda sedang melakukan regangan.

```
Aktif (menaip/tetikus) → Pemasa undur berjalan
  → Pemasa tamat → Peringatan + pemberitahuan
    → Idle 2+ minit → Dikesan sebagai regangan
    → Klik "Sudah Regangan" → Pengesahan manual
    → Tangguh → Ingatkan lagi 5/10 minit
  → Pemasa ditetapkan semula → Ulang
```

## Muat Turun

Muat turun keluaran terbaru dari [GitHub Releases](https://github.com/yolkmonday/stretchy/releases):

| Platform | Fail |
|----------|------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (Universal) | `.AppImage` |

## Ciri-ciri

- **Pengesanan Aktiviti** — Memantau papan kekunci, tetikus, pad jejak, dan roda tatal
- **Pengesanan Regangan Automatik** — Mengesan semasa anda melakukan regangan berdasarkan masa idle
- **8 Latihan LBP** — Senaman regangan berpandukan dengan arahan langkah demi langkah
- **Pelbagai Bahasa** — Inggeris, Indonesia, Cina, Melayu, Jepun, Korea
- **Dulang Sistem** — Berjalan di latar belakang dengan ikon status
- **Tema** — Mod Gelap, Cerah, dan Sistem
- **Boleh Dikonfigurasi** — Laraskan selang peringatan (15-60 min) dan ambang idle (1-5 min)
- **Merentas Platform** — macOS, Windows, Linux

## Senaman Regangan

| Senaman | Posisi | Tempoh |
|---------|--------|--------|
| Regangan Kucing-Lembu | Lantai | 30 saat |
| Regangan Lutut ke Dada | Lantai | 30 saat |
| Putaran Tulang Belakang Duduk | Kerusi | 30 saat |
| Ekstensi Belakang Berdiri | Berdiri | 20 saat |
| Pose Kanak-kanak | Lantai | 45 saat |
| Regangan Piriformis | Kerusi | 30 saat |
| Senget Pelvis | Lantai | 25 saat |
| Regangan Fleksor Pinggul | Lantai | 30 saat |

## Pembangunan

### Prasyarat

- [Rust](https://rustup.rs/) (melalui rustup)
- [Node.js](https://nodejs.org/) (v18+)
- Tauri CLI: `cargo install tauri-cli`
- macOS: Xcode Command Line Tools (`xcode-select --install`)
- Linux: `sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### Jalankan

```bash
npm install
cargo tauri dev
```

### Bina

```bash
cargo tauri build
```

## Kebenaran

### macOS
Aplikasi memerlukan kebenaran **Kebolehcapaian** untuk pemantauan aktiviti seluruh sistem:
System Settings → Privacy & Security → Accessibility → Tambah aplikasi

### Linux
Pasang `xprintidle` untuk pengesanan idle: `sudo apt install xprintidle`

## Tindanan Teknologi

- **Frontend**: React + Vite
- **Backend**: Rust (Tauri)
- **Pemantau Aktiviti**: CoreGraphics (macOS), GetLastInputInfo (Windows), xprintidle (Linux)

## Lesen

MIT
