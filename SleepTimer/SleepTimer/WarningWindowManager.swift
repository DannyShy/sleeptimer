import SwiftUI
import AppKit

/// Borderless warning overlay panel. A plain borderless NSWindow of an
/// inactive app can never become key, so the overlay could never receive
/// keyboard events or focus. A non-activating panel becomes the key window
/// of its (still inactive) application, so Return/Escape and initial
/// keyboard/VoiceOver interaction work while another app stays frontmost.
private final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }

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
        let window = KeyablePanel(contentViewController: hostingController)
        // .nonactivatingPanel: the panel becomes key WITHOUT activating Doze,
        // so keyboard events reach the overlay while another app stays
        // frontmost (macOS 14+ ignores programmatic activation from a timer).
        window.styleMask = [.borderless, .fullSizeContentView, .nonactivatingPanel]
        // Panels default to becoming key only on text-entry clicks and to
        // hiding while the app is inactive; both are wrong for an overlay.
        window.becomesKeyOnlyIfNeeded = false
        window.isFloatingPanel = true
        window.hidesOnDeactivate = false
        // hideWarningDialog() nils warningWindow, which drives deallocation;
        // releasing in close() would double-release under ARC.
        window.isReleasedWhenClosed = false
        // VoiceOver's window chooser presents the overlay as a dialog.
        window.setAccessibilitySubrole(.dialog)
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
        // Route keys into the SwiftUI content even before SwiftUI focus settles.
        window.makeFirstResponder(hostingController.view)
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
