import SwiftUI
import PhotosUI

struct IconEditorPopup: View {
    let app: AppId
    let onClosed: () -> Void

    private let store = AppearanceStore.shared

    @Environment(\.island) private var theme
    @State private var shown = false
    @State private var closing = false
    @State private var backProgress: CGFloat = 0
    @State private var item: PhotosPickerItem?

    private var appear: Double { shown && !closing ? 1 : 0 }

    var body: some View {
        let tokens = theme.folder
        let shape = RoundedRectangle(cornerRadius: 36, style: .continuous)
        ZStack {
            Rectangle()
                .fill(tokens.scrim)
                .opacity(appear)
                .contentShape(Rectangle())
                .onTapGesture { requestClose() }
            PopupBackdrop(cornerRadius: 36) {
                GlassSurface(cornerRadius: 36, elevation: 18) {
                    panel
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .frame(width: 280)
                        .background(tokens.panelFill)
                        .clipShape(shape)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { }
            .scaleEffect((0.86 + 0.14 * appear) * (1 - 0.12 * backProgress))
            .opacity(appear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(PageAnimation.motionOn ? .spring(response: 0.34, dampingFraction: 0.82) : nil, value: appear)
        .overlay {
            if !closing {
                EdgeBackStrips(
                    onProgress: { value in backProgress = PageAnimation.motionOn ? value : 0 },
                    onCommit: { requestClose() }
                )
            }
        }
        .onAppear { shown = true }
        .task(id: closing) {
            if closing {
                if PageAnimation.motionOn {
                    try? await Task.sleep(nanoseconds: 160_000_000)
                }
                onClosed()
            }
        }
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    _ = store.importIcon(app, data: data)
                }
                item = nil
            }
        }
        .holdShellEdgeBack()
    }

    private var panel: some View {
        VStack(spacing: 0) {
            PhotosPicker(selection: $item, matching: .images) {
                AppIcon(app: app, size: 96)
            }
            .buttonStyle(GlassPressableStyle())
            IslandText(app.label, size: 17, weight: .semibold, color: theme.icon.label, lineLimit: 1, alignment: .center)
                .padding(.top, 14)
            PhotosPicker(selection: $item, matching: .images) {
                PillLabel(title: "更换图片")
            }
            .buttonStyle(GlassPressableStyle())
            .padding(.top, 20)
            HStack(spacing: 12) {
                PillButton(title: "恢复默认", enabled: store.icon(for: app) != nil) {
                    store.resetIcon(app)
                }
                PillButton(title: "完成") { requestClose() }
            }
            .padding(.top, 12)
        }
    }

    private func requestClose() {
        if closing { return }
        closing = true
    }
}
