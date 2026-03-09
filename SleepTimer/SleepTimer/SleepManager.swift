import Foundation
import SwiftUI

class SleepManager: ObservableObject {
    @Published var isTimerActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 1800
    @Published var timerStatusMessage: String = ""
    @Published var showWarningDialog = false
    
    private var timer: Timer?
    private var endTime: Date?
    private var warningShown = false
    var warningWindowManager: WarningWindowManager?
    
    func startTimer(duration: TimeInterval) {
        selectedDuration = duration
        remainingTime = duration
        endTime = Date().addingTimeInterval(duration)
        isTimerActive = true
        
        let minutes = Int(duration) / 60
        timerStatusMessage = "Timer started for \(minutes) minutes"
        SettingsManager.shared.saveLastUsedDuration(duration)
        SettingsManager.shared.log("Timer started: \(minutes) min")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
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
        timerStatusMessage = "Timer snoozed by 5 minutes"
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
        timerStatusMessage = "Timer cancelled"
        SettingsManager.shared.log("Timer cancelled")
    }
    
    private func updateTimer() {
        guard let endTime = endTime else { return }
        
        let now = Date()
        remainingTime = endTime.timeIntervalSince(now)
        
        if remainingTime <= 0 {
            timerStatusMessage = "Timer complete, putting Mac to sleep"
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
            timerStatusMessage = "Warning: Mac will sleep in 1 minute"
        } else {
            timerStatusMessage = "Time remaining: \(formattedTime())"
        }
    }
    
    private func putMacToSleep() {
        let script = """
        tell application "System Events"
            sleep
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            
            if let error = error {
                print("Error putting Mac to sleep: \(error)")
            } else {
                print("Sleep command executed successfully")
            }
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
