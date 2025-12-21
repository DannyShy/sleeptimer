import SwiftUI
import AppKit

struct MacOSButton: NSViewRepresentable {
    let title: String
    let systemImageName: String?
    let bezelColor: NSColor?
    let contentTintColor: NSColor?
    let isEnabled: Bool
    let action: () -> Void

    init(
        title: String,
        systemImageName: String? = nil,
        bezelColor: NSColor? = nil,
        contentTintColor: NSColor? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.bezelColor = bezelColor
        self.contentTintColor = contentTintColor
        self.isEnabled = isEnabled
        self.action = action
    }

    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: title, target: context.coordinator, action: #selector(Coordinator.didTap))
        button.bezelStyle = .rounded
        button.controlSize = .large
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        button.isBordered = true
        button.refusesFirstResponder = true

        if let systemImageName {
            button.image = NSImage(systemSymbolName: systemImageName, accessibilityDescription: nil)
            button.imagePosition = .imageLeading
        }

        applyColors(button)
        button.isEnabled = isEnabled
        return button
    }

    func updateNSView(_ nsView: NSButton, context: Context) {
        nsView.title = title
        nsView.isEnabled = isEnabled

        if let systemImageName {
            nsView.image = NSImage(systemSymbolName: systemImageName, accessibilityDescription: nil)
            nsView.imagePosition = .imageLeading
        } else {
            nsView.image = nil
        }

        applyColors(nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    private func applyColors(_ button: NSButton) {
        if let bezelColor {
            button.bezelColor = bezelColor
        } else {
            button.bezelColor = nil
        }

        if let contentTintColor {
            button.contentTintColor = contentTintColor
        } else {
            button.contentTintColor = nil
        }
    }

    class Coordinator: NSObject {
        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTap() {
            action()
        }
    }
}

extension NSColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
