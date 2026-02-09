# Stretchy

腰痛（LBP）を抱える方のために設計された、ストレッチを促すクロスプラットフォームデスクトップアプリです。

**言語：** [English](README.md) | [Bahasa Indonesia](README_ID.md) | [中文](README_ZH.md) | [Bahasa Melayu](README_MS.md) | [日本語](#) | [한국어](README_KO.md)

## 仕組み

Stretchyはシステム全体であなたのアクティビティ（キーボード、マウス、トラックパッド、スクロールホイール）を監視します。アクティブな間はカウントダウンタイマーが動作します。タイマーがゼロになるとストレッチのリマインダーが届きます。十分な時間アイドル状態になると、アプリが自動的にストレッチ中であることを検出します。

```
アクティブ（タイピング/マウス）→ カウントダウン実行
  → タイマーゼロ → リマインダー + 通知
    → 2分以上アイドル → ストレッチとして自動検出
    → 「ストレッチ完了」をクリック → 手動確認
    → スヌーズ → 5/10分後に再通知
  → タイマーリセット → 繰り返し
```

## ダウンロード

[GitHub Releases](https://github.com/yolkmonday/stretchy/releases)から最新版をダウンロード：

| プラットフォーム | ファイル |
|-----------------|---------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (ユニバーサル) | `.AppImage` |

## 機能

- **アクティビティ検出** — キーボード、マウス、トラックパッド、スクロールホイールを監視
- **自動ストレッチ検出** — アイドル時間に基づきストレッチ中かを検出
- **8つの腰痛エクササイズ** — ステップバイステップの説明付きガイド付きストレッチ
- **多言語対応** — 英語、インドネシア語、中国語、マレー語、日本語、韓国語
- **システムトレイ** — ステータスアイコン付きでバックグラウンド実行
- **テーマ** — ダーク、ライト、システムモード
- **設定可能** — リマインド間隔（15-60分）とアイドル閾値（1-5分）を調整
- **クロスプラットフォーム** — macOS、Windows、Linux

## ストレッチエクササイズ

| エクササイズ | 姿勢 | 時間 |
|-------------|------|------|
| キャットカウストレッチ | 床 | 30秒 |
| 膝を胸に引き寄せる | 床 | 30秒 |
| 座位脊椎ツイスト | 椅子 | 30秒 |
| 立位バックエクステンション | 立位 | 20秒 |
| チャイルドポーズ | 床 | 45秒 |
| 梨状筋ストレッチ | 椅子 | 30秒 |
| ペルビックティルト | 床 | 25秒 |
| 股関節屈筋ストレッチ | 床 | 30秒 |

## 開発

### 前提条件

- [Rust](https://rustup.rs/)（rustup経由）
- [Node.js](https://nodejs.org/)（v18+）
- Tauri CLI：`cargo install tauri-cli`
- macOS：Xcodeコマンドラインツール（`xcode-select --install`）
- Linux：`sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### 実行

```bash
npm install
cargo tauri dev
```

### ビルド

```bash
cargo tauri build
```

## 権限

### macOS
アプリはシステム全体のアクティビティ監視のために**アクセシビリティ**権限が必要です：
システム設定 → プライバシーとセキュリティ → アクセシビリティ → アプリを追加

### Linux
アイドル検出のために`xprintidle`をインストール：`sudo apt install xprintidle`

## 技術スタック

- **フロントエンド**：React + Vite
- **バックエンド**：Rust (Tauri)
- **アクティビティモニター**：CoreGraphics (macOS)、GetLastInputInfo (Windows)、xprintidle (Linux)

## ライセンス

MIT
