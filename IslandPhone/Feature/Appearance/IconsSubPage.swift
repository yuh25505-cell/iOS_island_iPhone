import SwiftUI

struct IconsSubPage: View {
    let onClose: () -> Void

    private let store = AppearanceStore.shared
    private let apps: [AppId] = AppId.allCases.filter { !$0.adminOnly }

    @State private var editing: AppId?

    var body: some View {
        SubPageScaffold(title: "应用图标", blockBack: editing != nil, onClose: onClose) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 4),
                spacing: 16
            ) {
                ForEach(apps, id: \.self) { app in
                    AppIconWithLabel(app: app)
                        .frame(width: 72)
                        .glassPressable { editing = app }
                }
            }
            PillButton(title: "全部图标恢复默认", enabled: store.hasCustomIcons) {
                store.resetAllIcons()
            }
        } overlay: {
            if let target = editing {
                IconEditorPopup(app: target, onClosed: { editing = nil })
            }
        }
    }
}
