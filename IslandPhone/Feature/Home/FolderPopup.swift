import SwiftUI
import UIKit

struct FolderPopup: View {
    let state: HomeState

    @Environment(\.island) private var theme
    @Environment(\.launcher) private var launcher

    @State private var shown = false
    @State private var closing = false
    @State private var backProgress: CGFloat = 0
    @State private var gridOrigin: CGPoint = .zero
    @State private var panelRect: CGRect = .zero
    @State private var dragApp: AppId?
    @State private var dragPos: CGPoint = .zero
    @State private var keyboard: CGFloat = 0

    private var appear: Double { shown && !closing ? 1 : 0 }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(theme.folder.scrim)
                .opacity(appear)
                .contentShape(Rectangle())
                .onTapGesture { requestClose() }
            if let folder = state.openFolder {
                panel(folder)
                    .scaleEffect((0.86 + 0.14 * appear) * (1 - 0.12 * backProgress))
                    .opacity(appear)
                    .padding(.bottom, 48 + keyboard)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(pageMotionOn ? .spring(response: 0.34, dampingFraction: 0.82) : nil, value: appear)
        .overlay(alignment: .topLeading) { draggedIcon }
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
                state.closeFolder()
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

    private func panel(_ folder: FolderData) -> some View {
        let tokens = theme.folder
        let shape = RoundedRectangle(cornerRadius: 36, style: .continuous)
        return PopupBackdrop(cornerRadius: 36) {
            GlassSurface(cornerRadius: 36, elevation: 18) {
                VStack(spacing: 0) {
                    IslandTextField("", text: nameBinding(folder.id), size: 20, color: tokens.title)
                        .multilineTextAlignment(.center)
                        .tint(tokens.cursor)
                        .submitLabel(.done)
                        .padding(.vertical, 4)
                    Spacer().frame(height: 10)
                    grid(folder)
                    Spacer().frame(height: 6)
                    dissolveButton(folder.id)
                }
                .padding(.horizontal, FolderPanelPad)
                .padding(.vertical, 18)
                .frame(width: FolderPanelWidth)
                .background(tokens.panelFill)
                .clipShape(shape)
            }
        }
        .frameReader { rect in panelRect = rect }
        .contentShape(Rectangle())
        .onTapGesture { }
    }

    private func nameBinding(_ id: Int) -> Binding<String> {
        Binding(
            get: { state.openFolder?.name ?? "" },
            set: { state.renameFolder(id, name: $0) }
        )
    }

    private func dissolveButton(_ id: Int) -> some View {
        GlassSurface(shape: Capsule(), elevation: 4) {
            IslandText("解散文件夹", size: 15, color: theme.icon.label)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
        }
        .glassPressable { state.dissolveFolder(id) }
    }

    private func grid(_ folder: FolderData) -> some View {
        let rows = max((folder.apps.count + FolderColumns - 1) / FolderColumns, 1)
        return ZStack(alignment: .topLeading) {
            ForEach(Array(folder.apps.enumerated()), id: \.element) { item in
                let r = item.offset / FolderColumns
                let c = item.offset % FolderColumns
                Jiggle(active: state.editing, seed: item.offset) {
                    AppIconWithLabel(app: item.element)
                        .opacity(dragApp == item.element ? 0 : 1)
                }
                .frame(width: FolderCellW, height: FolderCellH, alignment: .top)
                .offset(x: CGFloat(c) * FolderCellW, y: CGFloat(r) * FolderCellH)
            }
        }
        .frame(width: FolderCellW * CGFloat(FolderColumns), height: FolderCellH * CGFloat(rows), alignment: .topLeading)
        .contentShape(Rectangle())
        .frameReader { rect in gridOrigin = rect.origin }
        .holdDrag(
            space: .named("home"),
            onTap: { pos in handleTap(pos, folder: folder) },
            onHoldStart: { pos in startHold(pos, folder: folder) },
            onHoldMove: { pos in
                if dragApp != nil { dragPos = pos }
            },
            onHoldEnd: { endHold(folder: folder) }
        )
    }

    private func appAt(_ pos: CGPoint, folder: FolderData) -> (app: AppId, col: Int, row: Int)? {
        let x = pos.x - gridOrigin.x
        let y = pos.y - gridOrigin.y
        if x < 0 || y < 0 || !x.isFinite || !y.isFinite { return nil }
        let col = Int(min(x / FolderCellW, 1000))
        let row = Int(min(y / FolderCellH, 1000))
        if col >= FolderColumns { return nil }
        let index = row * FolderColumns + col
        if index >= folder.apps.count { return nil }
        return (folder.apps[index], col, row)
    }

    private func handleTap(_ pos: CGPoint, folder: FolderData) {
        if state.editing { return }
        guard let hit = appAt(pos, folder: folder) else { return }
        let left = gridOrigin.x + CGFloat(hit.col) * FolderCellW + (FolderCellW - 60) / 2
        let top = gridOrigin.y + CGFloat(hit.row) * FolderCellH
        launcher.open(hit.app, origin: CGRect(x: left, y: top, width: 60, height: 60))
    }

    private func startHold(_ pos: CGPoint, folder: FolderData) -> Bool {
        guard let hit = appAt(pos, folder: folder) else { return false }
        dragApp = hit.app
        dragPos = pos
        return true
    }

    private func endHold(folder: FolderData) {
        let app = dragApp
        dragApp = nil
        if let app, !panelRect.contains(dragPos) {
            state.pullOut(folder.id, app: app)
        }
    }

    @ViewBuilder
    private var draggedIcon: some View {
        if let app = dragApp {
            AppIconWithLabel(app: app)
                .frame(width: 72, height: 84, alignment: .top)
                .scaleEffect(1.12)
                .offset(x: dragPos.x - 36, y: dragPos.y - 42)
                .allowsHitTesting(false)
        }
    }
}
