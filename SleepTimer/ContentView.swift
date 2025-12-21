import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepManager: SleepManager
    
    let timeOptions: [(label: String, duration: TimeInterval)] = [
        ("30 min", 1800),
        ("45 min", 2700),
        ("1 hour", 3600)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "e94560"))
                    
                    Text("Sleep Timer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                if sleepManager.isTimerActive {
                    VStack(spacing: 20) {
                        Text("Mac will sleep in")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(sleepManager.formattedTime())
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "e94560"))
                            .monospacedDigit()
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
                        .tint(Color(hex: "e94560"))
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
                            .foregroundColor(.white.opacity(0.7))
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
                            .tint(.white.opacity(0.2))
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
}
