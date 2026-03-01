import SwiftUI

struct ContentView: View {
    @ObservedObject var sleepManager: SleepManager
    var onOpenSettings: () -> Void = {}

    // MARK: - Timer option

    enum TimerOption: String, CaseIterable {
        case thirtyMin    = "30 min"
        case fortyFiveMin = "45 min"
        case oneHour      = "1h"
        case custom       = "Custom"

        var duration: TimeInterval? {
            switch self {
            case .thirtyMin:    return 1800
            case .fortyFiveMin: return 2700
            case .oneHour:      return 3600
            case .custom:       return nil
            }
        }
    }

    // MARK: - State

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedOption: TimerOption = .thirtyMin
    @State private var customHours: Int = 0
    @State private var customMinutes: Int = 30
    @State private var isHoveringCancel = false

    // MARK: - Computed

    private var cancelBg: Color {
        colorScheme == .dark
            ? Color.white.opacity(isHoveringCancel ? 0.22 : 0.15)
            : Color.black.opacity(isHoveringCancel ? 0.13 : 0.08)
    }

    private var currentDuration: TimeInterval {
        if selectedOption == .custom {
            return TimeInterval((customHours * 3600) + (customMinutes * 60))
        }
        return selectedOption.duration ?? 1800
    }

    private var displayTime: String {
        if sleepManager.isTimerActive {
            let t = Int(sleepManager.remainingTime)
            if t >= 3600 {
                let h = t / 3600, m = (t % 3600) / 60, s = t % 60
                return String(format: "%d:%02d:%02d", h, m, s)
            }
            let m = t / 60, s = t % 60
            return String(format: "%02d:%02d", m, s)
        }
        let m = Int(currentDuration) / 60
        return String(format: "%02d:00", m)
    }

    private var sleepAtPreview: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: Date().addingTimeInterval(currentDuration))
    }

    private var showCustomInput: Bool {
        selectedOption == .custom && !sleepManager.isTimerActive
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {

            // ── Header ───────────────────────────────────────────────
            HStack {
                Text("Sleep Timer")
                    .font(.title3.weight(.bold))
                Spacer()
                Menu {
                    Button("Check for Updates...") { print("Check for updates") }
                    Button("Send Feedback...")     { print("Send feedback") }
                    Button("Settings...")           { onOpenSettings() }
                    Divider()
                    Button("Quit Sleep Timer")     { NSApplication.shared.terminate(nil) }
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }

            // ── Segmented Picker ─────────────────────────────────────
            Picker("", selection: $selectedOption) {
                ForEach(TimerOption.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .disabled(sleepManager.isTimerActive)

            // ── Center block ─────────────────────────────────────────
            if showCustomInput {
                customInputBlock
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .transition(.opacity)
            } else {
                Text(displayTime)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
                    .accessibilityLabel("Time remaining")
                    .transition(.opacity)
            }

            // ── Progress bar (active only) ───────────────────────────
            if sleepManager.isTimerActive {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: max(0, geo.size.width * sleepManager.progress))
                    }
                }
                .frame(height: 4)
            }

            // ── Sleep-at footer ──────────────────────────────────────
            Text("Mac will sleep at **\(sleepManager.isTimerActive ? sleepManager.sleepAtTime : sleepAtPreview)**")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            // ── Start / Cancel ───────────────────────────────────────
            Button {
                if sleepManager.isTimerActive { sleepManager.cancelTimer() }
                else { sleepManager.startTimer(duration: currentDuration) }
            } label: {
                Text(sleepManager.isTimerActive ? "Cancel" : "Start Timer")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(sleepManager.isTimerActive ? .primary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        Capsule().fill(
                            sleepManager.isTimerActive
                                ? AnyShapeStyle(cancelBg)
                                : AnyShapeStyle(Color.accentColor)
                        )
                    )
            }
            .buttonStyle(.plain)
            .onHover { hov in
                guard sleepManager.isTimerActive else { return }
                withAnimation(.easeInOut(duration: 0.15)) { isHoveringCancel = hov }
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .animation(.easeInOut(duration: 0.2), value: showCustomInput)
    }

    // MARK: - Custom input block

    private var customInputBlock: some View {
        HStack(spacing: 10) {
            Spacer()
            TimeInputBox(value: $customHours, range: 0...99, label: "HOURS")
            Text(":")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .offset(y: -10)
            TimeInputBox(value: $customMinutes, range: 0...99, label: "MINUTES")
            Spacer()
        }
    }
}

// MARK: - Time Input Box

private struct TimeInputBox: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String

    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                TextField("00", text: $text)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity)
                    .onSubmit { formatText() }

                VStack(spacing: 2) {
                    stepButton("chevron.up")   { wrap(+1) }
                    stepButton("chevron.down") { wrap(-1) }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 115)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            )

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(1)
        }
        .onAppear { text = String(format: "%02d", value) }
        .onChange(of: text, perform: { _ in handleTextChange() })
        .onChange(of: isFocused, perform: { focused in
            if !focused { formatText() }
        })
        .onChange(of: value, perform: { _ in
            if !isFocused { text = String(format: "%02d", value) }
        })
    }

    private func handleTextChange() {
        let filtered = String(text.filter(\.isNumber).prefix(2))
        if filtered != text { text = filtered; return }
        if let num = Int(filtered) {
            value = min(num, range.upperBound)
        } else if filtered.isEmpty {
            value = 0
        }
    }

    private func formatText() {
        text = String(format: "%02d", value)
    }

    private func stepButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18, height: 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func wrap(_ delta: Int) {
        let next = value + delta
        if next > range.upperBound { value = range.lowerBound }
        else if next < range.lowerBound { value = range.upperBound }
        else { value = next }
    }
}

#Preview {
    ContentView(sleepManager: SleepManager())
}
