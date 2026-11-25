import SwiftUI

struct Dock: View {
    let state: HomeState

    @Environment(\.launcher) private var launcher

    var body: some View {
        GlassSurface(shape: RoundedRectangle(cornerRadius: 40, style: .continuous), elevation: 14) {
            GeometryReader { geo in
                dockContent(width: geo.size.width, height: geo.size.height)
            }
        }
        .frame(height: 98)
        .frameReader { rect in state.dockRect = rect }
    }

    private func slotWidth(inner: CGFloat) -> CGFloat {
        let count = max(state.dock.count, 1)
        if count >= DockCapacity {
            return min(inner / CGFloat(DockCapacity), 78)
        }
        return min(inner * 1.2 / (CGFloat(count) + 0.9), inner / CGFloat(count))
    }

    private func dockContent(width: CGFloat, height: CGFloat) -> some View {
        let slot = slotWidth(inner: max(width - 40, 0))
        return HStack(spacing: 0) {
            ForEach(Array(state.dock.enumerated()), id: \.element) { item in
                Jiggle(active: state.editing, seed: item.offset) {
                    AppIcon(app: item.element)
                        .opacity(state.isDragging(.app(item.element)) ? 0 : 1)
                }
                .frame(width: slot, height: 98)
            }
        }
        .frame(width: width, height: height)
        .pageAnimated(.spring(response: 0.4, dampingFraction: 0.8), value: slot)
        .pageAnimated(.spring(response: 0.35, dampingFraction: 0.82), value: state.dock)
        .contentShape(Rectangle())
        .onChange(of: slot, initial: true) { _, value in
            state.dockSlotPx = value
        }
        .holdDrag(
            space: .named("home"),
            onTap: { pos in handleTap(pos) },
            onHoldStart: { pos in startHold(pos) },
            onHoldMove: { pos in moveHold(pos) },
            onHoldEnd: { finishDrag(state) }
        )
    }

    private func slotIndex(local: CGPoint) -> (index: Int, left: CGFloat)? {
        let n = state.dock.count
        let slot = state.dockSlotPx
        if n == 0 || slot <= 0 { return nil }
        let left = state.dockRect.width / 2 - CGFloat(n) * slot / 2
        if local.x < left { return nil }
        let index = Int((local.x - left) / slot)
        if index < 0 || index >= n { return nil }
        return (index, left)
    }

    private func handleTap(_ pos: CGPoint) {
        if state.editing { return }
        let rect = state.dockRect
        let local = CGPoint(x: pos.x - rect.minX, y: pos.y - rect.minY)
        guard let hit = slotIndex(local: local) else { return }
        let slot = state.dockSlotPx
        let cx = hit.left + (CGFloat(hit.index) + 0.5) * slot
        let cy = rect.height / 2
        if abs(local.x - cx) <= 30 && abs(local.y - cy) <= 30 {
            let origin = CGRect(x: rect.minX + cx - 30, y: rect.minY + cy - 30, width: 60, height: 60)
            launcher.open(state.dock[hit.index], origin: origin)
        }
    }

    private func startHold(_ pos: CGPoint) -> Bool {
        let rect = state.dockRect
        let local = CGPoint(x: pos.x - rect.minX, y: pos.y - rect.minY)
        guard let hit = slotIndex(local: local) else { return false }
        state.clearDrag()
        state.dragging = .app(state.dock[hit.index])
        state.dragPos = CGPoint(x: pos.x - state.pagerRoot.x, y: pos.y - state.pagerRoot.y)
        state.editing = true
        return true
    }

    private func moveHold(_ pos: CGPoint) {
        if state.dragging != nil {
            state.dragPos = CGPoint(x: pos.x - state.pagerRoot.x, y: pos.y - state.pagerRoot.y)
            onItemDragMoved(state)
        }
    }
}
