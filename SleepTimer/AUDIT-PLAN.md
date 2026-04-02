# Sleep Timer — Final Audit Report (Mac App Store)

> **Target:** Mac App Store submission  
> **Date:** April 2026  
> **Scope:** Functionality, bugs, security, missing tests, App Store compliance  
> **Status:** All code fixes implemented. Ready for manual testing pass.

---

## 1. Bug Fixes & Code Safety

### 1.1 — Duplicate Timer ~~(HIGH)~~ ✅ FIXED
- **File:** `SleepManager.swift`
- **Issue:** `startTimer()` created a new timer without invalidating the previous one.
- **Fix:** Added `timer?.invalidate(); timer = nil` at the top of `startTimer()`. Also added `guard duration > 0` to prevent zero-duration timers.

### 1.2 — Duplicate Settings Window ~~(MEDIUM)~~ ✅ FIXED
- **File:** `AppDelegate.swift`
- **Issue:** A new window was created every time Settings was opened after closing.
- **Fix:** Added `NSWindowDelegate` conformance with `windowWillClose` to nil out references. Changed guard to check `settingsWindow != nil` (reuse existing).

### 1.3 — Timer Fires on Background Thread ~~(LOW)~~ ✅ FIXED
- **File:** `SleepManager.swift`
- **Issue:** `Timer.scheduledTimer` could miss the main RunLoop if called from a background thread.
- **Fix:** Replaced with explicit `Timer()` + `RunLoop.main.add(t, forMode: .common)`.

### 1.4 — Negative remainingTime Displayed ~~(LOW)~~ ✅ FIXED
- **File:** `SleepManager.swift`
- **Fix:** Clamped with `remainingTime = max(0, endTime.timeIntervalSince(now))`.

### 1.5 — Dead Code / Unused Files ~~(LOW)~~ ✅ FIXED
- **Deleted:** `SettingsToolbar.swift`, `MenuBarManager.swift`, `FloatingWindow.swift`
- **Removed** all references from `project.pbxproj`.
- **Note:** Empty `Image.imageset` remains (harmless, no build impact).

---

## 2. Functionality Audit (Manual Testing Required)

### 2.1 — Timer Flow
| Check | Status |
|---|---|
| Start timer (30 min / 45 min / 1h) | Manual test |
| Start timer with Custom duration | Manual test |
| Cancel timer | Manual test |
| Snooze (+5 min) from warning dialog | Manual test |
| Timer expiration → Mac sleeps (now via IOKit) | Manual test |
| Warning dialog appears at 60s | Manual test |
| Warning sound plays at 60s (if enabled) | Manual test |
| Menu bar countdown display (if enabled) | Manual test |
| Menu bar resets to icon-only after cancel/expire | Manual test |
| `sleepAtTime` preview is accurate | Manual test |

### 2.2 — Settings
| Check | Status |
|---|---|
| Open at Login toggle syncs with SMAppService | Manual test |
| Show Dock Icon toggle works | Manual test |
| Language switch (all 5 languages) updates UI immediately | Manual test |
| Appearance switch (Light/Dark/System) applies to popover + settings | Manual test |
| Menu bar icon follows *system* appearance (template image) | Manual test |
| Default Duration picker persists and applies on next launch | Manual test |
| Warning Sound toggle persists | Manual test |
| Show countdown in Menu Bar toggle persists | Manual test |

### 2.3 — Keyboard Shortcuts
| Check | Status |
|---|---|
| Record shortcut via Pill field | Manual test |
| Clear shortcut via ✕ button | Manual test |
| Global shortcut works when app is in background | Manual test |
| Local shortcut works when app is in foreground | Manual test |
| Escape cancels recording | Manual test |
| Shortcuts persist across app relaunch | Manual test |

### 2.4 — Logs
| Check | Status |
|---|---|
| Log entries appear for all major actions | Manual test |
| Export logs writes correct file | Manual test |
| Log capped at 500 entries | ✅ Covered by unit test |

### 2.5 — Edge Cases
| Check | Status |
|---|---|
| Start timer with 0h 0m custom (should be prevented) | ✅ Fixed — guard + disabled button |
| Rapid double-click Start button | ✅ Fixed — timer invalidated before restart |
| Open Settings while Settings is already open | ✅ Fixed — reuses existing window |
| Close popover while timer is running | Manual test |
| Mac wakes from sleep with active timer | Manual test (endTime-based, should be correct) |

---

## 3. Security Audit (App Sandbox)

### 3.1 — Entitlements Review ✅ CLEAN
| Entitlement | Value | Status |
|---|---|---|
| `com.apple.security.app-sandbox` | `true` | ✅ Required for Mac App Store |

All Apple Events entitlements **removed** after IOKit migration.

### 3.2 — AppleScript → IOKit Migration ✅ FIXED
- **Was:** AppleScript via `NSAppleScript` + `temporary-exception.apple-events` (App Store blocker)
- **Now:** `IOPMSleepSystem()` via `IOKit.pwr_mgt` — no entitlements required, fully sandbox-compliant.
- **Entitlements removed:** `automation.apple-events`, `temporary-exception.apple-events`

### 3.3 — Data Storage ✅
| Item | Method | Secure? |
|---|---|---|
| Settings | `UserDefaults` / `@AppStorage` | ✅ No sensitive data |
| Logs | In-memory array (max 500) | ✅ No PII |
| Log export | `NSSavePanel` | ✅ Sandbox compliant |

### 3.4 — Network / Privacy ✅
- **Zero** network requests — no tracking, analytics, or telemetry.
- No camera, microphone, location, contacts, or file system access.
- `NSAppleEventsUsageDescription` removed (no longer needed).

---

## 4. Mac App Store Compliance

### 4.1 — Metadata & Info.plist
| Requirement | Status | Notes |
|---|---|---|
| `CFBundleIdentifier` | ✅ | Must match App Store Connect |
| `CFBundleShortVersionString` | ✅ | Ensure ≥ 1.0 |
| `CFBundleVersion` | ✅ | Must increment on each upload |
| `LSMinimumSystemVersion` | ✅ | 14.0 |
| `LSUIElement` | ✅ | `true` — menu bar app |
| `LSApplicationCategoryType` | ✅ ADDED | `public.app-category.utilities` |
| Privacy manifest (`PrivacyInfo.xcprivacy`) | ✅ ADDED | Declares `UserDefaults` (CA92.1) |

### 4.2 — Privacy Manifest ✅ ADDED
- Created `PrivacyInfo.xcprivacy` declaring:
  - `NSPrivacyTracking`: false
  - `NSPrivacyAccessedAPITypes`: `UserDefaults` with reason `CA92.1`
  - No collected data types, no tracking domains.

### 4.3 — App Icon ✅
All 10 required macOS icon sizes present (16–1024px, @1x and @2x).

### 4.4 — Code Signing & Hardened Runtime
| Requirement | Status |
|---|---|
| Signing with Apple Developer certificate | **Verify in Xcode before archive** |
| Hardened Runtime enabled | **Verify in build settings** |
| Provisioning profile for Mac App Store | **Verify in Xcode** |

### 4.5 — App Review Guidelines
| Guideline | Status |
|---|---|
| **2.1 — App Completeness** | ✅ Placeholder buttons removed |
| **2.3 — Accurate Metadata** | Prepare App Store Connect listing |
| **2.5.1 — Software Requirements** | ✅ All APIs current for macOS 14+ |
| **3.0 — Business** | ✅ No hidden features |
| **4.0 — Design** | ✅ Follows HIG, native controls |
| **4.2 — Minimum Functionality** | ✅ Timer utility with full settings |
| **5.1.1 — Data Collection** | ✅ Privacy manifest added |
| **5.1.2 — Data Use and Sharing** | ✅ No network activity |

### 4.6 — Placeholder Actions ✅ FIXED
- Removed "Check for Updates..." and "Send Feedback..." placeholder buttons from the popover menu.

---

## 5. Tests

### 5.1 — Unit Tests ✅ ADDED (30 tests, all passing)
| Test Suite | Tests | Status |
|---|---|---|
| `SleepManagerTests` | 15 | ✅ All pass |
| `SettingsManagerTests` | 7 | ✅ All pass |
| `LocalizationTests` | 4 | ✅ All pass |
| `ColorExtensionTests` | 4 | ✅ All pass |

**Coverage:** `SleepManager` (start, cancel, snooze, formatTime, progress, sleepAtTime, duplicate safety, zero-duration guard), `SettingsManager` (default durations, version string, log cap), `L()` (English, Slovak, German, missing keys), `Color(hex:)` (3/6/8-char, invalid).

### 5.2 — UI Tests (Optional for v1)
Not added — low priority for initial release.

### 5.3 — Manual Test Checklist
| # | Test | Pass? |
|---|---|---|
| 1 | Launch app → menu bar icon appears | |
| 2 | Click icon → popover opens | |
| 3 | Select 30min → Start → countdown runs | |
| 4 | Cancel timer → resets to selection | |
| 5 | Custom time 1h 30m → Start → shows 01:30:00 | |
| 6 | Timer reaches 60s → warning dialog appears | |
| 7 | Snooze → timer extends 5min, dialog closes | |
| 8 | Timer expires → Mac sleeps (via IOKit) | |
| 9 | Settings → change appearance → popover updates | |
| 10 | Settings → change language → all text updates | |
| 11 | Settings → record keyboard shortcut | |
| 12 | Use global shortcut from another app | |
| 13 | Export logs → file saves correctly | |
| 14 | Quit app → relaunch → settings persist | |
| 15 | Enable "Open at Login" → verify in System Settings | |

---

## 6. Summary of All Changes Made

| # | Change | Priority | Files Modified |
|---|---|---|---|
| 1 | IOKit migration (AppleScript → IOPMSleepSystem) | BLOCKER | `SleepManager.swift`, `SleepTimer.entitlements` |
| 2 | Removed Apple Events entitlements | BLOCKER | `SleepTimer.entitlements` |
| 3 | Added `PrivacyInfo.xcprivacy` | BLOCKER | New file |
| 4 | Removed placeholder menu buttons | BLOCKER | `ContentView.swift` |
| 5 | Added `LSApplicationCategoryType` | HIGH | `Info.plist` |
| 6 | Removed `NSAppleEventsUsageDescription` | HIGH | `Info.plist` |
| 7 | Fixed duplicate timer bug | HIGH | `SleepManager.swift` |
| 8 | Fixed Settings window lifecycle | MEDIUM | `AppDelegate.swift` |
| 9 | Guarded zero-duration timer | MEDIUM | `SleepManager.swift`, `ContentView.swift` |
| 10 | Removed dead code files | MEDIUM | 3 files deleted, `project.pbxproj` |
| 11 | Clamped remainingTime ≥ 0 | LOW | `SleepManager.swift` |
| 12 | Timer on main RunLoop | LOW | `SleepManager.swift` |
| 13 | Added unit test target (30 tests) | MEDIUM | New `SleepTimerTests/`, `project.pbxproj` |

---

## 7. Remaining Steps Before Submission

```
Step 1: ✅ IOKit migration — DONE
Step 2: ✅ Fix duplicate timer bug — DONE
Step 3: ✅ Add PrivacyInfo.xcprivacy — DONE
Step 4: ✅ Add LSApplicationCategoryType — DONE
Step 5: ✅ Fix/remove placeholder menu buttons — DONE
Step 6: ✅ Fix Settings window lifecycle — DONE
Step 7: ✅ Guard 0-duration timer start — DONE
Step 8: ✅ Remove dead code files — DONE
Step 9: ✅ Add unit test target + core tests — DONE (30/30 pass)
Step 10: Full manual testing pass (see checklist in §5.3)
Step 11: Verify code signing + Hardened Runtime in Xcode
Step 12: Archive & validate in Xcode Organizer
Step 13: Submit to App Store Connect
```
