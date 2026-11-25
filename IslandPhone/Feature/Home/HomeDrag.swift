import SwiftUI

func finishDrag(_ state: HomeState) {
    if let dragged = state.dragging, case .app(let app) = dragged, let hover = state.hoverKey, state.mergeReady {
        state.mergeInto(dragged: app, targetKey: hover)
    }
    state.clearDrag()
}

func onItemDragMoved(_ state: HomeState) {
    guard let dragged = state.dragging else { return }
    let width = CGFloat(state.pagerWidth)
    if case .app(let app) = dragged {
        let rootPos = CGPoint(x: state.dragPos.x + state.pagerRoot.x, y: state.dragPos.y + state.pagerRoot.y)
        let d = state.dockRect
        let zone = CGRect(x: d.minX, y: d.minY - 16, width: d.width, height: d.height + 32)
        if zone.contains(rootPos) {
            state.hoverKey = nil
            state.mergeReady = false
            state.pendingMove = nil
            if state.dock.contains(app) {
                state.moveInDock(app, target: state.dockSlotAt(rootX: rootPos.x, count: state.dock.count))
            } else if state.dock.count < DockCapacity {
                let gi = state.indexOfKey(dragged.key)
                if gi >= 0 { state.items.remove(at: gi) }
                let slot = state.dockSlotAt(rootX: rootPos.x, count: state.dock.count + 1)
                state.dock.insert(app, at: min(max(slot, 0), state.dock.count))
            }
            return
        }
        if state.dock.contains(app) {
            state.dock.removeAll { $0 == app }
            let c = cellAt(state.dragPos, width: width)
            let raw = state.itemIndexAt(page: state.pagerPage, row: c.row, col: c.col) ?? state.items.count
            let at = min(max(raw, 0), state.items.count)
            state.items.insert(dragged, at: at)
        }
    }
    let cell = cellAt(state.dragPos, width: width)
    let index = state.itemIndexAt(page: state.pagerPage, row: cell.row, col: cell.col)
    var target: HomeItem?
    if let index, state.items.indices.contains(index) {
        target = state.items[index]
    }
    if let target, state.canMerge(dragged: dragged, target: target), inCellCenter(state.dragPos, width: width) {
        state.pendingMove = nil
        if state.hoverKey != target.key {
            state.hoverKey = target.key
            state.mergeReady = false
        }
    } else {
        state.hoverKey = nil
        state.mergeReady = false
        let own = state.indexOfKey(dragged.key)
        if let index, index != own {
            state.pendingMove = index
        } else {
            state.pendingMove = nil
        }
    }
}

func finishWidgetDrag(_ state: HomeState, page: Int, width: CGFloat) {
    if let kind = state.draggingWidget {
        let cellW = gridCellWidth(width)
        if cellW > 0 {
            let base = widgetRect(kind, row: 0, col: 0, width: width)
            let stride = CellHeight + RowGap
            let topLeftX = state.dragPos.x - state.widgetGrab.x
            let topLeftY = state.dragPos.y - state.widgetGrab.y
            let row = Int(((topLeftY - base.y) / stride).rounded())
            let col = Int(((topLeftX - base.x) / cellW).rounded())
            state.dropWidget(kind, page: page, row: row, col: col)
        }
    }
    state.clearDrag()
}
