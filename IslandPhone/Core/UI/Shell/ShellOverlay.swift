import SwiftUI
import Observation

@Observable
final class ShellOverlayState {
    var count: Int = 0
}

private struct ShellOverlayKey: EnvironmentKey {
    static let defaultValue = ShellOverlayState()
}

extension EnvironmentValues {
    var shellOverlay: ShellOverlayState {
        get { self[ShellOverlayKey.self] }
        set { self[ShellOverlayKey.self] = newValue }
    }
}

struct HoldShellEdgeBack: ViewModifier {
    @Environment(\.shellOverlay) private var state

    func body(content: Content) -> some View {
        content
            .onAppear { state.count += 1 }
            .onDisappear { state.count -= 1 }
    }
}

extension View {
    func holdShellEdgeBack() -> some View {
        modifier(HoldShellEdgeBack())
    }
}
