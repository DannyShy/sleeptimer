import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowPosition: CGPoint?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            if let savedPosition = UserDefaults.standard.object(forKey: "windowPosition") as? [String: CGFloat] {
                let x = savedPosition["x"] ?? 0
                let y = savedPosition["y"] ?? 0
                window.setFrameOrigin(CGPoint(x: x, y: y))
            } else {
                window.center()
            }
            
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
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
