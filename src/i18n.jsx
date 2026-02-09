import { createContext, useContext, useState, useCallback } from "react";

const translations = {
  en: {
    // Tabs
    tabTimer: "Timer",
    tabExercises: "Exercises",
    tabHistory: "History",

    // Theme
    themeSystem: "System",
    themeLight: "Light",
    themeDark: "Dark",

    // Timer
    timeToStretch: "Time to stretch!",
    youAreResting: "You are resting",
    untilStretch: "until stretch",

    // Units
    seconds: "sec",
    min: "min",

    // Reminder modal
    reminderTitle: "Time to Stretch!",
    reminderDesc:
      "You've been sitting too long. Let's do some stretching to reduce lower back pain.",
    doneStretching: "Done Stretching!",
    remindIn5: "Remind me in 5 minutes",
    remindIn10: "Later in 10 minutes",

    // Settings
    reminderInterval: "Reminder Interval",
    reminderIntervalDesc: "Sitting time before reminder",
    stretchDetection: "Stretch Detection",
    stretchDetectionDesc: "Idle time = stretching",
    monitoring: "Monitoring",
    activelyMonitoring: "Actively monitoring",
    paused: "Paused",
    pause: "Pause",
    start: "Start",
    language: "Language",
    languageDesc: "App display language",

    // Stats
    stretching: "Stretches",
    interval: "Interval",
    idleGoal: "Idle Goal",

    // Sections
    nextExercise: "Next Exercise",
    allExercises: "All LBP Stretching Exercises",
    monitoringActivity: "Monitoring activity",

    // History
    todayHistory: "Today's History",
    noStretchYet: "No stretches today yet.",
    startFirstStretch: "Start your first stretch!",
    timesStretchedToday: "stretches today",
    stretchTimes: "Stretch Times",

    // Settings button
    settings: "Settings",
  },

  id: {
    tabTimer: "Timer",
    tabExercises: "Gerakan",
    tabHistory: "Riwayat",

    themeSystem: "Sistem",
    themeLight: "Light",
    themeDark: "Dark",

    timeToStretch: "Waktunya stretching!",
    youAreResting: "Kamu sedang istirahat",
    untilStretch: "sampai stretching",

    seconds: "detik",
    min: "mnt",

    reminderTitle: "Waktunya Stretching!",
    reminderDesc:
      "Kamu sudah duduk terlalu lama. Yuk lakukan peregangan untuk mengurangi nyeri punggung bawah.",
    doneStretching: "Sudah Stretching!",
    remindIn5: "Ingatkan 5 menit lagi",
    remindIn10: "Nanti 10 menit",

    reminderInterval: "Interval Pengingat",
    reminderIntervalDesc: "Waktu duduk sebelum diingatkan",
    stretchDetection: "Deteksi Stretching",
    stretchDetectionDesc: "Idle time = sedang stretching",
    monitoring: "Monitoring",
    activelyMonitoring: "Sedang aktif memantau",
    paused: "Dijeda",
    pause: "Jeda",
    start: "Mulai",
    language: "Bahasa",
    languageDesc: "Bahasa tampilan aplikasi",

    stretching: "Stretching",
    interval: "Interval",
    idleGoal: "Idle Goal",

    nextExercise: "Latihan Berikutnya",
    allExercises: "Semua Gerakan Stretching LBP",
    monitoringActivity: "Memantau aktivitas",

    todayHistory: "Riwayat Hari Ini",
    noStretchYet: "Belum ada stretching hari ini.",
    startFirstStretch: "Mulai stretching pertamamu!",
    timesStretchedToday: "kali stretching hari ini",
    stretchTimes: "Waktu Stretching",

    settings: "Settings",
  },

  zh: {
    tabTimer: "计时器",
    tabExercises: "动作",
    tabHistory: "历史",

    themeSystem: "系统",
    themeLight: "浅色",
    themeDark: "深色",

    timeToStretch: "该拉伸了！",
    youAreResting: "你正在休息",
    untilStretch: "距离拉伸",

    seconds: "秒",
    min: "分钟",

    reminderTitle: "该拉伸了！",
    reminderDesc: "你已经坐太久了。做一些拉伸来缓解腰痛吧。",
    doneStretching: "已完成拉伸！",
    remindIn5: "5分钟后提醒我",
    remindIn10: "10分钟后再说",

    reminderInterval: "提醒间隔",
    reminderIntervalDesc: "坐多久后提醒",
    stretchDetection: "拉伸检测",
    stretchDetectionDesc: "空闲时间 = 正在拉伸",
    monitoring: "监控",
    activelyMonitoring: "正在监控活动",
    paused: "已暂停",
    pause: "暂停",
    start: "开始",
    language: "语言",
    languageDesc: "应用显示语言",

    stretching: "拉伸次数",
    interval: "间隔",
    idleGoal: "空闲目标",

    nextExercise: "下一个动作",
    allExercises: "所有腰痛拉伸动作",
    monitoringActivity: "正在监控活动",

    todayHistory: "今日记录",
    noStretchYet: "今天还没有拉伸。",
    startFirstStretch: "开始你的第一次拉伸！",
    timesStretchedToday: "次拉伸",
    stretchTimes: "拉伸时间",

    settings: "设置",
  },

  ms: {
    tabTimer: "Pemasa",
    tabExercises: "Senaman",
    tabHistory: "Sejarah",

    themeSystem: "Sistem",
    themeLight: "Cerah",
    themeDark: "Gelap",

    timeToStretch: "Masa untuk regangan!",
    youAreResting: "Anda sedang berehat",
    untilStretch: "sehingga regangan",

    seconds: "saat",
    min: "min",

    reminderTitle: "Masa untuk Regangan!",
    reminderDesc:
      "Anda sudah duduk terlalu lama. Jom buat regangan untuk mengurangkan sakit belakang bawah.",
    doneStretching: "Sudah Regangan!",
    remindIn5: "Ingatkan 5 minit lagi",
    remindIn10: "Nanti 10 minit",

    reminderInterval: "Selang Peringatan",
    reminderIntervalDesc: "Masa duduk sebelum diingatkan",
    stretchDetection: "Pengesanan Regangan",
    stretchDetectionDesc: "Masa idle = sedang regangan",
    monitoring: "Pemantauan",
    activelyMonitoring: "Sedang memantau aktiviti",
    paused: "Dijeda",
    pause: "Jeda",
    start: "Mula",
    language: "Bahasa",
    languageDesc: "Bahasa paparan aplikasi",

    stretching: "Regangan",
    interval: "Selang",
    idleGoal: "Sasaran Idle",

    nextExercise: "Senaman Seterusnya",
    allExercises: "Semua Senaman Regangan LBP",
    monitoringActivity: "Memantau aktiviti",

    todayHistory: "Sejarah Hari Ini",
    noStretchYet: "Belum ada regangan hari ini.",
    startFirstStretch: "Mulakan regangan pertama anda!",
    timesStretchedToday: "kali regangan hari ini",
    stretchTimes: "Masa Regangan",

    settings: "Tetapan",
  },

  ja: {
    tabTimer: "タイマー",
    tabExercises: "エクササイズ",
    tabHistory: "履歴",

    themeSystem: "システム",
    themeLight: "ライト",
    themeDark: "ダーク",

    timeToStretch: "ストレッチの時間です！",
    youAreResting: "休憩中です",
    untilStretch: "ストレッチまで",

    seconds: "秒",
    min: "分",

    reminderTitle: "ストレッチの時間です！",
    reminderDesc:
      "長時間座っています。腰痛を軽減するためにストレッチをしましょう。",
    doneStretching: "ストレッチ完了！",
    remindIn5: "5分後にリマインド",
    remindIn10: "10分後にする",

    reminderInterval: "リマインド間隔",
    reminderIntervalDesc: "リマインドまでの座り時間",
    stretchDetection: "ストレッチ検出",
    stretchDetectionDesc: "アイドル時間 = ストレッチ中",
    monitoring: "モニタリング",
    activelyMonitoring: "アクティビティを監視中",
    paused: "一時停止中",
    pause: "一時停止",
    start: "開始",
    language: "言語",
    languageDesc: "アプリの表示言語",

    stretching: "ストレッチ",
    interval: "間隔",
    idleGoal: "アイドル目標",

    nextExercise: "次のエクササイズ",
    allExercises: "すべての腰痛ストレッチ",
    monitoringActivity: "アクティビティを監視中",

    todayHistory: "今日の履歴",
    noStretchYet: "今日はまだストレッチしていません。",
    startFirstStretch: "最初のストレッチを始めましょう！",
    timesStretchedToday: "回ストレッチ",
    stretchTimes: "ストレッチ時間",

    settings: "設定",
  },

  ko: {
    tabTimer: "타이머",
    tabExercises: "운동",
    tabHistory: "기록",

    themeSystem: "시스템",
    themeLight: "라이트",
    themeDark: "다크",

    timeToStretch: "스트레칭 시간입니다!",
    youAreResting: "쉬고 있습니다",
    untilStretch: "스트레칭까지",

    seconds: "초",
    min: "분",

    reminderTitle: "스트레칭 시간입니다!",
    reminderDesc:
      "너무 오래 앉아 있었습니다. 허리 통증을 줄이기 위해 스트레칭을 합시다.",
    doneStretching: "스트레칭 완료!",
    remindIn5: "5분 후 알림",
    remindIn10: "10분 후에",

    reminderInterval: "알림 간격",
    reminderIntervalDesc: "알림까지의 앉은 시간",
    stretchDetection: "스트레칭 감지",
    stretchDetectionDesc: "유휴 시간 = 스트레칭 중",
    monitoring: "모니터링",
    activelyMonitoring: "활동 모니터링 중",
    paused: "일시 정지",
    pause: "일시 정지",
    start: "시작",
    language: "언어",
    languageDesc: "앱 표시 언어",

    stretching: "스트레칭",
    interval: "간격",
    idleGoal: "유휴 목표",

    nextExercise: "다음 운동",
    allExercises: "모든 허리 통증 스트레칭",
    monitoringActivity: "활동 모니터링 중",

    todayHistory: "오늘의 기록",
    noStretchYet: "오늘 아직 스트레칭을 하지 않았습니다.",
    startFirstStretch: "첫 번째 스트레칭을 시작하세요!",
    timesStretchedToday: "회 스트레칭",
    stretchTimes: "스트레칭 시간",

    settings: "설정",
  },
};

export const LANGUAGES = [
  { code: "en", label: "English" },
  { code: "id", label: "Bahasa Indonesia" },
  { code: "zh", label: "中文" },
  { code: "ms", label: "Bahasa Melayu" },
  { code: "ja", label: "日本語" },
  { code: "ko", label: "한국어" },
];

const LanguageContext = createContext();

export function LanguageProvider({ children }) {
  const [lang, setLang] = useState(() => localStorage.getItem("lang") || "en");

  const changeLang = useCallback((code) => {
    setLang(code);
    localStorage.setItem("lang", code);
  }, []);

  const t = useCallback(
    (key) => {
      return translations[lang]?.[key] || translations.en[key] || key;
    },
    [lang],
  );

  return (
    <LanguageContext.Provider value={{ lang, changeLang, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  return useContext(LanguageContext);
}
