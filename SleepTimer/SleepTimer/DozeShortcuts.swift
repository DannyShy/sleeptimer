import AppIntents

struct DozeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartSleepTimerIntent(),
            phrases: [
                "Start \(.applicationName)",
                "Start a \(.applicationName) sleep timer"
            ],
            shortTitle: "Start Sleep Timer",
            systemImageName: "moon.zzz"
        )
        AppShortcut(
            intent: CancelSleepTimerIntent(),
            phrases: [
                "Cancel \(.applicationName)",
                "Stop the \(.applicationName) timer"
            ],
            shortTitle: "Cancel Sleep Timer",
            systemImageName: "xmark.circle"
        )
        AppShortcut(
            intent: GetSleepTimerStatusIntent(),
            phrases: [
                "\(.applicationName) status",
                "How long until \(.applicationName) sleeps"
            ],
            shortTitle: "Sleep Timer Status",
            systemImageName: "timer"
        )
    }
}
