import SwiftUI

struct HomeItemIcon: View {
    let item: HomeItem

    var body: some View {
        switch item {
        case .app(let app):
            AppIconWithLabel(app: app)
        case .folder(let folder):
            FolderIconWithLabel(name: folder.name, apps: folder.apps)
        }
    }
}

struct AppGrid: View {
    let page: Int
    let state: HomeState
    let width: CGFloat

    @Environment(\.island) private var theme

    var body: some View {
        let cellW = gridCellWidth(width)
        ZStack(alignment: .topLeading) {
            ForEach(state.placedOn(page: page), id: \.item.key) { placed in
                itemCell(placed, cellW: cellW)
            }
            ForEach(state.widgets.filter { $0.page == page }, id: \.kind) { placement in
                widgetCell(placement)
            }
        }
        .frame(width: width, alignment: .topLeading)
    }

    private func itemCell(_ placed: PlacedItem, cellW: CGFloat) -> some View {
        let item = placed.item
        let scale: CGFloat = state.hoverKey != item.key ? 1 : (state.mergeReady ? 1.2 : 1.08)
        let x = GridPadH + cellW * CGFloat(placed.col)
        let y = GridPadV + (CellHeight + RowGap) * CGFloat(placed.row)
        return Jiggle(active: state.editing, seed: placed.row * GridColumns + placed.col) {
            HomeItemIcon(item: item)
                .opacity(state.isDragging(item) ? 0 : 1)
                .scaleEffect(scale)
                .animation(pageMotionOn ? .spring(response: 0.4, dampingFraction: 0.6) : nil, value: scale)
        }
        .frame(width: cellW, height: CellHeight, alignment: .top)
        .offset(x: x, y: y)
        .pageAnimated(.spring(response: 0.35, dampingFraction: 0.82), value: placed.row * 100 + placed.col)
    }

    private func widgetCell(_ placement: WidgetPlacement) -> some View {
        let rect = widgetRect(placement.kind, row: placement.row, col: placement.col, width: width)
        let seed = WidgetKind.allCases.firstIndex(of: placement.kind) ?? 0
        return VStack(spacing: 6) {
            Jiggle(active: state.editing, seed: seed) {
                WidgetContent(kind: placement.kind)
                    .frame(width: rect.w, height: rect.h)
            }
            if placement.kind != .clock {
                IslandText(
                    placement.kind.title,
                    size: 11,
                    color: theme.icon.label,
                    lineLimit: 1,
                    alignment: .center,
                    shadowColor: theme.icon.labelShadow,
                    shadowRadius: 3
                )
            }
        }
        .frame(width: rect.w)
        .opacity(state.draggingWidget == placement.kind ? 0.3 : 1)
        .offset(x: rect.x, y: rect.y)
    }
}
