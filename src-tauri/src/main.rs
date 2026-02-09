#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod activity_monitor;

use activity_monitor::ActivityMonitor;
use chrono::{DateTime, Local};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use tauri::{
    CustomMenuItem, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu, SystemTrayMenuItem,
};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Settings {
    interval_minutes: u32,
    idle_threshold_secs: u32,
    is_active: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            interval_minutes: 30,
            idle_threshold_secs: 120,
            is_active: true,
        }
    }
}

fn settings_path() -> PathBuf {
    let mut path = dirs_next().unwrap_or_else(|| PathBuf::from("."));
    path.push("settings.json");
    path
}

fn dirs_next() -> Option<PathBuf> {
    #[cfg(target_os = "macos")]
    {
        if let Some(home) = std::env::var_os("HOME") {
            let mut path = PathBuf::from(home);
            path.push("Library/Application Support/com.stretchy.app");
            let _ = std::fs::create_dir_all(&path);
            return Some(path);
        }
    }
    #[cfg(target_os = "windows")]
    {
        if let Some(appdata) = std::env::var_os("APPDATA") {
            let mut path = PathBuf::from(appdata);
            path.push("com.stretchy.app");
            let _ = std::fs::create_dir_all(&path);
            return Some(path);
        }
    }
    None
}

fn load_settings() -> Settings {
    let path = settings_path();
    if path.exists() {
        if let Ok(data) = std::fs::read_to_string(&path) {
            if let Ok(settings) = serde_json::from_str::<Settings>(&data) {
                return settings;
            }
        }
    }
    Settings::default()
}

fn save_settings(state: &AppState) {
    let settings = Settings {
        interval_minutes: state.interval_minutes,
        idle_threshold_secs: state.idle_threshold_secs,
        is_active: state.is_active,
    };
    if let Ok(data) = serde_json::to_string_pretty(&settings) {
        let _ = std::fs::write(settings_path(), data);
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppState {
    /// Interval in minutes before reminder
    pub interval_minutes: u32,
    /// Required idle time in seconds to count as "stretching done"
    pub idle_threshold_secs: u32,
    /// Whether monitoring is active
    pub is_active: bool,
    /// Seconds since last stretch (or app start)
    pub elapsed_secs: u32,
    /// Whether user is currently idle (possibly stretching)
    pub is_idle: bool,
    /// Idle duration in seconds
    pub idle_duration_secs: u32,
    /// Total stretches completed today
    pub stretches_today: u32,
    /// History of stretch times today
    pub stretch_history: Vec<String>,
    /// Whether reminder is currently showing
    pub reminder_showing: bool,
}

impl AppState {
    fn from_settings() -> Self {
        let settings = load_settings();
        Self {
            interval_minutes: settings.interval_minutes,
            idle_threshold_secs: settings.idle_threshold_secs,
            is_active: settings.is_active,
            elapsed_secs: 0,
            is_idle: false,
            idle_duration_secs: 0,
            stretches_today: 0,
            stretch_history: Vec::new(),
            reminder_showing: false,
        }
    }
}

type SharedState = Arc<Mutex<AppState>>;

#[tauri::command]
fn get_state(state: tauri::State<SharedState>) -> AppState {
    state.lock().unwrap().clone()
}

#[tauri::command]
fn set_interval(minutes: u32, state: tauri::State<SharedState>) {
    let mut s = state.lock().unwrap();
    s.interval_minutes = minutes;
    s.elapsed_secs = 0;
    save_settings(&s);
}

#[tauri::command]
fn set_idle_threshold(secs: u32, state: tauri::State<SharedState>) {
    let mut s = state.lock().unwrap();
    s.idle_threshold_secs = secs;
    save_settings(&s);
}

#[tauri::command]
fn toggle_monitoring(state: tauri::State<SharedState>) -> bool {
    let mut s = state.lock().unwrap();
    s.is_active = !s.is_active;
    if s.is_active {
        s.elapsed_secs = 0;
    }
    save_settings(&s);
    s.is_active
}

#[tauri::command]
fn mark_stretch_done(state: tauri::State<SharedState>) {
    let mut s = state.lock().unwrap();
    s.stretches_today += 1;
    s.elapsed_secs = 0;
    s.reminder_showing = false;
    let now: DateTime<Local> = Local::now();
    s.stretch_history.push(now.format("%H:%M").to_string());
}

#[tauri::command]
fn snooze_reminder(minutes: u32, state: tauri::State<SharedState>) {
    let mut s = state.lock().unwrap();
    // Set elapsed back so it triggers again after snooze duration
    let target = s.interval_minutes * 60;
    let snooze_secs = minutes * 60;
    if target > snooze_secs {
        s.elapsed_secs = target - snooze_secs;
    } else {
        s.elapsed_secs = 0;
    }
    s.reminder_showing = false;
}

#[tauri::command]
fn reset_today(state: tauri::State<SharedState>) {
    let mut s = state.lock().unwrap();
    s.stretches_today = 0;
    s.stretch_history.clear();
    s.elapsed_secs = 0;
}

fn play_alert_sound() {
    #[cfg(target_os = "macos")]
    {
        let _ = std::process::Command::new("afplay")
            .arg("/System/Library/Sounds/Glass.aiff")
            .spawn();
    }
    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("powershell")
            .args([
                "-WindowStyle",
                "Hidden",
                "-c",
                "[System.Media.SystemSounds]::Exclamation.Play()",
            ])
            .spawn();
    }
}

fn play_ping_sound() {
    #[cfg(target_os = "macos")]
    {
        let _ = std::process::Command::new("afplay")
            .arg("/System/Library/Sounds/Ping.aiff")
            .spawn();
    }
    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("powershell")
            .args([
                "-WindowStyle",
                "Hidden",
                "-c",
                "[System.Media.SystemSounds]::Asterisk.Play()",
            ])
            .spawn();
    }
}

fn create_system_tray() -> SystemTray {
    let menu = SystemTrayMenu::new()
        .add_item(CustomMenuItem::new("show", "Show Window"))
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(CustomMenuItem::new("pause", "Pause Monitoring"))
        .add_item(CustomMenuItem::new("stretch_now", "I Just Stretched! ✅"))
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(CustomMenuItem::new("quit", "Quit"));

    SystemTray::new().with_menu(menu)
}

fn main() {
    let state: SharedState = Arc::new(Mutex::new(AppState::from_settings()));
    let monitor_state = state.clone();
    let _tick_state = state.clone();

    tauri::Builder::default()
        .manage(state)
        .system_tray(create_system_tray())
        .on_system_tray_event(|app, event| match event {
            SystemTrayEvent::LeftClick { .. } => {
                if let Some(window) = app.get_window("main") {
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            }
            SystemTrayEvent::MenuItemClick { id, .. } => match id.as_str() {
                "show" => {
                    if let Some(window) = app.get_window("main") {
                        let _ = window.show();
                        let _ = window.set_focus();
                    }
                }
                "pause" => {
                    let state: tauri::State<SharedState> = app.state();
                    let mut s = state.lock().unwrap();
                    s.is_active = !s.is_active;
                    // Update menu item text
                    let item = app.tray_handle().get_item("pause");
                    if s.is_active {
                        let _ = item.set_title("Pause Monitoring");
                    } else {
                        let _ = item.set_title("Resume Monitoring");
                    }
                }
                "stretch_now" => {
                    let state: tauri::State<SharedState> = app.state();
                    let mut s = state.lock().unwrap();
                    s.stretches_today += 1;
                    s.elapsed_secs = 0;
                    s.reminder_showing = false;
                    let now: DateTime<Local> = Local::now();
                    s.stretch_history.push(now.format("%H:%M").to_string());
                }
                "quit" => {
                    std::process::exit(0);
                }
                _ => {}
            },
            _ => {}
        })
        .on_window_event(|event| {
            if let tauri::WindowEvent::CloseRequested { api, .. } = event.event() {
                event.window().hide().unwrap();
                api.prevent_close();
            }
        })
        .setup(move |app| {
            let app_handle = app.handle();

            // Start activity monitor in background thread
            let monitor_handle = app_handle.clone();
            std::thread::spawn(move || {
                let mut monitor = ActivityMonitor::new();
                let mut last_event_time = std::time::Instant::now();
                let mut last_tray_status: u8 = 255; // 0=paused, 1=stretch, 2=idle, 3=active
                let mut reminder_sound_tick: u32 = 0;

                loop {
                    std::thread::sleep(std::time::Duration::from_secs(1));

                    let mouse_moved = monitor.check_activity();

                    if mouse_moved {
                        last_event_time = std::time::Instant::now();
                    }

                    let idle_secs = last_event_time.elapsed().as_secs() as u32;

                    let mut state = monitor_state.lock().unwrap();

                    if !state.is_active {
                        // Still update tray when paused, but only once
                        if last_tray_status != 0 {
                            let _ = monitor_handle.tray_handle().set_title("Paused");
                            let _ = monitor_handle.tray_handle().set_icon(tauri::Icon::Raw(
                                include_bytes!("../icons/tray-paused.png").to_vec(),
                            ));
                            last_tray_status = 0;
                        }
                        continue;
                    }

                    // Update idle status
                    state.is_idle = idle_secs > 5; // Consider idle after 5 sec no movement
                    state.idle_duration_secs = idle_secs;

                    // If user is active (not idle), increment elapsed time
                    if !state.is_idle {
                        state.elapsed_secs += 1;
                    }

                    // Check if idle long enough to count as stretch
                    if idle_secs >= state.idle_threshold_secs && state.reminder_showing {
                        state.stretches_today += 1;
                        state.elapsed_secs = 0;
                        state.reminder_showing = false;
                        let now: DateTime<Local> = Local::now();
                        state.stretch_history.push(now.format("%H:%M").to_string());

                        // Emit stretch completed event
                        let _ = monitor_handle.emit_all("stretch-completed", ());
                    }

                    // Check if time to remind
                    let threshold = state.interval_minutes * 60;
                    if state.elapsed_secs >= threshold && !state.reminder_showing {
                        state.reminder_showing = true;
                        reminder_sound_tick = 0;

                        // Play alert sound
                        play_alert_sound();

                        // Show window and emit reminder event
                        if let Some(window) = monitor_handle.get_window("main") {
                            let _ = window.show();
                            let _ = window.set_focus();
                        }
                        let _ = monitor_handle.emit_all("stretch-reminder", ());

                        // Also send system notification
                        let _ = tauri::api::notification::Notification::new(
                            &monitor_handle.config().tauri.bundle.identifier,
                        )
                        .title("Time to Stretch!")
                        .body("You've been sitting too long. Let's stretch for your back!")
                        .show();
                    }

                    // Repeat sound every 30 seconds while reminder is showing
                    if state.reminder_showing {
                        reminder_sound_tick += 1;
                        if reminder_sound_tick % 30 == 0 {
                            play_ping_sound();
                        }
                    } else {
                        reminder_sound_tick = 0;
                    }

                    // Determine current status for tray
                    let current_status: u8 = if state.reminder_showing {
                        1
                    } else if state.is_idle {
                        2
                    } else {
                        3
                    };

                    // Update tray icon only when status changes
                    if current_status != last_tray_status {
                        let icon_bytes: &[u8] = match current_status {
                            1 => include_bytes!("../icons/tray-stretch.png"),
                            2 => include_bytes!("../icons/tray-idle.png"),
                            _ => include_bytes!("../icons/tray-active.png"),
                        };
                        let _ = monitor_handle
                            .tray_handle()
                            .set_icon(tauri::Icon::Raw(icon_bytes.to_vec()));
                        last_tray_status = current_status;
                    }

                    // Update tray title and emit UI tick every 5 seconds
                    if state.elapsed_secs % 5 == 0 || current_status != last_tray_status {
                        let remaining = threshold.saturating_sub(state.elapsed_secs);
                        let tray_title = if state.reminder_showing {
                            String::from("Stretch!")
                        } else if state.is_idle {
                            format!(
                                "Idle {:02}:{:02}",
                                state.idle_duration_secs / 60,
                                state.idle_duration_secs % 60
                            )
                        } else {
                            format!("{:02}:{:02}", remaining / 60, remaining % 60)
                        };
                        let _ = monitor_handle.tray_handle().set_title(&tray_title);
                        let _ = monitor_handle.emit_all("state-tick", state.clone());
                    }
                }
            });

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            get_state,
            set_interval,
            set_idle_threshold,
            toggle_monitoring,
            mark_stretch_done,
            snooze_reminder,
            reset_today,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
