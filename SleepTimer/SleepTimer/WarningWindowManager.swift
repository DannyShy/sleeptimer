import SwiftUI
import AppKit

/// Borderless warning overlay window. Plain borderless NSWindows cannot
/// become key, so the overlay could never receive keyboard events or focus.
/// This subclass allows key (and main) status so Return/Escape and initial
/// keyboard/VoiceOver focus work inside the overlay.
private final class KeyableBorderlessWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class WarningWindowManager: ObservableObject {
    private var warningWindow: NSWindow?

    func showWarningDialog(sleepManager: SleepManager) {
        if warningWindow != nil { return }
        let contentView = CountdownWarningDialog().environmentObject(sleepManager)
        let hostingController = NSHostingController(rootView: contentView)
        let window = KeyableBorderlessWindow(contentViewController: hostingController)
        window.styleMask = [.borderless, .fullSizeContentView]
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
        announceWarningToVoiceOver(remainingSeconds: max(0, Int(sleepManager.remainingTime)))
        warningWindow = window
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
