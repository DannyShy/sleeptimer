# Sleep Timer for macOS

A native macOS app that puts your MacBook to sleep after a specified time interval.

## Features

- **Three timer options**: 30 minutes, 45 minutes, or 1 hour
- **Cancel anytime**: Stop the timer before it completes
- **Modern UI**: Beautiful dark-themed interface with gradient background
- **Native macOS app**: Built with SwiftUI for optimal performance

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later

## Installation

### Building from Source

1. **Open the project in Xcode**:
   ```bash
   cd /Users/sklad/PROJEKTY/Sleepz/SleepTimer
   open SleepTimer.xcodeproj
   ```

2. **Select your Mac as the build target**:
   - In Xcode, click on the scheme selector (near the play button)
   - Select "My Mac" as the destination

3. **Build and run**:
   - Press `Cmd + R` or click the Play button
   - The app will build and launch

4. **Install to Applications folder** (optional):
   - In Xcode, go to Product → Archive
   - Once archived, click "Distribute App"
   - Choose "Copy App"
   - Save to your Applications folder

### Quick Run (for testing)

Simply press `Cmd + R` in Xcode to run the app directly without installing.

## Usage

1. Launch the Sleep Timer app
2. Choose your desired sleep duration:
   - 30 minutes
   - 45 minutes
   - 1 hour
3. The countdown will begin immediately
4. To cancel, click the "Cancel" button before the timer expires
5. When the timer reaches zero, your Mac will automatically go to sleep

## How It Works

The app uses AppleScript to trigger the system sleep command when the timer expires. It's completely safe and uses the same sleep mechanism as closing your MacBook lid or selecting Sleep from the Apple menu.

## Permissions

The app requires permission to send AppleScript commands to System Events. macOS will prompt you to grant this permission the first time you use the sleep function.

## Troubleshooting

**App doesn't put Mac to sleep:**
- Go to System Settings → Privacy & Security → Automation
- Ensure "Sleep Timer" has permission to control "System Events"

**Can't build the project:**
- Make sure you have Xcode 15.0 or later installed
- Verify your macOS version is 13.0 or later
- Try cleaning the build folder: Product → Clean Build Folder (Cmd + Shift + K)

## Project Structure

```
SleepTimer/
├── SleepTimer.xcodeproj/       # Xcode project file
└── SleepTimer/
    ├── SleepTimerApp.swift     # App entry point
    ├── ContentView.swift       # Main UI
    ├── SleepManager.swift      # Timer and sleep logic
    ├── Assets.xcassets/        # App icons and colors
    ├── Info.plist              # App configuration
    └── SleepTimer.entitlements # App permissions
```

## License

This project is open source and available for personal use.
