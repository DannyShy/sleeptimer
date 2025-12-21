import SwiftUI
import AppKit

enum AppearanceMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var nsAppearance: NSAppearance? {
        switch self {
        case .light:
            return NSAppearance(named: .aqua)
        case .dark:
            return NSAppearance(named: .darkAqua)
        case .system:
            return nil
        }
    }
}

class AppearanceManager: ObservableObject {
    @Published var currentMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "appearanceMode")
            applyAppearance()
        }
    }
    
    init() {
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: savedMode) {
            self.currentMode = mode
        } else {
            self.currentMode = .system
        }
        applyAppearance()
    }
    
    private func applyAppearance() {
        DispatchQueue.main.async {
            NSApp.appearance = self.currentMode.nsAppearance
        }
    }
}
