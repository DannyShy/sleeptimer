import XCTest
import SwiftUI
@testable import SleepTimer

final class SleepManagerTests: XCTestCase {

    var sut: SleepManager!

    override func setUp() {
        super.setUp()
        sut = SleepManager()
    }

    override func tearDown() {
        sut.cancelTimer()
        sut = nil
        super.tearDown()
    }

    // MARK: - startTimer

    func testStartTimerSetsActiveState() {
        sut.startTimer(duration: 300)
        XCTAssertTrue(sut.isTimerActive)
        XCTAssertEqual(sut.selectedDuration, 300)
        XCTAssertGreaterThan(sut.remainingTime, 0)
    }

    func testStartTimerZeroDurationIsIgnored() {
        sut.startTimer(duration: 0)
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.remainingTime, 0)
    }

    func testStartTimerNegativeDurationIsIgnored() {
        sut.startTimer(duration: -60)
        XCTAssertFalse(sut.isTimerActive)
    }

    func testStartTimerSetsStatusMessage() {
        sut.startTimer(duration: 1800)
        XCTAssertEqual(sut.timerStatusMessage, "Timer started for 30 minutes")
    }

    // MARK: - cancelTimer

    func testCancelTimerResetsState() {
        sut.startTimer(duration: 600)
        sut.cancelTimer()
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.remainingTime, 0)
        XCTAssertFalse(sut.showWarningDialog)
        XCTAssertEqual(sut.timerStatusMessage, "Timer cancelled")
    }

    func testCancelTimerWhenNotActiveIsSafe() {
        sut.cancelTimer()
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.remainingTime, 0)
    }

    // MARK: - snoozeTimer

    func testSnoozeExtendsTimer() {
        sut.startTimer(duration: 300)
        let before = sut.selectedDuration
        sut.snoozeTimer()
        XCTAssertEqual(sut.selectedDuration, before + 300)
        XCTAssertFalse(sut.showWarningDialog)
        XCTAssertEqual(sut.timerStatusMessage, "Timer snoozed by 5 minutes")
    }

    func testSnoozeWhenInactiveDoesNothing() {
        sut.snoozeTimer()
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.selectedDuration, 1800) // default
    }

    // MARK: - formattedTime

    func testFormattedTimeZero() {
        sut.startTimer(duration: 1)
        sut.cancelTimer()
        // After cancel, remainingTime is 0
        XCTAssertEqual(sut.formattedTime(), "00:00")
    }

    func testFormattedTimeMinutesAndSeconds() {
        sut.startTimer(duration: 125) // 2m 5s
        // remainingTime should be ~125
        let formatted = sut.formattedTime()
        XCTAssertTrue(formatted == "02:05" || formatted == "02:04",
                       "Expected ~02:05, got \(formatted)")
    }

    // MARK: - progress

    func testProgressWhenInactive() {
        XCTAssertEqual(sut.progress, 0)
    }

    func testProgressAtStart() {
        sut.startTimer(duration: 600)
        // Just started, progress should be near 0
        XCTAssertLessThan(sut.progress, 0.01)
    }

    // MARK: - sleepAtTime

    func testSleepAtTimeEmptyWhenInactive() {
        XCTAssertEqual(sut.sleepAtTime, "")
    }

    func testSleepAtTimeFormatWhenActive() {
        sut.startTimer(duration: 3600)
        let time = sut.sleepAtTime
        // Should be HH:mm format
        let regex = try! NSRegularExpression(pattern: "^\\d{2}:\\d{2}$")
        let range = NSRange(time.startIndex..., in: time)
        XCTAssertNotNil(regex.firstMatch(in: time, range: range),
                        "sleepAtTime should be HH:mm, got: \(time)")
    }

    // MARK: - Duplicate timer safety

    func testStartTimerTwiceDoesNotDuplicate() {
        sut.startTimer(duration: 600)
        let firstRemaining = sut.remainingTime
        sut.startTimer(duration: 1800)
        // Should reset to new duration, not accumulate
        XCTAssertEqual(sut.selectedDuration, 1800)
        XCTAssertGreaterThan(sut.remainingTime, firstRemaining)
    }
}

// MARK: - SettingsManager Tests

final class SettingsManagerTests: XCTestCase {

    func testDefaultDuration30Min() {
        UserDefaults.standard.set("30 min", forKey: "defaultDuration")
        XCTAssertEqual(SettingsManager.shared.defaultDurationSeconds(), 1800)
    }

    func testDefaultDuration45Min() {
        UserDefaults.standard.set("45 min", forKey: "defaultDuration")
        XCTAssertEqual(SettingsManager.shared.defaultDurationSeconds(), 2700)
    }

    func testDefaultDuration1h() {
        UserDefaults.standard.set("1h", forKey: "defaultDuration")
        XCTAssertEqual(SettingsManager.shared.defaultDurationSeconds(), 3600)
    }

    func testDefaultDurationLastUsedFallback() {
        UserDefaults.standard.set("Last used", forKey: "defaultDuration")
        UserDefaults.standard.removeObject(forKey: "lastUsedDuration")
        XCTAssertEqual(SettingsManager.shared.defaultDurationSeconds(), 1800)
    }

    func testDefaultDurationLastUsedWithValue() {
        UserDefaults.standard.set("Last used", forKey: "defaultDuration")
        UserDefaults.standard.set(Double(2700), forKey: "lastUsedDuration")
        XCTAssertEqual(SettingsManager.shared.defaultDurationSeconds(), 2700)
    }

    func testVersionStringFormat() {
        let version = SettingsManager.shared.versionString
        XCTAssertTrue(version.hasPrefix("Version "), "Got: \(version)")
    }

    func testLogCap() {
        for i in 0..<510 {
            SettingsManager.shared.log("Test entry \(i)")
        }
        // Log is capped at 500 entries (async, so wait briefly)
        let expectation = self.expectation(description: "Log capped")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertLessThanOrEqual(SettingsManager.shared.logEntries.count, 500)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

// MARK: - Localization Tests

final class LocalizationTests: XCTestCase {

    func testEnglishReturnsKey() {
        UserDefaults.standard.set("English", forKey: "appLanguage")
        XCTAssertEqual(L("Sleep Timer"), "Sleep Timer")
        XCTAssertEqual(L("Cancel"), "Cancel")
    }

    func testSlovakTranslation() {
        UserDefaults.standard.set("Slovak", forKey: "appLanguage")
        XCTAssertEqual(L("Sleep Timer"), "Časovač spánku")
        XCTAssertEqual(L("Cancel"), "Zrušiť")
    }

    func testGermanTranslation() {
        UserDefaults.standard.set("German", forKey: "appLanguage")
        XCTAssertEqual(L("Sleep Timer"), "Schlaf-Timer")
    }

    func testMissingKeyReturnsKey() {
        UserDefaults.standard.set("Slovak", forKey: "appLanguage")
        XCTAssertEqual(L("nonexistent_key_xyz"), "nonexistent_key_xyz")
    }

    override func tearDown() {
        UserDefaults.standard.set("English", forKey: "appLanguage")
        super.tearDown()
    }
}

// MARK: - Color Extension Tests

final class ColorExtensionTests: XCTestCase {

    func testHex6Digit() {
        let color = Color(hex: "FF0000")
        // Just verify it doesn't crash — Color internals aren't easily inspectable
        XCTAssertNotNil(color)
    }

    func testHex3Digit() {
        let color = Color(hex: "F00")
        XCTAssertNotNil(color)
    }

    func testHex8Digit() {
        let color = Color(hex: "80FF0000")
        XCTAssertNotNil(color)
    }

    func testInvalidHex() {
        let color = Color(hex: "XYZ")
        XCTAssertNotNil(color) // Should default to black, not crash
    }
}
