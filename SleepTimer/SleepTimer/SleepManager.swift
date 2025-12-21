import Foundation
import IOKit
import IOKit.pwr_mgt
import SwiftUI

class SleepManager: ObservableObject {
    @Published var isTimerActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 1800
    @Published var timerStatusMessage: String = ""
    
    private var timer: Timer?
    private var endTime: Date?
    
    func startTimer(duration: TimeInterval) {
        selectedDuration = duration
        remainingTime = duration
        endTime = Date().addingTimeInterval(duration)
        isTimerActive = true
        
        let minutes = Int(duration) / 60
        timerStatusMessage = "Timer started for \(minutes) minutes"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        remainingTime = 0
        endTime = nil
        timerStatusMessage = "Timer cancelled"
    }
    
    private func updateTimer() {
        guard let endTime = endTime else { return }
        
        let now = Date()
        remainingTime = endTime.timeIntervalSince(now)
        
        if remainingTime <= 0 {
            timerStatusMessage = "Timer complete, putting Mac to sleep"
            cancelTimer()
            putMacToSleep()
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
    
    func formattedTime() -> String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
