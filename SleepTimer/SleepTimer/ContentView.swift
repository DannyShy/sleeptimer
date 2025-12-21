import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepManager: SleepManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    let timeOptions: [(label: String, duration: TimeInterval)] = [
        ("30 min", 1800),
        ("45 min", 2700),
        ("1 hour", 3600)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1a1b30"),
                    Color(hex: "192038")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                    
                    Text("Sleep Timer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                if sleepManager.isTimerActive {
                    VStack(spacing: 20) {
                        Text("Mac will sleep in")
                            .font(.title3)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Text(sleepManager.formattedTime())
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundStyle(.tint)
                            .monospacedDigit()
                            .frame(width: 200)
                            .minimumScaleFactor(0.5)
                            .accessibilityLabel("Time remaining")
                            .accessibilityValue(sleepManager.timerStatusMessage)
                        
                        Button(action: {
                            sleepManager.cancelTimer()
                        }) {
                            Text("Cancel")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .frame(width: 200, height: 50)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .keyboardShortcut(.cancelAction)
                        .accessibilityLabel("Cancel timer")
                        .accessibilityHint("Stops the sleep timer")
                    }
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 16) {
                        Text("Choose sleep timer")
                            .font(.title3)
                            .foregroundColor(Color.white.opacity(0.7))
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
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .frame(width: 200, height: 50)
                            .buttonStyle(TimerButtonStyle())
                            .foregroundColor(.white)
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
        .frame(width: 300, height: 400)
        .tint(Color(hex: "e94560"))
    }
}

#Preview {
    ContentView()
        .environmentObject(SleepManager())
        .environmentObject(AppearanceManager())
}
