import SwiftUI

struct SubPageScaffold<Content: View, Overlay: View>: View {
    let title: String
    let blockBack: Bool
    let onClose: () -> Void
    let content: Content
    let overlay: Overlay

    @State private var shown: Bool
    @State private var closing = false
    @State private var backProgress: CGFloat = 0

    init(
        title: String,
        blockBack: Bool = false,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.title = title
        self.blockBack = blockBack
        self.onClose = onClose
        self.content = content()
        self.overlay = overlay()
        _shown = State(initialValue: !PageAnimation.motionOn)
    }

    private var appear: CGFloat { shown && !closing ? 1 : 0 }

    var body: some View {
        GeometryReader { geo in
            let motion = PageAnimation.motionOn
            ZStack {
                AppShell(title: title, onBack: { requestClose() }) {
                    ScrollView {
                        VStack(spacing: 16) { content }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                    }
                } overlay: {
                    overlay
                }
                if !closing && !blockBack {
                    EdgeBackStrips(
                        onProgress: { value in backProgress = motion ? value : 0 },
                        onCommit: { requestClose() }
                    )
                }
            }
            .offset(x: motion ? (1 - appear) * geo.size.width + backProgress * geo.size.width * 0.08 : 0)
            .animation(motion ? .spring(response: 0.34, dampingFraction: 0.9) : nil, value: appear)
        }
        .onAppear { shown = true }
        .task(id: closing) {
            if closing {
                if PageAnimation.motionOn {
                    try? await Task.sleep(nanoseconds: 220_000_000)
                }
                onClose()
            }
        }
        .holdShellEdgeBack()
    }

    private func requestClose() {
        if closing { return }
        backProgress = 0
        closing = true
    }
}

extension SubPageScaffold where Overlay == EmptyView {
    init(title: String, onClose: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.init(title: title, blockBack: false, onClose: onClose, content: content, overlay: { EmptyView() })
    }
}
