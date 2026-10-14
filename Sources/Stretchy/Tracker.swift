import Foundation

/// Pure timer state machine, ticked once per second with a presence snapshot.
struct Tracker {
    enum Event { case remind, stretched }

    struct Snapshot {
        var idle: Double            // seconds since last keyboard/mouse input
        var screenOff = false       // locked or display asleep
        var watching = false        // video/presentation keeps display awake
        var inCall = false          // microphone in use
    }

    var interval: Int // seconds of sitting before a reminder
    var idleGoal: Int // seconds away that count as a break / stretch
    var elapsed = 0
    var reminding = false
    /// Reminder is due but held back because the user is in a call.
    var held = false

    var remaining: Int { max(0, interval - elapsed) }

    func isAway(_ s: Snapshot) -> Bool {
        s.screenOff || (s.idle >= Double(idleGoal) && !s.watching && !s.inCall)
    }

    /// Typing/mouse in the last 5 s, or passively at the screen (video, call).
    func isSitting(_ s: Snapshot) -> Bool {
        !s.screenOff && (s.idle < 5 || s.watching || s.inCall)
    }

    mutating func tick(_ s: Snapshot) -> Event? {
        if isAway(s) {
            held = false
            if reminding { done(); return .stretched }
            elapsed = 0 // natural break away from the desk
            return nil
        }
        if reminding { return nil }
        if isSitting(s), elapsed < interval { elapsed += 1 }
        guard elapsed >= interval else { held = false; return nil }
        held = s.inCall // don't pop a full-screen overlay over a meeting
        if held { return nil }
        reminding = true
        return .remind
    }

    mutating func done() { elapsed = 0; reminding = false; held = false }

    mutating func snooze(_ secs: Int) { elapsed = max(0, interval - secs); reminding = false; held = false }

    static func selfTest() {
        typealias S = Snapshot
        var t = Tracker(interval: 3, idleGoal: 10)
        assert(t.tick(S(idle: 0)) == nil && t.tick(S(idle: 0)) == nil)
        assert(t.tick(S(idle: 6)) == nil && t.elapsed == 2, "reading (idle 5s+) pauses countdown")
        assert(t.tick(S(idle: 0)) == .remind && t.reminding)
        assert(t.tick(S(idle: 0)) == nil, "no repeat while reminding")
        assert(t.tick(S(idle: 10)) == .stretched && t.elapsed == 0 && !t.reminding, "away closes reminder")

        t.elapsed = 2
        assert(t.tick(S(idle: 10)) == nil && t.elapsed == 0, "natural break resets")

        t.elapsed = 1
        assert(t.tick(S(idle: 600, watching: true)) == nil && t.elapsed == 2, "watching video = still sitting")
        assert(t.tick(S(idle: 600, inCall: true)) == nil && t.elapsed == 3 && t.held, "in a call: due but held")
        assert(t.tick(S(idle: 0)) == .remind, "fires once the call ends")
        t.done()

        t.elapsed = 2
        assert(t.tick(S(idle: 1, screenOff: true)) == nil && t.elapsed == 0, "screen locked = away")

        t.reminding = true
        t.snooze(1)
        assert(t.elapsed == 2 && t.remaining == 1 && !t.reminding)
        print("selftest OK")
    }
}
