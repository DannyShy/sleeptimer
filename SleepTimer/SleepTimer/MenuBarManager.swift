import SwiftUI
import AppKit

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    @Published var showMainWindow = false
    
    override init() {
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "moon.zzz.fill", accessibilityDescription: "Sleep Timer")
            button.action = #selector(toggleMainWindow)
            button.target = self
        }
        
        updateMenu()
    }
    
    func updateMenu(sleepManager: SleepManager? = nil, appearanceManager: AppearanceManager? = nil) {
        let menu = NSMenu()
        
        if let manager = sleepManager, manager.isTimerActive {
            let timerItem = NSMenuItem(title: "Time remaining: \(manager.formattedTime())", action: nil, keyEquivalent: "")
            timerItem.isEnabled = false
            menu.addItem(timerItem)
            
            menu.addItem(NSMenuItem.separator())
            
            let cancelItem = NSMenuItem(title: "Cancel Timer", action: #selector(cancelTimerAction), keyEquivalent: "c")
            cancelItem.target = self
            menu.addItem(cancelItem)
        } else {
            let item30 = NSMenuItem(title: "30 minutes", action: #selector(startTimer30), keyEquivalent: "1")
            item30.target = self
            menu.addItem(item30)
            
            let item45 = NSMenuItem(title: "45 minutes", action: #selector(startTimer45), keyEquivalent: "2")
            item45.target = self
            menu.addItem(item45)
            
            let item60 = NSMenuItem(title: "1 hour", action: #selector(startTimer60), keyEquivalent: "3")
            item60.target = self
            menu.addItem(item60)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let appearanceMenu = NSMenu()
        let lightItem = NSMenuItem(title: "Light", action: #selector(setLightMode), keyEquivalent: "")
        lightItem.target = self
        appearanceMenu.addItem(lightItem)
        
        let darkItem = NSMenuItem(title: "Dark", action: #selector(setDarkMode), keyEquivalent: "")
        darkItem.target = self
        appearanceMenu.addItem(darkItem)
        
        let systemItem = NSMenuItem(title: "System", action: #selector(setSystemMode), keyEquivalent: "")
        systemItem.target = self
        appearanceMenu.addItem(systemItem)
        
        let appearanceMenuItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        appearanceMenuItem.submenu = appearanceMenu
        menu.addItem(appearanceMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showWindowItem = NSMenuItem(title: "Show Window", action: #selector(toggleMainWindow), keyEquivalent: "w")
        showWindowItem.target = self
        menu.addItem(showWindowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Sleep Timer", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func toggleMainWindow() {
        showMainWindow.toggle()
        if showMainWindow {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc private func startTimer30() {
        NotificationCenter.default.post(name: .startTimer, object: nil, userInfo: ["duration": 1800.0])
        showMainWindow = true
    }
    
    @objc private func startTimer45() {
        NotificationCenter.default.post(name: .startTimer, object: nil, userInfo: ["duration": 2700.0])
        showMainWindow = true
    }
    
    @objc private func startTimer60() {
        NotificationCenter.default.post(name: .startTimer, object: nil, userInfo: ["duration": 3600.0])
        showMainWindow = true
    }
    
    @objc private func cancelTimerAction() {
        NotificationCenter.default.post(name: .cancelTimer, object: nil)
    }
    
    @objc private func setLightMode() {
        NotificationCenter.default.post(name: .setAppearanceMode, object: nil, userInfo: ["mode": "light"])
    }
    
    @objc private func setDarkMode() {
        NotificationCenter.default.post(name: .setAppearanceMode, object: nil, userInfo: ["mode": "dark"])
    }
    
    @objc private func setSystemMode() {
        NotificationCenter.default.post(name: .setAppearanceMode, object: nil, userInfo: ["mode": "system"])
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

extension Notification.Name {
    static let startTimer = Notification.Name("startTimer")
    static let cancelTimer = Notification.Name("cancelTimer")
    static let setAppearanceMode = Notification.Name("setAppearanceMode")
}
