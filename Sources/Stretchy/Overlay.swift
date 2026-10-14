import AppKit
import SwiftUI

/// Full-screen reminder covering every display, above full-screen apps.
@MainActor
final class Overlay {
    private var panels: [NSPanel] = []

    var isShown: Bool { !panels.isEmpty }

    func show(_ ex: Exercise, onDone: @escaping () -> Void, onSnooze: @escaping (Int) -> Void) {
        close()
        let mouse = NSEvent.mouseLocation
        let active = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        for screen in NSScreen.screens {
            let panel = KeyPanel(contentRect: screen.frame, styleMask: [.borderless, .nonactivatingPanel],
                                 backing: .buffered, defer: false)
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.onEscape = { onSnooze(5) }
            let main = screen == active
            panel.contentView = NSHostingView(rootView: ReminderView(
                exercise: main ? ex : nil, onDone: onDone, onSnooze: onSnooze))
            panel.setFrame(screen.frame, display: true)
            panel.orderFrontRegardless()
            if main { panel.makeKey() }
            panels.append(panel)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        panels.forEach { $0.orderOut(nil) }
        panels = []
    }
}

private final class KeyPanel: NSPanel {
    var onEscape: (() -> Void)?
    override var canBecomeKey: Bool { true }
    override func cancelOperation(_ sender: Any?) { onEscape?() }
}

private struct ReminderView: View {
    let exercise: Exercise?
    let onDone: () -> Void
    let onSnooze: (Int) -> Void

    private static let prep = 10
    private enum Phase { case ready, stretch, done }
    @State private var phase = Phase.ready
    @State private var left = prep
    @State private var totalLeft = 0
    @State private var pose = 0 // 0 = start pose, 1 = end pose
    @State private var side = 0
    @State private var rep = 1
    @State private var cue = ""

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Color.black.opacity(0.45).ignoresSafeArea()
            if let ex = exercise { card(ex) }
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: Layout

    private var accent: Color { phase == .ready ? .orange : .green }

    /// Same card for both phases; the ready phase is told apart by orange color,
    /// a "Preview" badge on the looping illustration and a "Starts in" label.
    private func card(_ ex: Exercise) -> some View {
        HStack(alignment: .center, spacing: 48) {
            illustration(ex)
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    if phase == .ready {
                        Text(L("Next up", "Gerakan berikutnya")).font(.headline).foregroundStyle(.orange)
                    }
                    Text(ex.name.value).font(.system(size: 38, weight: .bold))
                    Text(ex.reps.value).font(.title3).foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(ex.steps.value.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(i + 1)").font(.headline.monospacedDigit()).foregroundStyle(accent)
                            Text(step).font(.title3).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Text(ex.benefit.value).foregroundStyle(.secondary)
                HStack(spacing: 20) {
                    counter(ex)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(headline)
                            .font(.title2.bold()).foregroundStyle(accent)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(.opacity)
                        Text(progressText(ex)).font(.headline.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    .animation(.easeInOut(duration: 0.3), value: headline)
                }
                buttons
            }
            .frame(width: 470, alignment: .leading)
        }
        .padding(44)
        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        .foregroundStyle(.white)
        .animation(.easeInOut(duration: 0.4), value: phase)
        .task { await run(ex) }
    }

    private var headline: String {
        switch phase {
        case .ready: L("Starts in \(left)…", "Mulai dalam \(left)…")
        case .stretch: cue
        case .done: L("Nice work!", "Mantap!")
        }
    }

    /// White card matching the illustration background, so the art never looks cropped.
    private func illustration(_ ex: Exercise) -> some View {
        let frames = ex.frames
        return ZStack {
            ForEach(frames.indices, id: \.self) { i in
                Image(nsImage: frames[i]).resizable().interpolation(.high).scaledToFit()
                    .opacity(pose == i ? 1 : 0)
            }
        }
        .scaleEffect(x: side == 1 ? -1 : 1)
        .padding(28)
        .frame(width: 400, height: 500)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .topLeading) {
            if phase == .ready {
                badge(L("Preview", "Contoh gerakan"), systemImage: "eye")
            } else if ex.sides == true, phase == .stretch {
                badge(side == 0 ? L("Side 1 of 2", "Sisi 1 dari 2") : L("Side 2 of 2", "Sisi 2 dari 2"))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(ex.name.value)
    }

    private func badge(_ text: String, systemImage: String? = nil) -> some View {
        Label {
            Text(text)
        } icon: {
            if let systemImage { Image(systemName: systemImage) }
        }
        .font(.callout.bold()).foregroundStyle(.white)
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(accent, in: Capsule())
        .padding(16)
    }

    /// Big number = seconds left in the current beat (or prep); ring = overall progress.
    private func counter(_ ex: Exercise) -> some View {
        let progress: CGFloat = switch phase {
        case .ready: CGFloat(left) / CGFloat(Self.prep)
        case .stretch: 1 - CGFloat(totalLeft) / CGFloat(ex.duration)
        case .done: 1
        }
        return ZStack {
            Circle().stroke(.white.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            if phase == .done {
                Image(systemName: "checkmark").font(.system(size: 40, weight: .bold))
            } else {
                Text("\(left)").font(.system(size: 48, weight: .bold).monospacedDigit())
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.snappy, value: left)
            }
        }
        .frame(width: 120, height: 120)
    }

    private func progressText(_ ex: Exercise) -> String {
        if phase == .done { return L("Press Done to continue", "Tekan Selesai untuk lanjut") }
        if phase == .ready {
            return String(format: L("Watch the preview · takes %d sec", "Lihat contoh gerakannya · durasi %d detik"), ex.duration)
        }
        var parts: [String] = []
        if ex.move.times > 1 { parts.append(L("Rep", "Ulangan") + " \(rep)/\(ex.move.times)") }
        parts.append(String(format: L("%d:%02d left", "sisa %d:%02d"), totalLeft / 60, totalLeft % 60))
        return parts.joined(separator: " · ")
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                if phase == .ready {
                    Button(L("Start now", "Mulai sekarang")) { left = 0 }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent).tint(.orange)
                } else {
                    Button(L("Done", "Selesai"), action: onDone)
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent).tint(.green)
                }
                Button(L("Snooze 5 min", "Tunda 5 menit")) { onSnooze(5) }
                Button(L("Snooze 10 min", "Tunda 10 menit")) { onSnooze(10) }
            }
            .controlSize(.large)
            Text(L("Esc = snooze 5 min · step away and it closes itself",
                   "Esc = tunda 5 menit · tinggalkan meja, otomatis tertutup"))
                .font(.caption).foregroundStyle(.tertiary)
        }
    }

    // MARK: Timeline

    private func run(_ ex: Exercise) async {
        // Preview: loop start/end pose while the prep countdown runs.
        let preview = Task { @MainActor in
            while (try? await Task.sleep(for: .seconds(1.5))) != nil {
                withAnimation(.easeInOut(duration: 0.9)) { pose = 1 - pose }
            }
        }
        await countdown(Self.prep)
        preview.cancel()
        guard !Task.isCancelled else { return }

        totalLeft = ex.duration
        withAnimation(.easeInOut(duration: 0.4)) { phase = .stretch }
        NSSound(named: "Hero")?.play()

        for (i, step) in ex.plan.enumerated() {
            if i > 0 { NSSound(named: step.side != side ? "Pop" : "Tink")?.play() }
            withAnimation(.easeInOut(duration: 0.5)) { side = step.side }
            withAnimation(.easeInOut(duration: 0.9)) { pose = step.beat.pose }
            rep = step.rep
            cue = step.beat.cue.value
            await countdown(step.beat.secs) { totalLeft -= 1 }
            guard !Task.isCancelled else { return }
        }

        withAnimation(.easeInOut(duration: 0.4)) { phase = .done }
        NSSound(named: "Glass")?.play()
    }

    /// Counts `left` down from `secs`. Setting `left = 0` from outside skips ahead.
    private func countdown(_ secs: Int, each: () -> Void = {}) async {
        left = secs
        while left > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            left = max(0, left - 1)
            each()
        }
    }
}
