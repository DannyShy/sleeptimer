import Foundation
import AppKit
import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Language (instant hot-reload)
    @Published var appLanguage: String = UserDefaults.standard.string(forKey: "appLanguage") ?? "English"

    // MARK: - Appearance (instant hot-reload)
    @Published var appAppearance: String = UserDefaults.standard.string(forKey: "appAppearance") ?? "System"

    // MARK: - Log
    @Published private(set) var logEntries: [String] = []

    // MARK: - Callbacks (wired by AppDelegate)
    var onTogglePopover: (() -> Void)?
    var onStartDefaultTimer: (() -> Void)?
    var onAppearanceChanged: ((NSAppearance?) -> Void)?

    // MARK: - Hotkey monitors
    private var globalShowMonitor: Any?
    private var globalStartMonitor: Any?
    private var localShowMonitor: Any?
    private var localStartMonitor: Any?

    // MARK: - App info (from Info.plist)
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    var versionString: String {
        "Version \(appVersion) (Build \(buildNumber))"
    }

    // MARK: - Init

    private init() {
        UserDefaults.standard.register(defaults: [
            "openAtLogin": false,
            "showDockIcon": false,
            "appLanguage": "English",
            "appAppearance": "System",
            "defaultDuration": "30 min",
            "warningSoundEnabled": true,
            "showCountdownMenuBar": false,
            "shortcutShowTimer": "",
            "shortcutStartTimer": ""
        ])
        log("App launched")
    }

    // MARK: - Logging

    func log(_ message: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let entry = "[\(df.string(from: Date()))] \(message)"
        DispatchQueue.main.async {
            self.logEntries.append(entry)
            if self.logEntries.count > 500 { self.logEntries.removeFirst() }
        }
    }

    // MARK: - Open at Login

    func setOpenAtLogin(_ enabled: Bool) {
        do {
            let service = SMAppService.mainApp
            if enabled { try service.register() } else { try service.unregister() }
            log("Login item \(enabled ? "enabled" : "disabled")")
        } catch {
            log("Login item error: \(error.localizedDescription)")
        }
    }

    func isLoginItemEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    // MARK: - Dock Icon

    func setDockIconVisible(_ visible: Bool) {
        NSApp.setActivationPolicy(visible ? .regular : .accessory)
        log("Dock icon \(visible ? "shown" : "hidden")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Appearance

    func applyAppearance(_ mode: String) {
        appAppearance = mode
        let appearance: NSAppearance?
        switch mode {
        case "Light": appearance = NSAppearance(named: .aqua)
        case "Dark":  appearance = NSAppearance(named: .darkAqua)
        default:      appearance = nil
        }
        // Keep NSApp at system appearance so the menu bar icon is tinted by macOS.
        NSApp.appearance = nil
        // Apply the selected appearance only to app windows/popover content.
        for window in NSApp.windows {
            window.appearance = appearance
        }
        // Explicitly update the popover bezel/background
        onAppearanceChanged?(appearance)
        log("Appearance: \(mode)")
    }

    var colorScheme: ColorScheme? {
        switch appAppearance {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil
        }
    }

    // MARK: - Language

    func setLanguage(_ language: String) {
        appLanguage = language
        UserDefaults.standard.set(language, forKey: "appLanguage")
        log("Language changed to \(language)")
    }

    // MARK: - Warning Sound

    func playWarningSound() {
        NSSound(named: NSSound.Name("Glass"))?.play()
        log("Warning sound played")
    }

    // MARK: - Default Duration

    func defaultDurationSeconds() -> TimeInterval {
        let key = UserDefaults.standard.string(forKey: "defaultDuration") ?? "30 min"
        switch key {
        case "45 min": return 2700
        case "1h":     return 3600
        case "Last used":
            let last = UserDefaults.standard.double(forKey: "lastUsedDuration")
            return last > 0 ? last : 1800
        default: return 1800
        }
    }

    func saveLastUsedDuration(_ duration: TimeInterval) {
        UserDefaults.standard.set(duration, forKey: "lastUsedDuration")
    }

    // MARK: - Export Logs

    func exportLogs() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "SleepTimer-logs.txt"
        panel.allowedContentTypes = [.plainText]
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url, let self else { return }
            let content = self.logEntries.joined(separator: "\n")
            try? content.write(to: url, atomically: true, encoding: .utf8)
            self.log("Logs exported to \(url.lastPathComponent)")
        }
    }

    // MARK: - Global Shortcuts

    func registerGlobalShortcuts() {
        unregisterGlobalShortcuts()
        let show = UserDefaults.standard.string(forKey: "shortcutShowTimer") ?? ""
        let start = UserDefaults.standard.string(forKey: "shortcutStartTimer") ?? ""

        if !show.isEmpty {
            // Global monitor (app in background)
            globalShowMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if self?.matchesShortcut(event, shortcut: show) == true {
                    DispatchQueue.main.async { self?.onTogglePopover?() }
                }
            }
            // Local monitor (app in foreground)
            localShowMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if self?.matchesShortcut(event, shortcut: show) == true {
                    DispatchQueue.main.async { self?.onTogglePopover?() }
                    return nil
                }
                return event
            }
        }
        if !start.isEmpty {
            // Global monitor (app in background)
            globalStartMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if self?.matchesShortcut(event, shortcut: start) == true {
                    DispatchQueue.main.async { self?.onStartDefaultTimer?() }
                }
            }
            // Local monitor (app in foreground)
            localStartMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if self?.matchesShortcut(event, shortcut: start) == true {
                    DispatchQueue.main.async { self?.onStartDefaultTimer?() }
                    return nil
                }
                return event
            }
        }
        if !show.isEmpty || !start.isEmpty { log("Shortcuts registered (global + local)") }
    }

    func unregisterGlobalShortcuts() {
        if let m = globalShowMonitor { NSEvent.removeMonitor(m); globalShowMonitor = nil }
        if let m = globalStartMonitor { NSEvent.removeMonitor(m); globalStartMonitor = nil }
        if let m = localShowMonitor { NSEvent.removeMonitor(m); localShowMonitor = nil }
        if let m = localStartMonitor { NSEvent.removeMonitor(m); localStartMonitor = nil }
    }

    private func matchesShortcut(_ event: NSEvent, shortcut: String) -> Bool {
        guard let built = Self.shortcutString(from: event) else { return false }
        return built == shortcut
    }

    static func shortcutString(from event: NSEvent) -> String? {
        guard let chars = event.charactersIgnoringModifiers?.uppercased(),
              !chars.isEmpty else { return nil }
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard mods.contains(.command) || mods.contains(.option) || mods.contains(.control) else {
            return nil
        }
        var parts: [String] = []
        if mods.contains(.control) { parts.append("⌃") }
        if mods.contains(.option)  { parts.append("⌥") }
        if mods.contains(.shift)   { parts.append("⇧") }
        if mods.contains(.command) { parts.append("⌘") }
        parts.append(chars)
        return parts.joined()
    }
}
