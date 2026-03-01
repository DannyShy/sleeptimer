import SwiftUI

struct CountdownWarningDialog: View {
    @EnvironmentObject var sleepManager: SleepManager

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

                // Text block
                VStack(spacing: 6) {
                    Text("Mac sa o chvíľu uspí")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)

                    Text("Zostávajúci čas do uspatia:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Countdown digits
                Text(countdown)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .frame(minWidth: 200)

                // Buttons
                VStack(spacing: 12) {
                    // Cancel — system blue
                    Button {
                        sleepManager.cancelTimer()
                    } label: {
                        Text("Zrušiť časovač")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.accentColor))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.cancelAction)

                    // Snooze — translucent
                    Button {
                        sleepManager.snoozeTimer()
                    } label: {
                        Text("Odložiť o 5 minút")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
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
    }
}

#Preview {
    CountdownWarningDialog()
        .environmentObject(SleepManager())
}
