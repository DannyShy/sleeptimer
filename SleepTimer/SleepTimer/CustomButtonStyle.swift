import SwiftUI

struct TimerButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "313449"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "464a5d"), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct ActiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "e94560"))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
