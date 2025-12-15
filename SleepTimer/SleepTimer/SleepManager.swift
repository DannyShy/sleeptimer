import Foundation
import IOKit
import IOKit.pwr_mgt

class SleepManager: ObservableObject {
    @Published var isTimerActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 1800
    
    private var timer: Timer?
    private var endTime: Date?
    
    func startTimer(duration: TimeInterval) {
        selectedDuration = duration
        remainingTime = duration
        endTime = Date().addingTimeInterval(duration)
        isTimerActive = true
        
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
    }
    
    private func updateTimer() {
        guard let endTime = endTime else { return }
        
        let now = Date()
        remainingTime = endTime.timeIntervalSince(now)
        
        if remainingTime <= 0 {
            cancelTimer()
            putMacToSleep()
        }
    }
    
    private func putMacToSleep() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]
        
        do {
            try task.run()
            print("Sleep command executed successfully")
        } catch {
            print("Error putting Mac to sleep: \(error)")
        }
    }
    
    func formattedTime() -> String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
