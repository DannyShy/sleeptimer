import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    private var settingsHostingController: NSHostingController<SettingsView>?
    let sleepManager = SleepManager()
    let warningWindowManager = WarningWindowManager()
    private let settings = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        sleepManager.warningWindowManager = warningWindowManager

        // Apply saved appearance
        let appearance = UserDefaults.standard.string(forKey: "appAppearance") ?? "System"
        settings.applyAppearance(appearance)

        // Apply saved dock icon preference
        if UserDefaults.standard.bool(forKey: "showDockIcon") {
            settings.setDockIconVisible(true)
        }

        // Sync login item checkbox with actual system state
        UserDefaults.standard.set(settings.isLoginItemEnabled(), forKey: "openAtLogin")

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
            let icon = NSImage(systemSymbolName: "moon.zzz.fill",
                               accessibilityDescription: "Sleep Timer")
            icon?.isTemplate = true
            button.image = icon
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Wire SettingsManager callbacks
        settings.onTogglePopover = { [weak self] in
            self?.togglePopover(nil)
        }
        settings.onStartDefaultTimer = { [weak self] in
            guard let self, !self.sleepManager.isTimerActive else { return }
            let duration = self.settings.defaultDurationSeconds()
            self.sleepManager.startTimer(duration: duration)
        }
        settings.onAppearanceChanged = { [weak self] appearance in
            self?.popover.appearance = appearance
        }

        // Observe timer for menu bar countdown display
        sleepManager.$remainingTime
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateMenuBarDisplay() }
            .store(in: &cancellables)

        // Register global shortcuts
        settings.registerGlobalShortcuts()

        settings.log("App ready")
    }

    // MARK: - Menu bar countdown

    private func updateMenuBarDisplay() {
        let show = UserDefaults.standard.bool(forKey: "showCountdownMenuBar")
        guard show, sleepManager.isTimerActive else {
            statusItem.button?.title = ""
            statusItem.length = NSStatusItem.squareLength
            return
        }
        statusItem.button?.title = " \(sleepManager.formattedTime())"
        statusItem.length = NSStatusItem.variableLength
    }

    // MARK: - Popover

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

    // MARK: - Settings window

    private func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let size = NSSize(width: 500, height: 320)
            let rect = NSRect(origin: .zero, size: size)

            // Standard NSWindow with fixed frame.
            let window = NSWindow(
                contentRect: rect,
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered, defer: false
            )
            window.title = "Sleep Timer Settings"
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.minSize = size
            window.maxSize = size

            // Manual content view container (no contentViewController).
            let container = NSView(frame: rect)
            container.translatesAutoresizingMaskIntoConstraints = true
            container.autoresizesSubviews = false

            // Hosting view with sizing negotiation disabled.
            let hostingController = NSHostingController(rootView: SettingsView())
            hostingController.sizingOptions = []
            let hostingView = hostingController.view
            hostingView.translatesAutoresizingMaskIntoConstraints = true
            hostingView.frame = rect

            container.addSubview(hostingView)
            window.contentView = container
            window.contentView?.translatesAutoresizingMaskIntoConstraints = true
            window.contentView?.autoresizesSubviews = false

            window.center()
            window.isReleasedWhenClosed = false
            self.settingsWindow = window
            self.settingsHostingController = hostingController

            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
