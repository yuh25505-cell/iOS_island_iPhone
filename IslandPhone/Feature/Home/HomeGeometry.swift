import SwiftUI

struct CellRect {
    var x: CGFloat
    var y: CGFloat
    var w: CGFloat
    var h: CGFloat
}

struct HomeCell {
    var row: Int
    var col: Int
}

func gridCellWidth(_ width: CGFloat) -> CGFloat {
    (width - GridPadH * 2) / CGFloat(GridColumns)
}

private func clampedIndex(_ value: CGFloat, upper: Int) -> Int {
    if !value.isFinite { return 0 }
    let safe = Int(max(min(value, 10000), -10000))
    return min(max(safe, 0), upper)
}

func widgetRect(_ kind: WidgetKind, row: Int, col: Int, width: CGFloat) -> CellRect {
    let cellW = gridCellWidth(width)
    let stride = CellHeight + RowGap
    let inset = (cellW - 60) / 2
    let ax = GridPadH + CGFloat(col) * cellW + inset
    let aw = CGFloat(kind.cols) * cellW - 2 * inset
    let ay = GridPadV + CGFloat(row) * stride
    let ah = CGFloat(kind.rows - 1) * stride + 60
    if kind == .clock {
        return CellRect(x: ax, y: ay, w: aw, h: ah)
    }
    return CellRect(x: ax - (ah - aw) / 2, y: ay, w: ah, h: ah)
}

func cellAt(_ pos: CGPoint, width: CGFloat) -> HomeCell {
    let cellW = gridCellWidth(width)
    if cellW <= 0 { return HomeCell(row: 0, col: 0) }
    let rowH = CellHeight + RowGap
    return HomeCell(
        row: clampedIndex((pos.y - GridPadV) / rowH, upper: GridRows - 1),
        col: clampedIndex((pos.x - GridPadH) / cellW, upper: GridColumns - 1)
    )
}

func iconCellHit(_ pos: CGPoint, width: CGFloat) -> HomeCell? {
    let cellW = gridCellWidth(width)
    if cellW <= 0 { return nil }
    let stride = CellHeight + RowGap
    let x = pos.x - GridPadH
    let y = pos.y - GridPadV
    if x < 0 || y < 0 || !x.isFinite || !y.isFinite { return nil }
    let col = Int(min(x / cellW, 10000))
    let row = Int(min(y / stride, 10000))
    if col >= GridColumns || row >= GridRows { return nil }
    let insideX = abs(x - (CGFloat(col) + 0.5) * cellW) <= 36
    let insideY = y - CGFloat(row) * stride <= CellHeight
    if insideX && insideY {
        return HomeCell(row: row, col: col)
    }
    return nil
}

func widgetHit(_ state: HomeState, page: Int, pos: CGPoint, width: CGFloat) -> WidgetPlacement? {
    state.widgets.first { w in
        if w.page != page { return false }
        let r = widgetRect(w.kind, row: w.row, col: w.col, width: width)
        return pos.x >= r.x && pos.x <= r.x + r.w && pos.y >= r.y && pos.y <= r.y + r.h
    }
}

func inCellCenter(_ pos: CGPoint, width: CGFloat) -> Bool {
    let cellW = gridCellWidth(width)
    if cellW <= 0 { return false }
    let rowH = CellHeight + RowGap
    let clampedX = min(max(pos.x - GridPadH, 0), cellW * CGFloat(GridColumns) - 1)
    let x = clampedX.truncatingRemainder(dividingBy: cellW) / cellW
    let y = max(pos.y - GridPadV, 0).truncatingRemainder(dividingBy: rowH)
    return x >= 0.2 && x <= 0.8 && y >= 6 && y <= 56
}

private struct HomeInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    var homeInsets: EdgeInsets {
        get { self[HomeInsetsKey.self] }
        set { self[HomeInsetsKey.self] = newValue }
    }
}

struct FrameReader: ViewModifier {
    let space: String
    let onChange: (CGRect) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { onChange(geo.frame(in: .named(space))) }
                    .onChange(of: geo.frame(in: .named(space))) { _, frame in
                        onChange(frame)
                    }
            }
        )
    }
}

extension View {
    func frameReader(in space: String = "home", _ onChange: @escaping (CGRect) -> Void) -> some View {
        modifier(FrameReader(space: space, onChange: onChange))
    }
}
