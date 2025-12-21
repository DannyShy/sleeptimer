import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showSettings = false
    
    let timeOptions: [(label: String, duration: TimeInterval)] = [
        ("30 min", 1800),
        ("45 min", 2700),
        ("1 hour", 3600)
    ]
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .accessibilityLabel("Settings")
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                    
                    Text("Sleep Timer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 20)
                
                if sleepManager.isTimerActive {
                    VStack(spacing: 20) {
                        Text("Mac will sleep in")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Text(sleepManager.formattedTime())
                            .font(.system(size: 120, weight: .bold, design: .rounded))
                            .foregroundStyle(.tint)
                            .monospacedDigit()
                            .minimumScaleFactor(0.5)
                            .accessibilityLabel("Time remaining")
                            .accessibilityValue(sleepManager.timerStatusMessage)
                        
                        Button(action: {
                            sleepManager.cancelTimer()
                        }) {
                            Text("Cancel")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 200, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.cancelAction)
                        .accessibilityLabel("Cancel timer")
                        .accessibilityHint("Stops the sleep timer")
                    }
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 16) {
                        Text("Choose sleep timer")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 10)
                        
                        ForEach(timeOptions, id: \.label) { option in
                            Button(action: {
                                sleepManager.startTimer(duration: option.duration)
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.title2)
                                    Text(option.label)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 250, height: 60)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .accessibilityLabel("Set timer for \(option.label)")
                            .accessibilityHint("Starts a sleep timer")
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 400, height: 500)
        .tint(Color(hex: "e94560"))
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appearanceManager)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepManager())
        .environmentObject(AppearanceManager())
}
