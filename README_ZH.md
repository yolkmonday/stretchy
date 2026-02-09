# Stretchy

跨平台桌面应用，提醒您进行拉伸，专为腰痛（LBP）患者设计。

**语言：** [English](README.md) | [Bahasa Indonesia](README_ID.md) | [中文](#) | [Bahasa Melayu](README_MS.md) | [日本語](README_JA.md) | [한국어](README_KO.md)

## 工作原理

Stretchy 在系统级别监控您的活动（键盘、鼠标、触控板、滚轮）。当您活跃时，倒计时计时器运行。当计时器归零时，您会收到拉伸提醒。如果您空闲足够长时间，应用会自动检测到您正在拉伸。

```
活跃（打字/鼠标）→ 倒计时运行
  → 计时器归零 → 提醒 + 通知
    → 空闲 2+ 分钟 → 自动检测为正在拉伸
    → 点击"已完成拉伸" → 手动确认
    → 稍后提醒 → 5/10 分钟后再次提醒
  → 计时器重置 → 重复
```

## 下载

从 [GitHub Releases](https://github.com/yolkmonday/stretchy/releases) 下载最新版本：

| 平台 | 文件 |
|------|------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (通用) | `.AppImage` |

## 功能

- **活动检测** — 监控键盘、鼠标、触控板和滚轮
- **自动拉伸检测** — 根据空闲时间检测您是否在拉伸
- **8个腰痛练习** — 带有分步说明的引导式拉伸练习
- **多语言** — 英语、印尼语、中文、马来语、日语、韩语
- **系统托盘** — 在后台运行，带有状态图标
- **主题** — 深色、浅色和系统模式
- **可配置** — 调整提醒间隔（15-60分钟）和空闲阈值（1-5分钟）
- **跨平台** — macOS、Windows、Linux

## 拉伸练习

| 练习 | 姿势 | 时长 |
|------|------|------|
| 猫牛式伸展 | 地面 | 30秒 |
| 膝盖抱胸 | 地面 | 30秒 |
| 坐姿脊柱扭转 | 椅子 | 30秒 |
| 站立背部伸展 | 站立 | 20秒 |
| 婴儿式 | 地面 | 45秒 |
| 梨状肌拉伸 | 椅子 | 30秒 |
| 骨盆倾斜 | 地面 | 25秒 |
| 髋屈肌拉伸 | 地面 | 30秒 |

## 开发

### 先决条件

- [Rust](https://rustup.rs/)（通过 rustup）
- [Node.js](https://nodejs.org/)（v18+）
- Tauri CLI：`cargo install tauri-cli`
- macOS：Xcode 命令行工具（`xcode-select --install`）
- Linux：`sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### 运行

```bash
npm install
cargo tauri dev
```

### 构建

```bash
cargo tauri build
```

## 权限

### macOS
应用需要 **辅助功能** 权限来进行系统级活动监控：
系统设置 → 隐私与安全 → 辅助功能 → 添加应用

### Linux
安装 `xprintidle` 用于空闲检测：`sudo apt install xprintidle`

## 技术栈

- **前端**：React + Vite
- **后端**：Rust (Tauri)
- **活动监控**：CoreGraphics (macOS)、GetLastInputInfo (Windows)、xprintidle (Linux)

## 许可证

MIT
