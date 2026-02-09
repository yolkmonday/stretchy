# Stretchy

허리 통증(LBP) 환자를 위해 설계된 스트레칭 알림 크로스 플랫폼 데스크톱 앱입니다.

**언어:** [English](README.md) | [Bahasa Indonesia](README_ID.md) | [中文](README_ZH.md) | [Bahasa Melayu](README_MS.md) | [日本語](README_JA.md) | [한국어](#)

## 작동 방식

Stretchy는 시스템 전체에서 활동(키보드, 마우스, 트랙패드, 스크롤 휠)을 모니터링합니다. 활동 중일 때 카운트다운 타이머가 작동합니다. 타이머가 0이 되면 스트레칭 알림을 받습니다. 충분히 오랫동안 유휴 상태가 되면 앱이 자동으로 스트레칭 중임을 감지합니다.

```
활동 중 (타이핑/마우스) → 카운트다운 실행
  → 타이머 종료 → 알림 + 통지
    → 2분 이상 유휴 → 스트레칭으로 자동 감지
    → "스트레칭 완료" 클릭 → 수동 확인
    → 다시 알림 → 5/10분 후 재알림
  → 타이머 초기화 → 반복
```

## 다운로드

[GitHub Releases](https://github.com/yolkmonday/stretchy/releases)에서 최신 릴리스를 다운로드하세요:

| 플랫폼 | 파일 |
|--------|------|
| macOS (Apple Silicon) | `.dmg` |
| macOS (Intel) | `.dmg` |
| Windows | `.msi` / `.exe` |
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (RedHat/Fedora) | `.rpm` |
| Linux (범용) | `.AppImage` |

## 기능

- **활동 감지** — 키보드, 마우스, 트랙패드, 스크롤 휠 모니터링
- **자동 스트레칭 감지** — 유휴 시간 기반으로 스트레칭 중인지 감지
- **8가지 허리 통증 운동** — 단계별 안내가 포함된 가이드 스트레칭
- **다국어 지원** — 영어, 인도네시아어, 중국어, 말레이어, 일본어, 한국어
- **시스템 트레이** — 상태 아이콘과 함께 백그라운드 실행
- **테마** — 다크, 라이트, 시스템 모드
- **설정 가능** — 알림 간격(15-60분) 및 유휴 임계값(1-5분) 조정
- **크로스 플랫폼** — macOS, Windows, Linux

## 스트레칭 운동

| 운동 | 자세 | 시간 |
|------|------|------|
| 캣카우 스트레칭 | 바닥 | 30초 |
| 무릎 가슴 당기기 | 바닥 | 30초 |
| 앉아서 척추 비틀기 | 의자 | 30초 |
| 서서 등 펴기 | 서기 | 20초 |
| 차일드 포즈 | 바닥 | 45초 |
| 이상근 스트레칭 | 의자 | 30초 |
| 골반 기울이기 | 바닥 | 25초 |
| 고관절 굴곡근 스트레칭 | 바닥 | 30초 |

## 개발

### 사전 요구 사항

- [Rust](https://rustup.rs/) (rustup 사용)
- [Node.js](https://nodejs.org/) (v18+)
- Tauri CLI: `cargo install tauri-cli`
- macOS: Xcode 명령줄 도구 (`xcode-select --install`)
- Linux: `sudo apt install libwebkit2gtk-4.0-dev librsvg2-dev patchelf libgtk-3-dev libayatana-appindicator3-dev`

### 실행

```bash
npm install
cargo tauri dev
```

### 빌드

```bash
cargo tauri build
```

## 권한

### macOS
앱은 시스템 전체 활동 모니터링을 위해 **손쉬운 사용** 권한이 필요합니다:
시스템 설정 → 개인 정보 보호 및 보안 → 손쉬운 사용 → 앱 추가

### Linux
유휴 감지를 위해 `xprintidle`을 설치하세요: `sudo apt install xprintidle`

## 기술 스택

- **프론트엔드**: React + Vite
- **백엔드**: Rust (Tauri)
- **활동 모니터**: CoreGraphics (macOS), GetLastInputInfo (Windows), xprintidle (Linux)

## 라이선스

MIT
