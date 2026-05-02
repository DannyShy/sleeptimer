import SwiftUI
import AppKit

struct SettingsTitlebarBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .withinWindow
        view.state = .active
        view.material = .titlebar
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
