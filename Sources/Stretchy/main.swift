import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let defaults = UserDefaults.standard
    private var item: NSStatusItem!
    private var tracker: Tracker!
    private let overlay = Overlay()
    private var paused = false
    /// Rotates through the list (ordered to alternate body areas); persisted across launches.
    private var nextExercise: Int {
        get { defaults.integer(forKey: "nextExercise") }
        set { defaults.set(newValue % Exercise.all.count, forKey: "nextExercise") }
    }

    private var interval: Int { defaults.integer(forKey: "intervalMin") }
    private var idleGoal: Int { defaults.integer(forKey: "idleMin") }

    func applicationDidFinishLaunching(_ n: Notification) {
        defaults.register(defaults: ["intervalMin": 30, "idleMin": 2])
        tracker = Tracker(interval: interval * 60, idleGoal: idleGoal * 60)

        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "figure.flexibility", accessibilityDescription: "Stretchy")
        item.button?.imagePosition = .imageLeading
        item.menu = NSMenu()
        item.menu?.delegate = self

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            MainActor.assumeIsolated { self.tick() }
        }
        render()
        // Dev: `Stretchy --preview [index]` opens the overlay right away.
        if let i = CommandLine.arguments.firstIndex(of: "--preview") {
            if let n = CommandLine.arguments.dropFirst(i + 1).first.flatMap({ Int($0) }) { nextExercise = n }
            stretchNow()
        }
    }

    private var snapshot = Tracker.Snapshot(idle: 0)

    private func tick() {
        let idle = Presence.inputIdle
        // Cheap signal first; the others only matter once input has gone quiet.
        let quiet = idle >= 5
        snapshot = Tracker.Snapshot(
            idle: idle,
            screenOff: Presence.screenOff,
            watching: quiet && Presence.displayKeptAwake,
            inCall: quiet && Presence.micInUse)
        if !paused {
            switch tracker.tick(snapshot) {
            case .remind: remind()
            case .stretched: finish()
            case nil: break
            }
        }
        render()
    }

    private func render() {
        let r = tracker.remaining
        item.button?.title = paused ? " ⏸" : tracker.reminding ? " !" : " \(Int((Double(r) / 60).rounded(.up)))m"
        item.button?.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
    }

    private func remind() {
        NSSound(named: "Funk")?.play()
        let ex = Exercise.all[nextExercise % Exercise.all.count]
        nextExercise += 1
        overlay.show(ex, onDone: { [weak self] in self?.finish() },
                     onSnooze: { [weak self] m in self?.snooze(m) })
    }

    private func finish() {
        tracker.done()
        overlay.close()
        let today = Date().formatted(date: .numeric, time: .omitted)
        if defaults.string(forKey: "countDate") != today {
            defaults.set(today, forKey: "countDate")
            defaults.set(0, forKey: "count")
        }
        defaults.set(defaults.integer(forKey: "count") + 1, forKey: "count")
        render()
    }

    private func snooze(_ min: Int) {
        tracker.snooze(min * 60)
        overlay.close()
        render()
    }

    private var statusText: String {
        let s = snapshot
        if paused { return L("paused", "dijeda") }
        if s.screenOff { return L("away (screen locked/off)", "tidak di depan laptop (layar terkunci/mati)") }
        if tracker.isAway(s) { return L("away (no activity)", "tidak di depan laptop (tidak ada aktivitas)") }
        if tracker.held { return L("in a call, reminder after it ends", "sedang meeting, diingatkan setelah selesai") }
        if s.inCall { return L("in a call", "sedang meeting/telepon") }
        if s.watching { return L("watching video", "menonton video") }
        if s.idle < 5 { return L("active (typing/mouse)", "aktif (mengetik/mouse)") }
        return L("reading (timer paused)", "membaca (timer berhenti sebentar)")
    }

    // MARK: Menu, rebuilt each time it opens

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let today = defaults.string(forKey: "countDate") == Date().formatted(date: .numeric, time: .omitted)
            ? defaults.integer(forKey: "count") : 0
        let r = tracker.remaining
        menu.addItem(withTitle: paused ? L("Paused", "Dijeda")
                     : L("Next stretch in ", "Stretching berikutnya ") + String(format: "%d:%02d", r / 60, r % 60),
                     action: nil, keyEquivalent: "")
        menu.addItem(withTitle: L("Status: ", "Status: ") + statusText, action: nil, keyEquivalent: "")
        menu.addItem(withTitle: L("Stretches today: ", "Stretching hari ini: ") + "\(today)", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        add(menu, L("Stretch now", "Stretching sekarang"), #selector(stretchNow), "s")
        add(menu, paused ? L("Resume", "Lanjutkan") : L("Pause", "Jeda"), #selector(togglePause), "p")
        menu.addItem(.separator())
        menu.addItem(choices(L("Remind every", "Ingatkan tiap"), [15, 20, 30, 45, 60], interval, #selector(setInterval(_:))))
        menu.addItem(choices(L("Break counts after idle", "Dihitung istirahat setelah diam"), [1, 2, 3, 5], idleGoal, #selector(setIdle(_:))))
        let login = add(menu, L("Launch at login", "Buka saat login"), #selector(toggleLogin), "")
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(.separator())
        add(menu, L("Quit Stretchy", "Keluar"), #selector(NSApplication.terminate(_:)), "q").target = NSApp
    }

    @discardableResult
    private func add(_ menu: NSMenu, _ title: String, _ sel: Selector, _ key: String) -> NSMenuItem {
        let i = menu.addItem(withTitle: title, action: sel, keyEquivalent: key)
        i.target = self
        return i
    }

    private func choices(_ title: String, _ values: [Int], _ current: Int, _ sel: Selector) -> NSMenuItem {
        let parent = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let sub = NSMenu()
        for v in values {
            let i = sub.addItem(withTitle: "\(v) " + L("min", "menit"), action: sel, keyEquivalent: "")
            i.target = self
            i.tag = v
            i.state = v == current ? .on : .off
        }
        parent.submenu = sub
        return parent
    }

    @objc private func stretchNow() { if !overlay.isShown { tracker.reminding = true; remind() } }

    @objc private func togglePause() { paused.toggle(); tracker.done(); overlay.close(); render() }

    @objc private func setInterval(_ s: NSMenuItem) {
        defaults.set(s.tag, forKey: "intervalMin")
        tracker.interval = s.tag * 60
        tracker.elapsed = 0
        render()
    }

    @objc private func setIdle(_ s: NSMenuItem) {
        defaults.set(s.tag, forKey: "idleMin")
        tracker.idleGoal = s.tag * 60
    }

    @objc private func toggleLogin() {
        let svc = SMAppService.mainApp
        do {
            try svc.status == .enabled ? svc.unregister() : svc.register()
        } catch {
            let a = NSAlert(error: error)
            a.runModal()
        }
    }
}

if CommandLine.arguments.contains("--presence") {
    print("inputIdle=\(Int(Presence.inputIdle))s screenOff=\(Presence.screenOff) watching=\(Presence.displayKeptAwake) inCall=\(Presence.micInUse)")
    exit(0)
}

if CommandLine.arguments.contains("--selftest") {
    Tracker.selfTest()
    precondition(Exercise.all.count == 17 && Exercise.all.allSatisfy { $0.frames.count == 2 })
    let byName = Dictionary(uniqueKeysWithValues: Exercise.all.map { ($0.image, $0) })
    let cat = byName["seated-cat-cow"]!
    precondition(cat.plan.count == 12 && cat.duration == 36, "6 reps × (3s + 3s)")
    precondition(byName["twist"]!.plan.map(\.side) == [0, 1], "twist: one hold per side")
    precondition(byName["neck-turn"]!.plan.filter { $0.beat.mirror == true }.count == 3, "neck-turn: left turn mirrored")
    print("exercises OK:", Exercise.all.map { "\($0.image) \($0.duration)s" }.joined(separator: ", "))
    exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = MainActor.assumeIsolated { AppDelegate() }
app.delegate = delegate
app.run()
