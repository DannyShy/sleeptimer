import SwiftUI
import AppKit

// MARK: - Tab enum

private enum STab: String, CaseIterable, Identifiable {
    case general, timer, shortcuts
    var id: String { rawValue }
    var label: String {
        switch self { case .general: L("General"); case .timer: L("Timer"); case .shortcuts: L("Shortcuts") }
    }
    var icon: String {
        switch self { case .general: "gearshape.fill"; case .timer: "timer"; case .shortcuts: "keyboard" }
    }
}

// MARK: - Grid constants

private let kLabelW: CGFloat = 160

// MARK: - SettingsView

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var tab: STab = .general

    var body: some View {
        VStack(spacing: 0) {

            // ── Header with titlebar material ────────────────────────
            ZStack {
                SettingsTitlebarBackground()

                VStack(spacing: 0) {
                    Text(L("Sleep Timer Settings"))
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)

                    HStack(spacing: 0) {
                        Spacer()
                        ForEach(STab.allCases) { t in
                            STabButton(tab: t, active: tab == t) { tab = t }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(height: 90)
            .clipped()

            // ── 1px separator ────────────────────────────────────────
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1)

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
                Divider()
                    .padding(.horizontal, 20)

                // ── Footer ──────────────────────────────────────────
                HStack {
                    Text(SettingsManager.shared.versionString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(L("Export logs")) { SettingsManager.shared.exportLogs() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .padding(.bottom, 6)
            }
        }
        .frame(width: 500, height: 320, alignment: .top)
        .ignoresSafeArea()
    }
}

// MARK: - Tab button

private struct STabButton: View {
    let tab: STab
    let active: Bool
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: active ? .semibold : .regular))
                Text(tab.label)
                    .font(.system(size: 10, weight: active ? .medium : .regular))
            }
            .foregroundStyle(active ? Color.white : Color.secondary)
            .frame(width: 84)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(active ? Color.accentColor : (isHovering ? Color.secondary.opacity(0.12) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeInOut(duration: 0.12), value: isHovering)
    }
}

// MARK: - General tab

private struct GeneralTab: View {
    @ObservedObject private var settings = SettingsManager.shared
    @AppStorage("openAtLogin")   private var openAtLogin  = false
    @AppStorage("showDockIcon")  private var showDockIcon = false
    @AppStorage("appLanguage")   private var language     = "English"
    @AppStorage("appAppearance") private var appearance   = "System"

    private let langs = ["English", "Slovak", "German", "French", "Spanish"]
    private let modes = ["Light", "Dark", "System"]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text(L("Open at Login"))
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Toggle("", isOn: $openAtLogin)
                    .toggleStyle(.checkbox).labelsHidden()
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text(L("Show Icon in Dock")).foregroundStyle(.secondary)
                Toggle("", isOn: $showDockIcon).toggleStyle(.checkbox).labelsHidden()
            }
            GridRow {
                Text(L("Language")).foregroundStyle(.secondary)
                Picker("", selection: $language) {
                    ForEach(langs, id: \.self) { Text($0).tag($0) }
                }
                .labelsHidden().frame(width: 150)
            }
            GridRow {
                Text(L("Appearance")).foregroundStyle(.secondary)
                Picker("", selection: $appearance) {
                    ForEach(modes, id: \.self) { mode in
                        Text(L(mode)).tag(mode)
                    }
                }
                .labelsHidden().pickerStyle(.segmented).frame(width: 195)
                .id(settings.appLanguage)
            }
        }
        .onChange(of: openAtLogin)  { _, val in SettingsManager.shared.setOpenAtLogin(val) }
        .onChange(of: showDockIcon) { _, val in SettingsManager.shared.setDockIconVisible(val) }
        .onChange(of: appearance)   { _, val in SettingsManager.shared.applyAppearance(val) }
        .onChange(of: language)     { _, val in SettingsManager.shared.setLanguage(val) }
    }
}

// MARK: - Timer tab

private struct TimerTab: View {
    @ObservedObject private var settings = SettingsManager.shared
    @AppStorage("defaultDuration")      private var dur      = "30 min"
    @AppStorage("warningSoundEnabled")  private var warn     = true
    @AppStorage("showCountdownMenuBar") private var menuBar  = false

    private let durations = ["30 min", "45 min", "1h", "Last used"]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text(L("Default Duration"))
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Picker("", selection: $dur) {
                    ForEach(durations, id: \.self) { Text(L($0)).tag($0) }
                }
                .labelsHidden().frame(width: 150)
                .gridColumnAlignment(.leading)
            }
            GridRow {
                Text(L("Warning Sound")).foregroundStyle(.secondary)
                Toggle(L("Play sound 60s before sleeping"), isOn: $warn).toggleStyle(.checkbox)
            }
            GridRow {
                Text(L("Menu Bar")).foregroundStyle(.secondary)
                Toggle(L("Show countdown in Menu Bar"), isOn: $menuBar).toggleStyle(.checkbox)
            }
        }
        .onChange(of: dur)     { _, val in SettingsManager.shared.log("Default duration: \(val)") }
        .onChange(of: warn)    { _, val in SettingsManager.shared.log("Warning sound: \(val)") }
        .onChange(of: menuBar) { _, val in SettingsManager.shared.log("Menu bar countdown: \(val)") }
    }
}

// MARK: - Shortcuts tab

private struct ShortcutsTab: View {
    @ObservedObject private var settings = SettingsManager.shared
    @AppStorage("shortcutShowTimer")  private var scShow  = ""
    @AppStorage("shortcutStartTimer") private var scStart = ""

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            GridRow {
                Text(L("Show Sleep Timer"))
                    .foregroundStyle(.secondary)
                    .frame(width: kLabelW, alignment: .trailing)
                    .gridColumnAlignment(.trailing)
                Pill(shortcut: $scShow)
                    .gridColumnAlignment(.leading)
            }
            GridRow {
                Text(L("Start Default Timer")).foregroundStyle(.secondary)
                Pill(shortcut: $scStart)
            }
            GridRow {
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                Text(L("Click a field and press a key combination to record."))
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
    @State private var eventMonitor: Any?

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if recording {
                    Text(L("Type shortcut…")).italic().foregroundStyle(.tertiary)
                } else if shortcut.isEmpty {
                    Text(L("None")).foregroundStyle(.tertiary)
                } else {
                    Text(shortcut).font(.system(.body, design: .monospaced)).fontWeight(.medium)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: recording)
            Spacer(minLength: 0)
            if !shortcut.isEmpty && !recording {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { shortcut = "" }
                    SettingsManager.shared.registerGlobalShortcuts()
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
        .onTapGesture { toggleRecording() }
        .onDisappear { stopRecording() }
    }

    private func toggleRecording() {
        if recording {
            withAnimation(.easeInOut(duration: 0.15)) { recording = false }
            stopRecording()
        } else {
            withAnimation(.easeInOut(duration: 0.15)) { recording = true }
            startRecording()
        }
    }

    private func startRecording() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Escape — cancel recording
                withAnimation(.easeInOut(duration: 0.15)) { recording = false }
                stopRecording()
                return nil
            }
            if let sc = SettingsManager.shortcutString(from: event) {
                shortcut = sc
                withAnimation(.easeInOut(duration: 0.15)) { recording = false }
                stopRecording()
                SettingsManager.shared.registerGlobalShortcuts()
                SettingsManager.shared.log("Shortcut recorded: \(sc)")
                return nil
            }
            return event
        }
    }

    private func stopRecording() {
        if let m = eventMonitor { NSEvent.removeMonitor(m); eventMonitor = nil }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
