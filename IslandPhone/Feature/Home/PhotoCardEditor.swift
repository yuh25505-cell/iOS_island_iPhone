import SwiftUI

struct PhotoCardEditor: View {
    let state: HomeState

    @Environment(\.island) private var theme

    var body: some View {
        WidgetEditorPopup(
            avoidKeyboard: true,
            verticalPad: 20,
            onClosed: { state.photoCardOpen = false }
        ) { close in
            panelContent(close)
        }
    }

    @ViewBuilder
    private func panelContent(_ close: @escaping () -> Void) -> some View {
        let store = PhotoCardStore.shared
        let label = theme.icon.label
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ImagePickThumb(
                    image: store.avatar,
                    width: 64,
                    height: 64,
                    shape: Circle(),
                    tint: label,
                    onPicked: { store.importImage($0, key: PhotoCardStore.avatarKey) }
                )
                ImagePickThumb(
                    image: store.photo,
                    width: 156,
                    height: 64,
                    shape: RoundedRectangle(cornerRadius: 16, style: .continuous),
                    tint: label,
                    onPicked: { store.importImage($0, key: PhotoCardStore.photoKey) }
                )
            }
            Spacer().frame(height: 14)
            CardField(title: "名字", value: store.name, limit: 10, multiLine: false) { store.updateName($0) }
            Spacer().frame(height: 8)
            CardField(title: "话题", value: store.topic, limit: 8, multiLine: false) { store.updateTopic($0) }
            Spacer().frame(height: 8)
            CardField(title: "文案", value: store.body, limit: 40, multiLine: true) { store.updateBody($0) }
            Spacer().frame(height: 8)
            CardField(title: "音乐", value: store.music, limit: 16, multiLine: false) { store.updateMusic($0) }
            Spacer().frame(height: 16)
            HStack(spacing: 12) {
                WidgetEditorButton(title: "恢复默认") { store.reset() }
                WidgetEditorButton(title: "完成") { close() }
            }
        }
    }
}

private struct CardField: View {
    let title: String
    let value: String
    let limit: Int
    let multiLine: Bool
    let onChange: (String) -> Void

    @Environment(\.island) private var theme

    var body: some View {
        let tokens = theme.folder
        HStack(alignment: .top, spacing: 0) {
            IslandText(title, size: 15, color: tokens.title.opacity(0.55))
                .frame(width: 40, alignment: .leading)
            IslandTextField(
                "",
                text: Binding(get: { value }, set: { handle($0) }),
                size: 15,
                color: tokens.title,
                axis: multiLine ? .vertical : .horizontal,
                maxLines: 3
            )
            .tint(tokens.cursor)
            .submitLabel(.done)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tokens.title.opacity(0.08))
        )
    }

    private func handle(_ raw: String) {
        if raw.contains("\n") { hideKeyboard() }
        onChange(String(raw.replacingOccurrences(of: "\n", with: "").prefix(limit)))
    }
}
