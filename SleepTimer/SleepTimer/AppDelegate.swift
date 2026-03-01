import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    let sleepManager = SleepManager()
    let warningWindowManager = WarningWindowManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        sleepManager.warningWindowManager = warningWindowManager

        // Build popover
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        let contentView = ContentView(sleepManager: sleepManager, onOpenSettings: { [weak self] in
            self?.openSettings()
        })
        let hostingController = NSHostingController(rootView: contentView)
        if #available(macOS 13.0, *) {
            hostingController.sizingOptions = .preferredContentSize
        }
        popover.contentViewController = hostingController

        // Build status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "moon.zzz.fill",
                                   accessibilityDescription: "Sleep Timer")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // Make popover window transparent so VisualEffectView shows desktop through
    func popoverWillShow(_ notification: Notification) {
        DispatchQueue.main.async {
            if let window = self.popover.contentViewController?.view.window {
                window.isOpaque = false
                window.backgroundColor = .clear
            }
        }
    }

    private func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingController = NSHostingController(rootView: SettingsView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Sleep Timer Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
        window.setContentSize(NSSize(width: 500, height: 320))
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()
        window.isReleasedWhenClosed = false
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
