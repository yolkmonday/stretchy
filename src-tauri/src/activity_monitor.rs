#[cfg(target_os = "macos")]
mod platform {
    // CGEventSourceSecondsSinceLastEventType is not wrapped by core-graphics 0.23,
    // so we declare it via raw FFI. CoreGraphics.framework is already linked by
    // the core-graphics crate.
    extern "C" {
        fn CGEventSourceSecondsSinceLastEventType(
            stateID: i32,   // CGEventSourceStateID (int32_t)
            eventType: u32, // CGEventType (uint32_t)
        ) -> f64;
    }

    const HID_SYSTEM_STATE: i32 = 1; // kCGEventSourceStateHIDSystemState
    const ANY_INPUT: u32 = u32::MAX; // kCGAnyInputEventType = ~0

    /// Returns seconds since the last input event of any type
    /// (mouse move, mouse click, keyboard, scroll wheel, tablet).
    pub fn seconds_since_last_input() -> f64 {
        unsafe { CGEventSourceSecondsSinceLastEventType(HID_SYSTEM_STATE, ANY_INPUT) }
    }
}

#[cfg(target_os = "windows")]
mod platform {
    use std::mem;
    use windows::Win32::UI::Input::KeyboardAndMouse::{GetLastInputInfo, LASTINPUTINFO};

    /// Returns seconds since the last input event of any type
    /// (mouse move, mouse click, keyboard).
    pub fn seconds_since_last_input() -> f64 {
        unsafe {
            let mut lii = LASTINPUTINFO {
                cbSize: mem::size_of::<LASTINPUTINFO>() as u32,
                dwTime: 0,
            };
            if GetLastInputInfo(&mut lii).as_bool() {
                let now = windows::Win32::System::SystemInformation::GetTickCount();
                let idle_ms = now.wrapping_sub(lii.dwTime);
                idle_ms as f64 / 1000.0
            } else {
                0.0 // Assume active on error
            }
        }
    }
}

pub struct ActivityMonitor {
    poll_interval_secs: f64,
}

impl ActivityMonitor {
    pub fn new() -> Self {
        Self {
            poll_interval_secs: 1.5,
        }
    }

    /// Check if any user input occurred recently.
    /// Returns true if activity detected (keyboard, mouse move, mouse click, etc).
    pub fn check_activity(&mut self) -> bool {
        let idle = platform::seconds_since_last_input();
        idle < self.poll_interval_secs
    }
}
