import SwiftUI

struct CountdownWarningDialog: View {
    @EnvironmentObject var sleepManager: SleepManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Warning")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Mac will sleep in")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Text(sleepManager.formattedTime())
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "e94560"))
                .monospacedDigit()
                .frame(minWidth: 150)
            
            VStack(spacing: 12) {
                Button(action: {
                    sleepManager.cancelTimer()
                }) {
                    Text("Cancel Timer")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(hex: "e94560"))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                
                Button(action: {
                    sleepManager.showWarningDialog = false
                    sleepManager.warningWindowManager?.hideWarningDialog()
                }) {
                    Text("Continue")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "1a1b30"),
                            Color(hex: "192038")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .frame(width: 350)
        }
        .tint(Color(hex: "e94560"))
    }
}

#Preview {
    CountdownWarningDialog()
        .environmentObject(SleepManager())
}
