import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    var isTransitioningPolicy = false
    private var settingsHostingController: NSHostingController<SettingsView>?
    let sleepManager = SleepManager()
    let warningWindowManager = WarningWindowManager()
    private let settings = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var settingsShowPending = false
    private var settingsInitialHeightApplied = false

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
            let icon = NSImage(systemSymbolName: "hourglass",
                               accessibilityDescription: "Doze")
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

        // Auto-close the popover on a fresh timer start (isTimerActive false -> true).
        // Snooze keeps isTimerActive true, so it never triggers this transition.
        sleepManager.$isTimerActive
            .removeDuplicates()
            .scan((false, false)) { ($0.1, $1) }      // (previous, current)
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] pair in
                guard let self else { return }
                let enabled = UserDefaults.standard.bool(forKey: "closePopoverOnStart")
                guard SleepManager.shouldClosePopover(wasActive: pair.0, isActive: pair.1, settingEnabled: enabled) else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    guard let self, self.popover.isShown, self.sleepManager.isTimerActive else { return }
                    self.popover.performClose(nil)
                }
            }
            .store(in: &cancellables)

        // Keep the settings window title in sync with the in-app language
        // (the NSWindow title is not re-evaluated by SwiftUI).
        settings.$appLanguage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.settingsWindow?.title = L("Doze Settings")
            }
            .store(in: &cancellables)

        // Register global shortcut handlers (KeyboardShortcuts package)
        settings.registerShortcutHandlers()

        settings.log("App ready")

        // If macOS terminated us (e.g. TCC accessibility toggle) while
        // the settings window was open, restore it on relaunch.
        if UserDefaults.standard.bool(forKey: "settingsWindowOpen") {
            settings.log("Restoring settings window after relaunch")
            openSettings()
        }
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
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            // Placeholder size; the first SwiftUI height measurement replaces
            // the height before the window becomes visible.
            let size = NSSize(width: 500, height: 320)
            let rect = NSRect(origin: .zero, size: size)

            // Standard NSWindow with fixed frame.
            let window = NSWindow(
                contentRect: rect,
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered, defer: false
            )
            window.title = L("Doze Settings")
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.minSize = size
            window.maxSize = size

            // Manual content view container (no contentViewController).
            let container = NSView(frame: rect)

            // Hosting view with sizing negotiation disabled; it follows the
            // container's size via autoresizing.
            let hostingController = NSHostingController(
                rootView: SettingsView { [weak self] height in
                    self?.settingsHeightChanged(height)
                })
            hostingController.sizingOptions = []
            let hostingView = hostingController.view
            hostingView.frame = container.bounds
            hostingView.autoresizingMask = [.width, .height]

            container.addSubview(hostingView)

            // Register the window before it enters the hierarchy so an early
            // height callback is not dropped.
            self.settingsWindow = window
            self.settingsShowPending = true
            self.settingsInitialHeightApplied = false

            window.contentView = container

            window.delegate = self
            window.center()
            window.isReleasedWhenClosed = false
            window.hidesOnDeactivate = false
            window.collectionBehavior = [.moveToActiveSpace, .managed]
            self.settingsHostingController = hostingController

            // Lay out while still hidden so SwiftUI reports the ideal height
            // and the window is sized before it is shown (no visible jump).
            container.layoutSubtreeIfNeeded()

            // Safety net: reveal even if no measurement arrives.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.revealPendingSettingsWindow()
            }
        }
    }

    // MARK: - Settings window sizing

    /// SwiftUI reported the ideal content height; resize the window so its
    /// content height matches, keeping the top edge fixed.
    private func settingsHeightChanged(_ contentHeight: CGFloat) {
        guard contentHeight > 0, let window = settingsWindow else { return }
        let contentRect = window.contentRect(forFrameRect: window.frame)
        let chromeHeight = window.frame.height - contentRect.height
        let newFrame = Self.topAnchoredFrame(current: window.frame,
                                             newContentHeight: contentHeight,
                                             chromeHeight: chromeHeight,
                                             width: window.frame.width)
        window.minSize = newFrame.size
        window.maxSize = newFrame.size
        if newFrame != window.frame {
            let animate = window.isVisible && settingsInitialHeightApplied
            window.setFrame(newFrame, display: true, animate: animate)
        }
        #if DEBUG
        print("📐 Settings content height: \(Int(contentHeight)) pt (window frame \(Int(newFrame.height)) pt)")
        #endif
        settingsInitialHeightApplied = true
        if settingsShowPending {
            revealPendingSettingsWindow()
        }
    }

    private func revealPendingSettingsWindow() {
        guard settingsShowPending, let window = settingsWindow else { return }
        settingsShowPending = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        UserDefaults.standard.set(true, forKey: "settingsWindowOpen")
    }

    /// Returns a frame of the given width and `newContentHeight + chromeHeight`
    /// total height whose top edge (maxY) matches `current`'s.
    static func topAnchoredFrame(current: NSRect, newContentHeight: CGFloat,
                                 chromeHeight: CGFloat, width: CGFloat) -> NSRect {
        let newHeight = newContentHeight + chromeHeight
        return NSRect(x: current.minX, y: current.maxY - newHeight,
                      width: width, height: newHeight)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closing = notification.object as? NSWindow,
              closing === settingsWindow else { return }
        if isTransitioningPolicy { return }
        settings.log("Settings window closing (isActive=\(NSApp.isActive), keyWindow=\(NSApp.keyWindow?.title ?? "nil"))")
        settingsWindow = nil
        settingsHostingController = nil
        UserDefaults.standard.set(false, forKey: "settingsWindowOpen")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        settings.log("App will terminate")
    }
}
