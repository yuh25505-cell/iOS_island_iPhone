import SwiftUI

struct Jiggle<Content: View>: View {
    let active: Bool
    let seed: Int
    private let content: Content

    @State private var phase = false

    init(active: Bool, seed: Int, @ViewBuilder content: () -> Content) {
        self.active = active
        self.seed = seed
        self.content = content()
    }

    private var duration: Double {
        0.105 + Double(seed % 4) * 0.014
    }

    var body: some View {
        content
            .rotationEffect(.degrees(active ? (phase ? 1.6 : -1.6) : 0))
            .animation(active ? .linear(duration: duration).repeatForever(autoreverses: true) : nil, value: phase)
            .onChange(of: active, initial: true) { _, on in
                phase = on
            }
    }
}
