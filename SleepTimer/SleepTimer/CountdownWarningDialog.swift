import SwiftUI

struct CountdownWarningDialog: View {
    @EnvironmentObject var sleepManager: SleepManager
    @ObservedObject private var settings = SettingsManager.shared
    @FocusState private var cancelFocused: Bool

    private var countdown: String {
        let t = max(0, Int(sleepManager.remainingTime))
        let m = t / 60, s = t % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // ── Full-screen dark backdrop ─────────────────────────
            Color.black.opacity(0.70)
                .ignoresSafeArea()

            // ── Card ─────────────────────────────────────────────────
            VStack(spacing: 28) {

                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.yellow)
                    .symbolRenderingMode(.multicolor)
                    .padding(.top, 8)
                    .accessibilityHidden(true)

                // Text block
                VStack(spacing: 6) {
                    Text(L("Mac will sleep soon"))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text(L("Time remaining until sleep:"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Countdown digits
                Text(countdown)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .frame(minWidth: 200)
                    .accessibilityLabel(L("Time remaining"))
                    .accessibilityValue(SleepManager.accessibilityTimeValue(seconds: max(0, Int(sleepManager.remainingTime))))

                // Buttons
                VStack(spacing: 12) {
                    // Cancel — system blue
                    Button {
                        sleepManager.cancelTimer()
                    } label: {
                        Text(L("Cancel Timer"))
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.accentColor))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.defaultAction)
                    .focused($cancelFocused)
                    .defaultFocus($cancelFocused, true)

                    // Snooze — translucent
                    Button {
                        sleepManager.snoozeTimer()
                    } label: {
                        Text(L("Snooze 5 minutes"))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.primary.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
            .frame(width: 340)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 15)
        }
        .onExitCommand { sleepManager.cancelTimer() }
    }
}

#Preview {
    CountdownWarningDialog()
        .environmentObject(SleepManager())
}
