import SwiftUI

struct HomePager: View {
    let state: HomeState

    @Environment(\.launcher) private var launcher
    @State private var page = 0
    @State private var swipeX: CGFloat = 0
    @State private var boxWidth: CGFloat = 0

    private var edge: Int {
        if !state.isDraggingAny || boxWidth <= 0 { return 0 }
        if state.dragPos.x < 32 { return -1 }
        if state.dragPos.x > boxWidth - 32 { return 1 }
        return 0
    }

    var body: some View {
        let pageCount = state.pageCount()
        VStack(spacing: 0) {
            GeometryReader { geo in
                pagerBody(width: geo.size.width, height: geo.size.height, pageCount: pageCount)
            }
            PageDots(count: pageCount, current: page)
                .padding(.vertical, 10)
        }
        .onChange(of: pageCount) { _, count in
            if page >= count { page = max(count - 1, 0) }
        }
        .onChange(of: page, initial: true) { _, value in
            state.pagerPage = value
        }
        .task(id: edge) { await runEdgeFlip() }
        .task(id: state.pendingMove) { await runPendingMove() }
        .task(id: state.hoverKey) { await runMergeTimer() }
    }

    private func pagerBody(width w: CGFloat, height h: CGFloat, pageCount: Int) -> some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ForEach(0..<pageCount, id: \.self) { index in
                    AppGrid(page: index, state: state, width: w)
                        .frame(width: w, height: h, alignment: .topLeading)
                }
            }
            .frame(width: w * CGFloat(max(pageCount, 1)), height: h, alignment: .leading)
            .offset(x: -CGFloat(page) * w + swipeX)
            draggedItem
            draggedWidget(width: w)
        }
        .frame(width: w, height: h, alignment: .topLeading)
        .contentShape(Rectangle())
        .frameReader { rect in state.pagerRoot = rect.origin }
        .onAppear {
            boxWidth = w
            state.pagerWidth = Int(w)
        }
        .onChange(of: w) { _, value in
            boxWidth = value
            state.pagerWidth = Int(value)
        }
        .holdDrag(
            space: .local,
            onTap: { pos in handleTap(pos, width: w) },
            onHoldStart: { pos in startHold(pos, width: w) },
            onHoldMove: { pos in moveHold(pos) },
            onHoldEnd: { endHold(width: w) },
            onSwipeChange: { dx in swipeChanged(dx) },
            onSwipeEnd: { dx, predicted in swipeEnded(dx, predicted, width: w) }
        )
    }

    @ViewBuilder
    private var draggedItem: some View {
        if let dragged = state.dragging {
            HomeItemIcon(item: dragged)
                .frame(width: 72, height: 84, alignment: .top)
                .scaleEffect(1.12)
                .offset(x: state.dragPos.x - 36, y: state.dragPos.y - 42)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func draggedWidget(width w: CGFloat) -> some View {
        if let kind = state.draggingWidget {
            let rect = widgetRect(kind, row: 0, col: 0, width: w)
            WidgetContent(kind: kind)
                .frame(width: rect.w, height: rect.h)
                .scaleEffect(1.05)
                .offset(x: state.dragPos.x - state.widgetGrab.x, y: state.dragPos.y - state.widgetGrab.y)
                .allowsHitTesting(false)
        }
    }

    private func handleTap(_ pos: CGPoint, width w: CGFloat) {
        if !state.editing, let hit = widgetHit(state, page: page, pos: pos, width: w) {
            if hit.kind == .photocard {
                state.photoCardOpen = true
            } else if hit.kind == .vinyl {
                state.vinylOpen = true
            }
            return
        }
        let cell = cellAt(pos, width: w)
        let index = state.itemIndexAt(page: page, row: cell.row, col: cell.col)
        var item: HomeItem?
        if let index, state.items.indices.contains(index) {
            item = state.items[index]
        }
        if case .folder(let folder)? = item {
            state.openFolderId = folder.id
            return
        }
        if case .app(let app)? = item, !state.editing {
            if let hit = iconCellHit(pos, width: w) {
                let cellW = gridCellWidth(w)
                let stride = CellHeight + RowGap
                let left = state.pagerRoot.x + GridPadH + CGFloat(hit.col) * cellW + (cellW - 60) / 2
                let top = state.pagerRoot.y + GridPadV + CGFloat(hit.row) * stride
                launcher.open(app, origin: CGRect(x: left, y: top, width: 60, height: 60))
            }
            return
        }
        if state.editing && index != nil && item == nil {
            state.editing = false
        }
    }

    private func startHold(_ pos: CGPoint, width w: CGFloat) -> Bool {
        if let widget = widgetHit(state, page: page, pos: pos, width: w) {
            state.clearDrag()
            let rect = widgetRect(widget.kind, row: widget.row, col: widget.col, width: w)
            state.draggingWidget = widget.kind
            state.widgetGrab = CGPoint(x: pos.x - rect.x, y: pos.y - rect.y)
            state.dragPos = pos
            state.editing = true
            return true
        }
        guard let cell = iconCellHit(pos, width: w),
              let index = state.itemIndexAt(page: page, row: cell.row, col: cell.col),
              state.items.indices.contains(index) else { return false }
        state.clearDrag()
        state.dragging = state.items[index]
        state.dragPos = pos
        state.editing = true
        return true
    }

    private func moveHold(_ pos: CGPoint) {
        if state.draggingWidget != nil {
            state.dragPos = pos
        } else if state.dragging != nil {
            state.dragPos = pos
            onItemDragMoved(state)
        }
    }

    private func endHold(width w: CGFloat) {
        if state.draggingWidget != nil {
            finishWidgetDrag(state, page: page, width: w)
        } else {
            finishDrag(state)
        }
    }

    private func swipeChanged(_ dx: CGFloat) {
        let last = state.pageCount() - 1
        var x = dx
        if (page == 0 && dx > 0) || (page >= last && dx < 0) {
            x = dx / 3
        }
        swipeX = x
    }

    private func swipeEnded(_ dx: CGFloat, _ predicted: CGFloat, width w: CGFloat) {
        let last = max(state.pageCount() - 1, 0)
        let threshold = w * 0.3
        var target = page
        if predicted < -threshold || dx < -threshold {
            target = min(page + 1, last)
        } else if predicted > threshold || dx > threshold {
            target = max(page - 1, 0)
        }
        setPage(target)
    }

    private func setPage(_ target: Int) {
        withPageAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
            page = target
            swipeX = 0
        }
    }

    @MainActor
    private func runEdgeFlip() async {
        let dir = edge
        guard dir != 0 else { return }
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 600_000_000)
            if Task.isCancelled { return }
            let target = page + dir
            if target < 0 || target >= state.pageCount() { return }
            setPage(target)
            if let dragged = state.dragging {
                let cell = cellAt(state.dragPos, width: boxWidth)
                if let index = state.itemIndexAt(page: target, row: cell.row, col: cell.col) {
                    state.moveTo(dragged.key, target: index)
                }
            }
        }
    }

    @MainActor
    private func runPendingMove() async {
        guard let target = state.pendingMove else { return }
        try? await Task.sleep(nanoseconds: 220_000_000)
        if Task.isCancelled { return }
        if let dragged = state.dragging, state.pendingMove == target {
            withPageAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                state.moveTo(dragged.key, target: target)
            }
            state.pendingMove = nil
        }
    }

    @MainActor
    private func runMergeTimer() async {
        guard state.hoverKey != nil else { return }
        try? await Task.sleep(nanoseconds: 450_000_000)
        if Task.isCancelled { return }
        state.mergeReady = true
    }
}
