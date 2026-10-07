import AppIntents

// MARK: - Pure intent logic (unit-tested)

enum SleepTimerLogic {
    /// Resolves the timer duration from an optional user-provided minute count.
    /// Falls back to the app default when `minutes` is nil.
    static func resolveDuration(minutes: Int?, defaultSeconds: TimeInterval) -> TimeInterval {
        guard let minutes else { return defaultSeconds }
        return TimeInterval(minutes * 60)
    }

    /// Converts the remaining seconds into whole minutes, rounded up.
    /// Returns 0 when no timer is running.
    static func remainingMinutesRoundedUp(remaining: TimeInterval, isActive: Bool) -> Int {
        guard isActive else { return 0 }
        return Int(ceil(remaining / 60))
    }
}

// MARK: - Intents

struct StartSleepTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Doze Timer"
    static var description = IntentDescription(
        "Starts a Doze sleep timer. Your Mac sleeps when it ends, after a 60-second warning."
    )

    // 6039 minutes = 99 h 99 min, the maximum the custom input allows.
    @Parameter(title: "Minutes", inclusiveRange: (lowerBound: 1, upperBound: 6039))
    var minutes: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Start Doze timer for \(\.$minutes) minutes")
    }

    @Dependency private var sleepManager: SleepManager

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if sleepManager.isTimerActive {
            let remaining = SleepTimerLogic.remainingMinutesRoundedUp(
                remaining: sleepManager.remainingTime,
                isActive: true)
            return .result(dialog: "A sleep timer is already running. \(remaining) minutes remaining.")
        }
        let duration = SleepTimerLogic.resolveDuration(
            minutes: minutes,
            defaultSeconds: SettingsManager.shared.defaultDurationSeconds())
        sleepManager.startTimer(duration: duration)
        return .result(dialog: "Sleep timer started. Your Mac will sleep at \(sleepManager.sleepAtTime).")
    }
}

struct CancelSleepTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Doze Timer"
    static var description = IntentDescription(
        "Cancels the running Doze sleep timer."
    )

    @Dependency private var sleepManager: SleepManager

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if sleepManager.isTimerActive {
            sleepManager.cancelTimer()
            return .result(dialog: "Sleep timer cancelled.")
        }
        return .result(dialog: "No sleep timer is running.")
    }
}

struct GetSleepTimerStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Doze Timer Status"
    static var description = IntentDescription(
        "Returns the minutes remaining on the Doze sleep timer, or 0 if none is running."
    )

    @Dependency private var sleepManager: SleepManager

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        if sleepManager.isTimerActive {
            let remaining = SleepTimerLogic.remainingMinutesRoundedUp(
                remaining: sleepManager.remainingTime,
                isActive: true)
            return .result(value: remaining, dialog: "\(remaining) minutes remaining.")
        }
        return .result(value: 0, dialog: "No sleep timer is running.")
    }
}
