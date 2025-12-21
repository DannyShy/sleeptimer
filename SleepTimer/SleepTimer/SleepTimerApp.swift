import SwiftUI

@main
struct SleepTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarManager = MenuBarManager()
    @StateObject private var sleepManager = SleepManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sleepManager)
                .environmentObject(menuBarManager)
                .onAppear {
                    setupNotifications()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            
            CommandMenu("Timer") {
                Button("Start 30 min timer") {
                    sleepManager.startTimer(duration: 1800)
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Start 45 min timer") {
                    sleepManager.startTimer(duration: 2700)
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("Start 1 hour timer") {
                    sleepManager.startTimer(duration: 3600)
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Divider()
                
                Button("Cancel Timer") {
                    sleepManager.cancelTimer()
                }
                .keyboardShortcut("c", modifiers: .command)
                .disabled(!sleepManager.isTimerActive)
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .startTimer,
            object: nil,
            queue: .main
        ) { notification in
            if let duration = notification.userInfo?["duration"] as? TimeInterval {
                sleepManager.startTimer(duration: duration)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .cancelTimer,
            object: nil,
            queue: .main
        ) { _ in
            sleepManager.cancelTimer()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            menuBarManager.updateMenu(sleepManager: sleepManager)
        }
    }
}
