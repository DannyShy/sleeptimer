import SwiftUI
import AppKit

class WarningWindowManager: ObservableObject {
    private var warningWindow: NSWindow?
    
    func showWarningDialog(sleepManager: SleepManager) {
        if warningWindow != nil {
            return
        }
        
        let contentView = CountdownWarningDialog()
            .environmentObject(sleepManager)
        
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(contentViewController: hostingController)
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
        
        warningWindow = window
    }
    
    func hideWarningDialog() {
        warningWindow?.close()
        warningWindow = nil
    }
}
