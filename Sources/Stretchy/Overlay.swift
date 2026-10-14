import AppKit
import SwiftUI

/// Full-screen reminder covering every display, above full-screen apps.
@MainActor
final class Overlay {
    private var panels: [NSPanel] = []

    var isShown: Bool { !panels.isEmpty }

    func show(_ ex: Exercise, onDone: @escaping () -> Void, onSnooze: @escaping (Int) -> Void) {
        close()
        for screen in NSScreen.screens {
            let panel = KeyPanel(contentRect: screen.frame, styleMask: [.borderless, .nonactivatingPanel],
                                 backing: .buffered, defer: false)
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.onEscape = { onSnooze(5) }
            let main = screen == NSScreen.main
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
    @State private var left = 0

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Color.black.opacity(0.35).ignoresSafeArea()
            if let ex = exercise { card(ex) }
        }
        .environment(\.colorScheme, .dark)
    }

    private func card(_ ex: Exercise) -> some View {
        VStack(spacing: 28) {
            Image(systemName: "figure.flexibility").font(.system(size: 64)).foregroundStyle(.green)
            Text(L("Time to stretch", "Waktunya stretching")).font(.title2).foregroundStyle(.secondary)
            Text(ex.name.value).font(.system(size: 44, weight: .bold))
            Text(ex.reps.value).font(.title3).foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(ex.steps.value.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(i + 1)").font(.headline.monospacedDigit()).foregroundStyle(.green)
                        Text(step).font(.title3)
                    }
                }
            }
            .frame(maxWidth: 620, alignment: .leading)

            Text(ex.benefit.value).font(.body).foregroundStyle(.secondary).italic()

            Text(left > 0 ? String(format: "%d:%02d", left / 60, left % 60) : L("Done!", "Selesai!"))
                .font(.system(size: 56, weight: .semibold).monospacedDigit())
                .contentTransition(.numericText())

            HStack(spacing: 16) {
                Button(L("Done stretching", "Selesai stretching"), action: onDone)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent).tint(.green)
                Button(L("Snooze 5 min", "Tunda 5 menit")) { onSnooze(5) }
                Button(L("Snooze 10 min", "Tunda 10 menit")) { onSnooze(10) }
            }
            .controlSize(.extraLarge)

            Text(L("Esc = snooze 5 min · step away and it closes itself",
                   "Esc = tunda 5 menit · tinggalkan meja, otomatis tertutup"))
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding(48)
        .foregroundStyle(.white)
        .task {
            left = ex.duration
            while left > 0 {
                try? await Task.sleep(for: .seconds(1))
                left -= 1
            }
            NSSound(named: "Glass")?.play()
        }
    }
}
