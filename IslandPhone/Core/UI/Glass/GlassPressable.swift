import SwiftUI

struct GlassPressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension View {
    func glassPressable(action: @escaping () -> Void) -> some View {
        Button(action: action) { self }
            .buttonStyle(GlassPressableStyle())
    }
}
