import SwiftUI

@main
struct SleepTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarManager = MenuBarManager()
    @StateObject private var sleepManager = SleepManager()
    @StateObject private var appearanceManager = AppearanceManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sleepManager)
                .environmentObject(menuBarManager)
                .environmentObject(appearanceManager)
                .onAppear {
                    setupNotifications()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            
            CommandGroup(after: .appInfo) {
                Menu("Appearance") {
                    Button("Light") {
                        appearanceManager.currentMode = .light
                    }
                    .keyboardShortcut("l", modifiers: [.command, .option])
                    
                    Button("Dark") {
                        appearanceManager.currentMode = .dark
                    }
                    .keyboardShortcut("d", modifiers: [.command, .option])
                    
                    Button("System") {
                        appearanceManager.currentMode = .system
                    }
                    .keyboardShortcut("s", modifiers: [.command, .option])
                }
                
                Divider()
            }
            
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
        
        NotificationCenter.default.addObserver(
            forName: .setAppearanceMode,
            object: nil,
            queue: .main
        ) { notification in
            if let mode = notification.userInfo?["mode"] as? String {
                switch mode {
                case "light":
                    appearanceManager.currentMode = .light
                case "dark":
                    appearanceManager.currentMode = .dark
                case "system":
                    appearanceManager.currentMode = .system
                default:
                    break
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            menuBarManager.updateMenu(sleepManager: sleepManager, appearanceManager: appearanceManager)
        }
    }
}
