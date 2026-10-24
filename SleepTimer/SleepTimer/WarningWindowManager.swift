import SwiftUI
import AppKit

/// Borderless warning overlay window. Plain borderless NSWindows cannot
/// become key, so the overlay could never receive keyboard events or focus.
/// This subclass allows key (and main) status so Return/Escape and initial
/// keyboard/VoiceOver focus work inside the overlay.
private final class KeyableBorderlessWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    /// Escape routing, independent of which control inside the overlay has
    /// focus. The standard key binding maps "␛" to cancelOperation:, which
    /// reaches the window once no responder consumes the key; keyDown
    /// (keyCode 53) is the direct fallback.
    var onCancel: (() -> Void)?

    override func cancelOperation(_ sender: Any?) {
        onCancel?()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // kVK_Escape
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }
}

class WarningWindowManager: ObservableObject {
    private var warningWindow: NSWindow?

    func showWarningDialog(sleepManager: SleepManager) {
        if warningWindow != nil { return }
        let contentView = CountdownWarningDialog().environmentObject(sleepManager)
        let hostingController = NSHostingController(rootView: contentView)
        let window = KeyableBorderlessWindow(contentViewController: hostingController)
        window.styleMask = [.borderless, .fullSizeContentView]
        // Invisible on a borderless window; gives VoiceOver a window name
        // instead of announcing the overlay as "Untitled".
        window.title = "Doze"
        // Escape cancels the timer no matter which control has focus.
        window.onCancel = { [weak sleepManager] in sleepManager?.cancelTimer() }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovable = false
        window.center()
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            window.setFrame(screenFrame, display: true)
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        warningWindow = window
        scheduleWarningAnnouncement(sleepManager: sleepManager)
    }

    /// Posts the VoiceOver announcement about one second after the overlay
    /// becomes key, so VoiceOver's own window/focus utterance (triggered by
    /// makeKeyAndOrderFront/activate) does not override it. The remaining
    /// time is read at posting time so the spoken value is current. The
    /// staleness guard suppresses the announcement if the overlay was
    /// dismissed or replaced meanwhile.
    private func scheduleWarningAnnouncement(sleepManager: SleepManager) {
        let overlay = warningWindow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self, self.warningWindow === overlay else { return }
            self.announceWarningToVoiceOver(remainingSeconds: max(0, Int(sleepManager.remainingTime)))
        }
    }

    func hideWarningDialog() {
        warningWindow?.close()
        warningWindow = nil
    }

    /// High-priority VoiceOver announcement shown once when the overlay
    /// appears, composed entirely from existing localized strings plus the
    /// coarse (minute-granular) time value.
    private func announceWarningToVoiceOver(remainingSeconds: Int) {
        let message = "\(L("Mac will sleep soon")). \(L("Time remaining until sleep:")) \(SleepManager.accessibilityTimeValue(seconds: remainingSeconds))"
        NSAccessibility.post(
            element: NSApplication.shared,
            notification: .announcementRequested,
            userInfo: [
                .announcement: NSAttributedString(string: message),
                .priority: NSAccessibilityPriorityLevel.high
            ]
        )
    }
}
