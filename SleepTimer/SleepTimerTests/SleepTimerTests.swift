import XCTest
import SwiftUI
import AppKit
import Carbon.HIToolbox
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

    // MARK: - cancelTimer

    func testCancelTimerResetsState() {
        sut.startTimer(duration: 600)
        sut.cancelTimer()
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.remainingTime, 0)
        XCTAssertFalse(sut.showWarningDialog)
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
    }

    func testSnoozeWhenInactiveDoesNothing() {
        sut.snoozeTimer()
        XCTAssertFalse(sut.isTimerActive)
        XCTAssertEqual(sut.selectedDuration, 1800) // default
    }

    func testSnoozeKeepsTimerActive() {
        sut.startTimer(duration: 300)
        sut.snoozeTimer()
        XCTAssertTrue(sut.isTimerActive)
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

    func testClosePopoverOnStartDefaultsToTrue() {
        // Ensure SettingsManager's register(defaults:) has run, then clear any
        // explicitly stored value. removeObject does not clear the registration
        // domain, so bool falls back to the registered default (true).
        _ = SettingsManager.shared
        UserDefaults.standard.removeObject(forKey: "closePopoverOnStart")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "closePopoverOnStart"))
    }

    func testVersionStringFormat() {
        UserDefaults.standard.set("English", forKey: "appLanguage")
        let version = SettingsManager.shared.versionString
        XCTAssertTrue(version.hasPrefix("Version "), "Got: \(version)")
        XCTAssertFalse(version.contains("Build"), "Got: \(version)")
    }

    func testVersionStringFormatSlovak() {
        UserDefaults.standard.set("Slovak", forKey: "appLanguage")
        defer { UserDefaults.standard.set("English", forKey: "appLanguage") }
        let version = SettingsManager.shared.versionString
        XCTAssertTrue(version.hasPrefix("Verzia "), "Got: \(version)")
        XCTAssertFalse(version.contains("Build"), "Got: \(version)")
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

// MARK: - Global Shortcut Tests

final class GlobalShortcutTests: XCTestCase {

    // MARK: isAcceptableShortcut

    func testCommandOnlyAccepted() {
        XCTAssertTrue(SettingsManager.isAcceptableShortcut(modifiers: [.command]))
    }

    func testControlOnlyAccepted() {
        XCTAssertTrue(SettingsManager.isAcceptableShortcut(modifiers: [.control]))
    }

    func testOptionOnlyRejected() {
        XCTAssertFalse(SettingsManager.isAcceptableShortcut(modifiers: [.option]))
    }

    func testShiftOnlyRejected() {
        XCTAssertFalse(SettingsManager.isAcceptableShortcut(modifiers: [.shift]))
    }

    func testOptionShiftRejected() {
        XCTAssertFalse(SettingsManager.isAcceptableShortcut(modifiers: [.option, .shift]))
    }

    func testControlOptionCommandAccepted() {
        XCTAssertTrue(SettingsManager.isAcceptableShortcut(modifiers: [.control, .option, .command]))
    }

    // MARK: Legacy shortcut migration

    func testLegacyMigrationRemovesOldKeys() {
        let defaults = UserDefaults.standard
        defaults.set("⌘L", forKey: "shortcutShowTimer")
        defaults.set("⌥S", forKey: "shortcutStartTimer")
        XCTAssertTrue(SettingsManager.migrateLegacyShortcuts())
        XCTAssertNil(defaults.string(forKey: "shortcutShowTimer"))
        XCTAssertNil(defaults.string(forKey: "shortcutStartTimer"))
    }

    func testLegacyMigrationSecondRunIsNoOp() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "shortcutShowTimer")
        defaults.removeObject(forKey: "shortcutStartTimer")
        XCTAssertFalse(SettingsManager.migrateLegacyShortcuts())
        XCTAssertNil(defaults.string(forKey: "shortcutShowTimer"))
        XCTAssertNil(defaults.string(forKey: "shortcutStartTimer"))
    }

    // MARK: Default shortcuts

    func testShowDozeDefaultShortcutIsControlOptionCommandD() {
        XCTAssertEqual(SettingsManager.defaultShowDozeShortcutInfo?.carbonKeyCode, Int(kVK_ANSI_D))
        XCTAssertEqual(SettingsManager.defaultShowDozeShortcutInfo?.modifiers, [.control, .option, .command])
    }

    func testStartDefaultTimerDefaultShortcutIsControlOptionCommandS() {
        XCTAssertEqual(SettingsManager.defaultStartDefaultTimerShortcutInfo?.carbonKeyCode, Int(kVK_ANSI_S))
        XCTAssertEqual(SettingsManager.defaultStartDefaultTimerShortcutInfo?.modifiers, [.control, .option, .command])
    }
}

// MARK: - Localization Tests

final class LocalizationTests: XCTestCase {

    func testEnglishReturnsKey() {
        UserDefaults.standard.set("English", forKey: "appLanguage")
        XCTAssertEqual(L("Doze"), "Doze")
        XCTAssertEqual(L("Cancel"), "Cancel")
    }

    func testSlovakTranslation() {
        UserDefaults.standard.set("Slovak", forKey: "appLanguage")
        XCTAssertEqual(L("Doze"), "Doze")
        XCTAssertEqual(L("Cancel"), "Zrušiť")
    }

    func testGermanTranslation() {
        UserDefaults.standard.set("German", forKey: "appLanguage")
        XCTAssertEqual(L("Doze"), "Doze")
    }

    func testMissingKeyReturnsKey() {
        UserDefaults.standard.set("Slovak", forKey: "appLanguage")
        XCTAssertEqual(L("nonexistent_key_xyz"), "nonexistent_key_xyz")
    }

    func testAllEntriesHaveAllLanguages() {
        let allowListedEmptyKeys: Set<String> = ["30 min", "45 min", "1h"]
        for (key, translations) in strings {
            if translations.isEmpty {
                XCTAssertTrue(allowListedEmptyKeys.contains(key),
                              "Key \"\(key)\" has an empty translation map but is not in the allow-list")
                continue
            }
            let missing = ["sk", "de", "fr", "es"].filter { translations[$0]?.isEmpty != false }
            XCTAssertTrue(missing.isEmpty,
                          "Key \"\(key)\" missing translations for: \(missing.joined(separator: ", "))")
        }
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

// MARK: - Popover Auto-Close Tests

final class PopoverAutoCloseTests: XCTestCase {

    func testFreshStartWithSettingOnCloses() {
        // idle -> running, setting ON
        XCTAssertTrue(SleepManager.shouldClosePopover(wasActive: false, isActive: true, settingEnabled: true))
    }

    func testFreshStartWithSettingOffDoesNotClose() {
        // idle -> running, setting OFF
        XCTAssertFalse(SleepManager.shouldClosePopover(wasActive: false, isActive: true, settingEnabled: false))
    }

    func testSnoozeTransitionDoesNotClose() {
        // running/warning -> running (no change)
        XCTAssertFalse(SleepManager.shouldClosePopover(wasActive: true, isActive: true, settingEnabled: true))
    }

    func testCancelTransitionDoesNotClose() {
        // running -> idle (cancel or expire)
        XCTAssertFalse(SleepManager.shouldClosePopover(wasActive: true, isActive: false, settingEnabled: true))
    }
}

// MARK: - Settings Window Geometry Tests

final class SettingsWindowGeometryTests: XCTestCase {

    func testTopAnchoredFrameGrowsDownward() {
        // Growing: top edge (maxY) stays fixed, height increases, origin.y
        // decreases by the height difference.
        let current = NSRect(x: 100, y: 200, width: 500, height: 320)
        let result = AppDelegate.topAnchoredFrame(current: current,
                                                  newContentHeight: 400,
                                                  chromeHeight: 28,
                                                  width: 500)
        XCTAssertEqual(result.width, 500, accuracy: 0.001)
        XCTAssertEqual(result.height, 428, accuracy: 0.001)
        XCTAssertEqual(result.maxY, current.maxY, accuracy: 0.001)
        XCTAssertEqual(result.minY, 92, accuracy: 0.001)  // 520 - 428
        XCTAssertEqual(result.minX, 100, accuracy: 0.001)
    }

    func testTopAnchoredFrameShrinksUpwardFromBottom() {
        // Shrinking: top edge (maxY) stays fixed, height decreases, origin.y
        // increases by the height difference.
        let current = NSRect(x: 100, y: 92, width: 500, height: 428)
        let result = AppDelegate.topAnchoredFrame(current: current,
                                                  newContentHeight: 240,
                                                  chromeHeight: 28,
                                                  width: 500)
        XCTAssertEqual(result.width, 500, accuracy: 0.001)
        XCTAssertEqual(result.height, 268, accuracy: 0.001)
        XCTAssertEqual(result.maxY, current.maxY, accuracy: 0.001)
        XCTAssertEqual(result.minY, 252, accuracy: 0.001)  // 520 - 268
        XCTAssertEqual(result.minX, 100, accuracy: 0.001)
    }
}

// MARK: - Sleep Intent Logic Tests

final class SleepIntentLogicTests: XCTestCase {

    func testResolveDurationNilReturnsDefault() {
        XCTAssertEqual(SleepTimerLogic.resolveDuration(minutes: nil, defaultSeconds: 1800), 1800)
    }

    func testResolveDuration45MinutesReturns2700() {
        XCTAssertEqual(SleepTimerLogic.resolveDuration(minutes: 45, defaultSeconds: 1800), 2700)
    }

    func testRemainingMinutesRoundedUpNotActiveReturnsZero() {
        XCTAssertEqual(SleepTimerLogic.remainingMinutesRoundedUp(remaining: 100, isActive: false), 0)
    }

    func testRemainingMinutesRoundedUp61SecondsReturnsTwo() {
        XCTAssertEqual(SleepTimerLogic.remainingMinutesRoundedUp(remaining: 61, isActive: true), 2)
    }

    func testRemainingMinutesRoundedUp60SecondsReturnsOne() {
        XCTAssertEqual(SleepTimerLogic.remainingMinutesRoundedUp(remaining: 60, isActive: true), 1)
    }

    func testRemainingMinutesRoundedUp1SecondReturnsOne() {
        XCTAssertEqual(SleepTimerLogic.remainingMinutesRoundedUp(remaining: 1, isActive: true), 1)
    }
}
