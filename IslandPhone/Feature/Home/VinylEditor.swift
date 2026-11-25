import SwiftUI

struct VinylEditor: View {
    let state: HomeState

    @Environment(\.island) private var theme

    var body: some View {
        WidgetEditorPopup(
            avoidKeyboard: false,
            verticalPad: 24,
            onClosed: { state.vinylOpen = false }
        ) { close in
            panelContent(close)
        }
    }

    @ViewBuilder
    private func panelContent(_ close: @escaping () -> Void) -> some View {
        let store = VinylStore.shared
        VStack(spacing: 0) {
            ImagePickThumb(
                image: store.cover,
                width: 140,
                height: 140,
                shape: Circle(),
                tint: theme.icon.label,
                onPicked: { store.importCover($0) }
            )
            Spacer().frame(height: 20)
            HStack(spacing: 12) {
                WidgetEditorButton(title: "恢复默认") { store.reset() }
                WidgetEditorButton(title: "完成") { close() }
            }
        }
    }
}
