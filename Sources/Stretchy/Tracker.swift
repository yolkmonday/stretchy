import Foundation

/// Pure timer state machine, ticked once per second with the current system idle time.
struct Tracker {
    enum Event { case remind, stretched }

    var interval: Int // seconds of activity before a reminder
    var idleGoal: Int // seconds idle that count as a break / stretch
    var elapsed = 0
    var reminding = false

    var remaining: Int { max(0, interval - elapsed) }

    mutating func tick(idle: Double) -> Event? {
        if reminding {
            guard idle >= Double(idleGoal) else { return nil }
            done()
            return .stretched
        }
        if idle >= Double(idleGoal) { elapsed = 0; return nil } // natural break away from the desk
        if idle < 5 { elapsed += 1 }
        guard elapsed >= interval else { return nil }
        reminding = true
        return .remind
    }

    mutating func done() { elapsed = 0; reminding = false }

    mutating func snooze(_ secs: Int) { elapsed = max(0, interval - secs); reminding = false }

    static func selfTest() {
        var t = Tracker(interval: 3, idleGoal: 10)
        assert(t.tick(idle: 0) == nil && t.tick(idle: 0) == nil)
        assert(t.tick(idle: 6) == nil && t.elapsed == 2, "idle 5s+ pauses countdown")
        assert(t.tick(idle: 0) == .remind && t.reminding)
        assert(t.tick(idle: 0) == nil, "no repeat while reminding")
        assert(t.tick(idle: 10) == .stretched && t.elapsed == 0 && !t.reminding)
        t.elapsed = 2
        assert(t.tick(idle: 10) == nil && t.elapsed == 0, "natural break resets")
        t.reminding = true
        t.snooze(1)
        assert(t.elapsed == 2 && t.remaining == 1 && !t.reminding)
        print("selftest OK")
    }
}
