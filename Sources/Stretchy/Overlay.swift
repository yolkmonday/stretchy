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

    private func card(_ ex: Exercise) -> some View {
        Group {
            if phase == .ready { readyView(ex).transition(.opacity) }
            else { exerciseCard(ex).transition(.opacity.combined(with: .scale(scale: 0.97))) }
        }
        .foregroundStyle(.white)
        .task { await run(ex) }
    }

    /// Prep phase: no illustration, so the countdown can't be mistaken for the stretch timer.
    private func readyView(_ ex: Exercise) -> some View {
        VStack(spacing: 28) {
            Text(L("Get ready", "Bersiap")).font(.system(size: 28, weight: .semibold)).foregroundStyle(.orange)
            Text("\(left)")
                .font(.system(size: 160, weight: .bold).monospacedDigit())
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: left)
            VStack(spacing: 8) {
                Text(L("Next up", "Gerakan berikutnya")).font(.headline).foregroundStyle(.secondary)
                Text(ex.name.value).font(.system(size: 36, weight: .bold))
            }
            HStack(spacing: 12) {
                Button(L("Start now", "Mulai sekarang")) { left = 0 }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent).tint(.orange)
                Button(L("Snooze 5 min", "Tunda 5 menit")) { onSnooze(5) }
                Button(L("Snooze 10 min", "Tunda 10 menit")) { onSnooze(10) }
            }
            .controlSize(.large)
            .padding(.top, 8)
        }
        .accessibilityElement(children: .contain)
    }

    private func exerciseCard(_ ex: Exercise) -> some View {
        HStack(alignment: .center, spacing: 48) {
            illustration(ex)
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(ex.name.value).font(.system(size: 38, weight: .bold))
                    Text(ex.reps.value).font(.title3).foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(ex.steps.value.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(i + 1)").font(.headline.monospacedDigit()).foregroundStyle(.green)
                            Text(step).font(.title3).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Text(ex.benefit.value).foregroundStyle(.secondary)
                HStack(spacing: 20) {
                    counter(ex)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(phase == .done ? L("Nice work!", "Mantap!") : cue)
                            .font(.title2.bold()).foregroundStyle(.green)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(.opacity)
                        Text(progressText(ex)).font(.headline.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    .animation(.easeInOut(duration: 0.3), value: cue)
                }
                buttons
            }
            .frame(width: 470, alignment: .leading)
        }
        .padding(44)
        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 36, style: .continuous))
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
            if ex.sides == true, phase == .stretch {
                Text(side == 0 ? L("Side 1 of 2", "Sisi 1 dari 2") : L("Side 2 of 2", "Sisi 2 dari 2"))
                    .font(.callout.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.green, in: Capsule())
                    .padding(16)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(ex.name.value)
    }

    /// Big number = seconds left in the current beat; ring = progress of the whole exercise.
    private func counter(_ ex: Exercise) -> some View {
        ZStack {
            Circle().stroke(.white.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: phase == .done ? 1 : 1 - CGFloat(totalLeft) / CGFloat(ex.duration))
                .stroke(.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: totalLeft)
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
        var parts: [String] = []
        if ex.move.times > 1 { parts.append(L("Rep", "Ulangan") + " \(rep)/\(ex.move.times)") }
        parts.append(String(format: L("%d:%02d left", "sisa %d:%02d"), totalLeft / 60, totalLeft % 60))
        return parts.joined(separator: " · ")
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Button(L("Done", "Selesai"), action: onDone)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent).tint(.green)
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
        await countdown(Self.prep)
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
