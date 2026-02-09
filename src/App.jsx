import { useState, useEffect, useCallback } from "react";
import { invoke } from "@tauri-apps/api/tauri";
import { listen } from "@tauri-apps/api/event";
import { Icon } from "@iconify/react";
import { exercises, getQuickExercise, getSessionExercises } from "./exercises";

const TABS = ["Timer", "Gerakan", "Riwayat"];
const THEME_CYCLE = ["system", "light", "dark"];
const THEME_ICONS = {
  system: "solar:monitor-bold-duotone",
  light: "solar:sun-bold-duotone",
  dark: "solar:moon-bold-duotone",
};
const THEME_LABELS = {
  system: "Sistem",
  light: "Light",
  dark: "Dark",
};

function formatTime(totalSecs) {
  const mins = Math.floor(totalSecs / 60);
  const secs = totalSecs % 60;
  return `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;
}

function TimerRing({ elapsed, total, isIdle, reminderShowing }) {
  const radius = 88;
  const circumference = 2 * Math.PI * radius;
  const progress = Math.min(elapsed / total, 1);
  const offset = circumference - progress * circumference;

  let colorClass = "";
  if (progress > 0.9 || reminderShowing) colorClass = "danger";
  else if (progress > 0.7) colorClass = "warning";

  return (
    <div className="timer-ring-container">
      <svg width="200" height="200" viewBox="0 0 200 200">
        <circle className="timer-ring-bg" cx="100" cy="100" r={radius} />
        <circle
          className={`timer-ring-progress ${colorClass}`}
          cx="100"
          cy="100"
          r={radius}
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
      </svg>
      <div className="timer-center">
        <div className="timer-time">{formatTime(total - elapsed)}</div>
        <div className="timer-label">
          {reminderShowing
            ? "Waktunya stretching!"
            : isIdle
              ? "Kamu sedang istirahat"
              : "sampai stretching"}
        </div>
      </div>
    </div>
  );
}

function ExerciseCard({ exercise }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div
      className={`exercise-card ${expanded ? "expanded" : ""}`}
      onClick={() => setExpanded(!expanded)}
    >
      <div className="exercise-header">
        <div className="exercise-emoji">
          <Icon icon={exercise.icon} width={28} />
        </div>
        <div className="exercise-info">
          <div className="exercise-name">{exercise.nameId}</div>
          <div className="exercise-meta">
            {exercise.reps} · {exercise.duration} detik
          </div>
        </div>
      </div>

      {expanded && (
        <div className="exercise-details">
          <ul className="exercise-steps">
            {exercise.steps.map((step, i) => (
              <li key={i}>{step}</li>
            ))}
          </ul>
          <div className="exercise-target">
            <strong>Target:</strong> {exercise.targetMuscle}
            <br />
            <strong>Manfaat:</strong> {exercise.benefit}
          </div>
        </div>
      )}
    </div>
  );
}

function ReminderModal({ exercise, onDone, onSnooze }) {
  return (
    <div className="reminder-overlay">
      <div className="reminder-modal">
        <div className="reminder-emoji">
          <Icon icon="solar:stretching-round-bold-duotone" width={56} />
        </div>
        <h2>Waktunya Stretching!</h2>
        <p>
          Kamu sudah duduk terlalu lama. Yuk lakukan peregangan untuk mengurangi
          nyeri punggung bawah.
        </p>

        {exercise && (
          <div className="reminder-exercise">
            <h3>
              <Icon
                icon={exercise.icon}
                width={18}
                style={{ verticalAlign: "middle", marginRight: 6 }}
              />
              {exercise.nameId}
            </h3>
            <div className="exercise-meta" style={{ marginTop: 4 }}>
              {exercise.reps} · {exercise.duration} detik
            </div>
            <ul className="exercise-steps" style={{ marginTop: 10 }}>
              {exercise.steps.map((step, i) => (
                <li key={i}>{step}</li>
              ))}
            </ul>
          </div>
        )}

        <div className="reminder-actions">
          <button className="btn btn-primary" onClick={onDone}>
            <Icon
              icon="solar:check-circle-bold-duotone"
              width={18}
              style={{ verticalAlign: "middle", marginRight: 6 }}
            />
            Sudah Stretching!
          </button>
          <button className="btn btn-secondary" onClick={() => onSnooze(5)}>
            <Icon
              icon="solar:alarm-bold-duotone"
              width={18}
              style={{ verticalAlign: "middle", marginRight: 6 }}
            />
            Ingatkan 5 menit lagi
          </button>
          <button className="btn btn-ghost" onClick={() => onSnooze(10)}>
            Nanti 10 menit
          </button>
        </div>
      </div>
    </div>
  );
}

function SettingsPanel({ state, onSetInterval, onSetIdle, onToggle }) {
  return (
    <div className="settings-panel">
      <div className="setting-item">
        <div>
          <div className="setting-label">Interval Pengingat</div>
          <div className="setting-desc">Waktu duduk sebelum diingatkan</div>
        </div>
        <div className="setting-control">
          <select
            value={state.interval_minutes}
            onChange={(e) => onSetInterval(Number(e.target.value))}
          >
            <option value={15}>15 mnt</option>
            <option value={20}>20 mnt</option>
            <option value={25}>25 mnt</option>
            <option value={30}>30 mnt</option>
            <option value={45}>45 mnt</option>
            <option value={60}>60 mnt</option>
          </select>
        </div>
      </div>

      <div className="setting-item">
        <div>
          <div className="setting-label">Deteksi Stretching</div>
          <div className="setting-desc">Idle time = sedang stretching</div>
        </div>
        <div className="setting-control">
          <select
            value={state.idle_threshold_secs}
            onChange={(e) => onSetIdle(Number(e.target.value))}
          >
            <option value={60}>1 mnt</option>
            <option value={90}>1.5 mnt</option>
            <option value={120}>2 mnt</option>
            <option value={180}>3 mnt</option>
            <option value={300}>5 mnt</option>
          </select>
        </div>
      </div>

      <div className="setting-item">
        <div>
          <div className="setting-label">Monitoring</div>
          <div className="setting-desc">
            {state.is_active ? "Sedang aktif memantau" : "Dijeda"}
          </div>
        </div>
        <div className="setting-control">
          <button
            className={`btn ${state.is_active ? "btn-secondary" : "btn-primary"}`}
            style={{ padding: "6px 14px", fontSize: 13 }}
            onClick={onToggle}
          >
            {state.is_active ? "Jeda" : "Mulai"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  const [tab, setTab] = useState(0);
  const [state, setState] = useState({
    interval_minutes: 30,
    idle_threshold_secs: 120,
    is_active: true,
    elapsed_secs: 0,
    is_idle: false,
    idle_duration_secs: 0,
    stretches_today: 0,
    stretch_history: [],
    reminder_showing: false,
  });
  const [showReminder, setShowReminder] = useState(false);
  const [reminderExercise, setReminderExercise] = useState(null);
  const [showSettings, setShowSettings] = useState(false);
  const [theme, setTheme] = useState(
    () => localStorage.getItem("theme") || "system",
  );

  useEffect(() => {
    if (theme === "system") {
      document.documentElement.removeAttribute("data-theme");
    } else {
      document.documentElement.setAttribute("data-theme", theme);
    }
    localStorage.setItem("theme", theme);
  }, [theme]);

  const cycleTheme = useCallback(() => {
    setTheme((prev) => {
      const idx = THEME_CYCLE.indexOf(prev);
      return THEME_CYCLE[(idx + 1) % THEME_CYCLE.length];
    });
  }, []);

  // Initial state fetch
  useEffect(() => {
    invoke("get_state").then(setState).catch(console.error);
  }, []);

  // Listen for events from Rust backend
  useEffect(() => {
    const unlisteners = [];

    listen("state-tick", (event) => {
      setState(event.payload);
    }).then((u) => unlisteners.push(u));

    listen("stretch-reminder", () => {
      setReminderExercise(getQuickExercise());
      setShowReminder(true);
    }).then((u) => unlisteners.push(u));

    listen("stretch-completed", () => {
      setShowReminder(false);
      // Refresh state
      invoke("get_state").then(setState);
    }).then((u) => unlisteners.push(u));

    return () => {
      unlisteners.forEach((fn) => fn());
    };
  }, []);

  const handleDone = useCallback(async () => {
    await invoke("mark_stretch_done");
    setShowReminder(false);
    const newState = await invoke("get_state");
    setState(newState);
  }, []);

  const handleSnooze = useCallback(async (minutes) => {
    await invoke("snooze_reminder", { minutes });
    setShowReminder(false);
    const newState = await invoke("get_state");
    setState(newState);
  }, []);

  const handleSetInterval = useCallback(async (minutes) => {
    await invoke("set_interval", { minutes });
    const newState = await invoke("get_state");
    setState(newState);
  }, []);

  const handleSetIdle = useCallback(async (secs) => {
    await invoke("set_idle_threshold", { secs });
    const newState = await invoke("get_state");
    setState(newState);
  }, []);

  const handleToggle = useCallback(async () => {
    await invoke("toggle_monitoring");
    const newState = await invoke("get_state");
    setState(newState);
  }, []);

  const totalSecs = state.interval_minutes * 60;

  return (
    <div className="app">
      {/* Header */}
      <div className="header">
        <h1>
          <Icon
            icon="solar:leaf-bold-duotone"
            width={22}
            style={{ verticalAlign: "middle", marginRight: 6 }}
          />{" "}
          Stretchy
        </h1>
        <div className="header-actions">
          <button
            className="icon-btn"
            onClick={cycleTheme}
            title={`Mode: ${THEME_LABELS[theme]}`}
          >
            <Icon icon={THEME_ICONS[theme]} width={18} />
          </button>
          <button
            className="icon-btn"
            onClick={() => setShowSettings(!showSettings)}
            title="Settings"
          >
            <Icon icon="solar:settings-bold-duotone" width={18} />
          </button>
        </div>
      </div>

      {/* Settings (toggleable) */}
      {showSettings && (
        <SettingsPanel
          state={state}
          onSetInterval={handleSetInterval}
          onSetIdle={handleSetIdle}
          onToggle={handleToggle}
        />
      )}

      {/* Tab Navigation */}
      <div className="tab-nav">
        {TABS.map((t, i) => (
          <button
            key={t}
            className={`tab-btn ${tab === i ? "active" : ""}`}
            onClick={() => setTab(i)}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Tab: Timer */}
      {tab === 0 && (
        <>
          <div className="timer-section">
            <TimerRing
              elapsed={state.elapsed_secs}
              total={totalSecs}
              isIdle={state.is_idle}
              reminderShowing={state.reminder_showing}
            />

            <div
              className={`status-badge ${
                !state.is_active
                  ? "status-paused"
                  : state.is_idle
                    ? "status-idle"
                    : "status-active"
              }`}
            >
              <span
                className={`status-dot ${state.is_active ? "pulse" : ""}`}
              />
              {!state.is_active
                ? "Dijeda"
                : state.is_idle
                  ? `Idle ${formatTime(state.idle_duration_secs)}`
                  : "Memantau aktivitas"}
            </div>
          </div>

          {/* Stats */}
          <div className="stats-row">
            <div className="stat-card">
              <div className="stat-value">{state.stretches_today}</div>
              <div className="stat-label">Stretching</div>
            </div>
            <div className="stat-card">
              <div className="stat-value">{state.interval_minutes}m</div>
              <div className="stat-label">Interval</div>
            </div>
            <div className="stat-card">
              <div className="stat-value">
                {Math.round(state.idle_threshold_secs / 60)}m
              </div>
              <div className="stat-label">Idle Goal</div>
            </div>
          </div>

          {/* Quick Exercise Suggestion */}
          <div className="section-title">Latihan Berikutnya</div>
          <ExerciseCard exercise={getQuickExercise()} />
        </>
      )}

      {/* Tab: Gerakan */}
      {tab === 1 && (
        <>
          <div className="section-title">
            Semua Gerakan Stretching LBP ({exercises.length})
          </div>
          {exercises.map((ex) => (
            <ExerciseCard key={ex.id} exercise={ex} />
          ))}
        </>
      )}

      {/* Tab: Riwayat */}
      {tab === 2 && (
        <>
          <div className="section-title">Riwayat Hari Ini</div>
          {state.stretch_history.length === 0 ? (
            <div
              style={{
                textAlign: "center",
                padding: 40,
                color: "var(--text-muted)",
              }}
            >
              <div style={{ fontSize: 48, marginBottom: 12 }}>
                <Icon icon="solar:leaf-bold-duotone" width={48} />
              </div>
              <p>Belum ada stretching hari ini.</p>
              <p style={{ fontSize: 13, marginTop: 4 }}>
                Mulai stretching pertamamu!
              </p>
            </div>
          ) : (
            <>
              <div
                style={{
                  textAlign: "center",
                  marginBottom: 20,
                  padding: 20,
                  background: "var(--success-light)",
                  borderRadius: "var(--radius)",
                }}
              >
                <div style={{ fontSize: 40 }}>
                  <Icon icon="solar:cup-star-bold-duotone" width={40} />
                </div>
                <div
                  style={{
                    fontFamily: "'Outfit', sans-serif",
                    fontWeight: 700,
                    fontSize: 36,
                    color: "var(--success)",
                  }}
                >
                  {state.stretches_today}
                </div>
                <div
                  style={{
                    fontSize: 13,
                    color: "var(--success)",
                    marginTop: 4,
                  }}
                >
                  kali stretching hari ini
                </div>
              </div>

              <div className="section-title">Waktu Stretching</div>
              <div className="history-list">
                {state.stretch_history.map((time, i) => (
                  <span key={i} className="history-chip">
                    <Icon
                      icon="solar:check-circle-bold-duotone"
                      width={14}
                      style={{ verticalAlign: "middle", marginRight: 4 }}
                    />
                    {time}
                  </span>
                ))}
              </div>
            </>
          )}
        </>
      )}

      {/* Reminder Modal */}
      {showReminder && (
        <ReminderModal
          exercise={reminderExercise}
          onDone={handleDone}
          onSnooze={handleSnooze}
        />
      )}
    </div>
  );
}
