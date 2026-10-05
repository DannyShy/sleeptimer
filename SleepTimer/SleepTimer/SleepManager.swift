import Foundation
import SwiftUI
import IOKit.pwr_mgt

class SleepManager: ObservableObject {
    @Published var isTimerActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 1800
    @Published var showWarningDialog = false
    
    private var timer: Timer?
    private var endTime: Date?
    private var warningShown = false
    var warningWindowManager: WarningWindowManager?
    
    func startTimer(duration: TimeInterval) {
        guard duration > 0 else { return }
        
        timer?.invalidate()
        timer = nil
        
        selectedDuration = duration
        remainingTime = duration
        endTime = Date().addingTimeInterval(duration)
        isTimerActive = true
        
        let minutes = Int(duration) / 60
        SettingsManager.shared.saveLastUsedDuration(duration)
        SettingsManager.shared.log("Timer started: \(minutes) min")
        
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
    
    func snoozeTimer() {
        guard isTimerActive, let end = endTime else { return }
        let newEnd = end.addingTimeInterval(300)
        endTime = newEnd
        selectedDuration += 300
        remainingTime = newEnd.timeIntervalSince(Date())
        showWarningDialog = false
        warningShown = false
        warningWindowManager?.hideWarningDialog()
        SettingsManager.shared.log("Timer snoozed +5 min")
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        remainingTime = 0
        endTime = nil
        showWarningDialog = false
        warningShown = false
        warningWindowManager?.hideWarningDialog()
        SettingsManager.shared.log("Timer cancelled")
    }
    
    private func updateTimer() {
        guard let endTime = endTime else { return }
        
        let now = Date()
        remainingTime = max(0, endTime.timeIntervalSince(now))
        
        if remainingTime <= 0 {
            showWarningDialog = false
            warningWindowManager?.hideWarningDialog()
            cancelTimer()
            putMacToSleep()
        } else if remainingTime <= 60 && !warningShown {
            showWarningDialog = true
            warningShown = true
            warningWindowManager?.showWarningDialog(sleepManager: self)
            if UserDefaults.standard.bool(forKey: "warningSoundEnabled") {
                SettingsManager.shared.playWarningSound()
            }
        }
    }
    
    private func putMacToSleep() {
        let port = IOPMFindPowerManagement(mach_port_t(MACH_PORT_NULL))
        guard port != 0 else {
            SettingsManager.shared.log("Error: could not connect to IOKit power management")
            return
        }
        let result = IOPMSleepSystem(port)
        IOServiceClose(port)
        if result == kIOReturnSuccess {
            SettingsManager.shared.log("Sleep command executed successfully")
        } else {
            SettingsManager.shared.log("Error putting Mac to sleep: IOKit result \(result)")
        }
    }
    
    var progress: Double {
        guard isTimerActive, selectedDuration > 0 else { return 0 }
        return 1.0 - (remainingTime / selectedDuration)
    }

    var sleepAtTime: String {
        guard let endTime = endTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }

    func formattedTime() -> String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Popover auto-close decision (pure logic, no UI)

extension SleepManager {
    /// Returns true only for a fresh start: the timer transitioned from
    /// inactive to active and the auto-close setting is enabled.
    /// Snooze (active -> active) and cancel/expire (active -> inactive) never close the popover.
    static func shouldClosePopover(wasActive: Bool, isActive: Bool, settingEnabled: Bool) -> Bool {
        !wasActive && isActive && settingEnabled
    }
}
