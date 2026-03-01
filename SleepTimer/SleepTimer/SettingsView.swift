import SwiftUI
import AppKit

// MARK: - Tab enum

private enum STab: CaseIterable {
    case general, timer, shortcuts
    var label: String {
        switch self { case .general: "General"; case .timer: "Timer"; case .shortcuts: "Shortcuts" }
    }
    var icon: String {
        switch self { case .general: "gearshape.fill"; case .timer: "timer"; case .shortcuts: "keyboard" }
    }
}

// MARK: - Grid constants

private let kLabelW: CGFloat = 180

// MARK: - SettingsView

struct SettingsView: View {
    @State private var tab: STab = .general

    var body: some View {
        VStack(spacing: 0) {

            // ── Centered title (titlebar area) ──────────────────────
            Text("Sleep Timer Settings")
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 28)

            // ── Tab bar ─────────────────────────────────────────────
            HStack(spacing: 0) {
                Spacer()
                ForEach(STab.allCases, id: \.label) { t in
                    STabButton(tab: t, active: tab == t) { tab = t }
                }
                Spacer()
            }
            .padding(.vertical, 8)

            Divider()

            // ── Content area (top-aligned) + spacer pushes footer ──
            VStack(spacing: 0) {
                Group {
                    switch tab {
                    case .general:   GeneralTab()
                    case .timer:     TimerTab()
                    case .shortcuts: ShortcutsTab()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(24)

                Spacer(minLength: 0)

                // ── Footer separator ────────────────────────────────
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(NSColor.separatorColor))
                    .padding(.horizontal, 20)

                // ── Footer ──────────────────────────────────────────
                HStack {
                    Text("Version 1.0.0 (Build 26)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Export logs") { print("Export logs") }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .frame(width: 500, height: 320)
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - Tab button

private struct STabButton: View {
    let tab: STab
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: active ? .semibold : .regular))
                Text(tab.label)
                    .font(.system(size: 10, weight: active ? .medium : .regular))
            }
            .foregroundStyle(active ? Color.accentColor : Color.secondary)
            .frame(width: 84)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(active ? Color(NSColor.controlColor) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - General tab

private struct GeneralTab: View {
    @AppStorage("openAtLogin")   private var openAtLogin  = false
    @AppStorage("showDockIcon")  private var showDockIcon = false
    @AppStorage("appLanguage")   private var language     = "English"
    @AppStorage("appAppearance") private var appearance   = "System"

    private let langs = ["English", "Slovak", "German", "French", "Spanish"]
    private let modes = ["Light", "Dark", "System"]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text("Open at Login")
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Toggle("", isOn: $openAtLogin)
                    .toggleStyle(.checkbox).labelsHidden()
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Show Icon in Dock").foregroundStyle(.secondary)
                Toggle("", isOn: $showDockIcon).toggleStyle(.checkbox).labelsHidden()
            }
            GridRow {
                Text("Language").foregroundStyle(.secondary)
                Picker("", selection: $language) {
                    ForEach(langs, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden().fixedSize()
            }
            GridRow {
                Text("Appearance").foregroundStyle(.secondary)
                Picker("", selection: $appearance) {
                    ForEach(modes, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden().pickerStyle(.segmented).frame(width: 195)
            }
        }
    }
}

// MARK: - Timer tab

private struct TimerTab: View {
    @AppStorage("defaultDuration")      private var dur      = "30 min"
    @AppStorage("warningSoundEnabled")  private var warn     = true
    @AppStorage("showCountdownMenuBar") private var menuBar  = false

    private let durations = ["30 min", "45 min", "1h", "Last used"]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text("Default Duration")
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Picker("", selection: $dur) {
                    ForEach(durations, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden().fixedSize()
                .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Warning Sound").foregroundStyle(.secondary)
                Toggle("Play sound 60s before sleeping", isOn: $warn).toggleStyle(.checkbox)
            }
            GridRow {
                Text("Menu Bar").foregroundStyle(.secondary)
                Toggle("Show countdown in Menu Bar", isOn: $menuBar).toggleStyle(.checkbox)
            }
        }
    }
}

// MARK: - Shortcuts tab

private struct ShortcutsTab: View {
    @AppStorage("shortcutShowTimer")  private var scShow  = ""
    @AppStorage("shortcutStartTimer") private var scStart = ""

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text("Show Sleep Timer")
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Pill(shortcut: $scShow)
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text("Start Default Timer").foregroundStyle(.secondary)
                Pill(shortcut: $scStart)
            }
            GridRow {
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                Text("Click a field and press a key combination to record.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Shortcut pill field

private struct Pill: View {
    @Binding var shortcut: String
    @State private var recording = false

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if recording {
                    Text("Type shortcut…").italic().foregroundStyle(.tertiary)
                } else if shortcut.isEmpty {
                    Text("None").foregroundStyle(.tertiary)
                } else {
                    Text(shortcut).font(.system(.body, design: .monospaced)).fontWeight(.medium)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: recording)
            Spacer(minLength: 0)
            if !shortcut.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { shortcut = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .frame(width: 210)
        .background(recording ? Color.accentColor.opacity(0.10) : Color.secondary.opacity(0.10))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(
            recording ? Color.accentColor : Color(NSColor.separatorColor),
            lineWidth: recording ? 1.5 : 0.5
        ))
        .contentShape(Capsule())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { recording.toggle() } }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
