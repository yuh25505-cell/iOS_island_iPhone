import SwiftUI
import PhotosUI
import UIKit

struct WidgetEditorPopup<Content: View>: View {
    let avoidKeyboard: Bool
    let verticalPad: CGFloat
    let onClosed: () -> Void
    let content: (_ close: @escaping () -> Void) -> Content

    @Environment(\.island) private var theme

    @State private var shown = false
    @State private var closing = false
    @State private var backProgress: CGFloat = 0
    @State private var keyboard: CGFloat = 0

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
                    content(requestClose)
                        .padding(.horizontal, FolderPanelPad)
                        .padding(.vertical, verticalPad)
                        .frame(width: FolderPanelWidth)
                        .background(tokens.panelFill)
                        .clipShape(shape)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { }
            .scaleEffect((0.86 + 0.14 * appear) * (1 - 0.12 * backProgress))
            .opacity(appear)
            .padding(.bottom, avoidKeyboard ? keyboard : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(pageMotionOn ? .spring(response: 0.34, dampingFraction: 0.82) : nil, value: appear)
        .overlay {
            if !closing {
                EdgeBackStrips(
                    onProgress: { value in backProgress = pageMotionOn ? value : 0 },
                    onCommit: { requestClose() }
                )
            }
        }
        .onAppear { shown = true }
        .task(id: closing) {
            if closing {
                if pageMotionOn {
                    try? await Task.sleep(nanoseconds: 160_000_000)
                }
                onClosed()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            let end = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
            let screen = UIScreen.main.bounds.height
            let height = max(0, screen - end.minY)
            withAnimation(.easeOut(duration: 0.25)) { keyboard = height }
        }
    }

    private func requestClose() {
        hideKeyboard()
        closing = true
    }
}

struct WidgetEditorButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.island) private var theme

    var body: some View {
        GlassSurface(shape: Capsule(), elevation: 4) {
            IslandText(title, size: 15, color: theme.icon.label, lineLimit: 1, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .glassPressable(action: action)
    }
}

struct ImagePickThumb<S: Shape>: View {
    let image: UIImage?
    let width: CGFloat
    let height: CGFloat
    let shape: S
    let tint: Color
    let onPicked: (Data) -> Void

    @State private var item: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $item, matching: .images) {
            thumb
        }
        .buttonStyle(GlassPressableStyle())
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    onPicked(data)
                }
                item = nil
            }
        }
    }

    private var thumb: some View {
        shape
            .fill(tint.opacity(0.12))
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Canvas { context, size in
                        var cross = Path()
                        cross.move(to: CGPoint(x: 0, y: size.height / 2))
                        cross.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                        cross.move(to: CGPoint(x: size.width / 2, y: 0))
                        cross.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                        context.stroke(cross, with: .color(tint.opacity(0.6)), lineWidth: 2)
                    }
                    .frame(width: 22, height: 22)
                }
            }
            .clipShape(shape)
            .frame(width: width, height: height)
    }
}
