import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowPosition: CGPoint?
    var customPanel: FloatingPanel?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            let contentView = window.contentView
            let frame = window.frame
            let styleMask = window.styleMask
            
            let floatingPanel = FloatingPanel(
                contentRect: frame,
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
            
            floatingPanel.contentView = contentView
            
            if let savedPosition = UserDefaults.standard.object(forKey: "windowPosition") as? [String: CGFloat] {
                let x = savedPosition["x"] ?? 0
                let y = savedPosition["y"] ?? 0
                floatingPanel.setFrameOrigin(CGPoint(x: x, y: y))
            } else {
                floatingPanel.center()
            }
            
            floatingPanel.level = .floating
            floatingPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            floatingPanel.appearance = NSAppearance(named: .darkAqua)
            floatingPanel.titlebarAppearsTransparent = false
            floatingPanel.isFloatingPanel = true
            floatingPanel.becomesKeyOnlyIfNeeded = false
            
            window.close()
            
            floatingPanel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            
            customPanel = floatingPanel
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            let position = window.frame.origin
            UserDefaults.standard.set(["x": position.x, "y": position.y], forKey: "windowPosition")
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
