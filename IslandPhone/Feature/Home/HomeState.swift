import SwiftUI
import Observation

let DockCapacity = 4

struct PlacedItem {
    let item: HomeItem
    let row: Int
    let col: Int
}

let DefaultWidgets: [WidgetPlacement] = [
    WidgetPlacement(kind: .clock, page: 0, row: 0, col: 0),
    WidgetPlacement(kind: .battery, page: 0, row: 2, col: 2),
    WidgetPlacement(kind: .weather, page: 1, row: 0, col: 0),
    WidgetPlacement(kind: .countdown, page: 1, row: 2, col: 2),
    WidgetPlacement(kind: .photocard, page: 2, row: 0, col: 2),
    WidgetPlacement(kind: .vinyl, page: 2, row: 2, col: 0),
]

@Observable
final class HomeState {
    var items: [HomeItem]
    var dock: [AppId]
    var widgets: [WidgetPlacement]
    var editing = false
    var photoCardOpen = false
    var vinylOpen = false
    var dragging: HomeItem?
    var draggingWidget: WidgetKind?
    var widgetGrab: CGPoint = .zero
    var dragPos: CGPoint = .zero
    var hoverKey: String?
    var mergeReady = false
    var pendingMove: Int?
    var openFolderId: Int?

    @ObservationIgnored var dockRect: CGRect = .zero
    @ObservationIgnored var dockSlotPx: CGFloat = 1
    @ObservationIgnored var pagerRoot: CGPoint = .zero
    @ObservationIgnored var pagerWidth: Int = 0
    @ObservationIgnored var pagerPage: Int = 0
    @ObservationIgnored private var nextFolderId = 1

    init(initial: [AppId] = GridApps) {
        items = initial.map { HomeItem.app($0) }
        dock = DockApps
        widgets = DefaultWidgets
    }

    var openFolder: FolderData? {
        guard let id = openFolderId else { return nil }
        for case .folder(let f) in items where f.id == id { return f }
        return nil
    }

    var isDraggingAny: Bool { dragging != nil || draggingWidget != nil }

    func isDragging(_ item: HomeItem) -> Bool { dragging?.key == item.key }

    func indexOfKey(_ key: String) -> Int {
        items.firstIndex(where: { $0.key == key }) ?? -1
    }

    private func indexOfFolder(_ id: Int) -> Int {
        items.firstIndex(where: {
            if case .folder(let f) = $0 { return f.id == id }
            return false
        }) ?? -1
    }

    func dockSlotAt(rootX: CGFloat, count: Int) -> Int {
        if count <= 0 { return 0 }
        let left = dockRect.midX - CGFloat(count) * dockSlotPx / 2
        let raw = Int((rootX - left) / dockSlotPx)
        return min(max(raw, 0), count - 1)
    }

    func moveInDock(_ app: AppId, target: Int) {
        guard let from = dock.firstIndex(of: app) else { return }
        let to = min(max(target, 0), dock.count - 1)
        if from == to { return }
        dock.remove(at: from)
        dock.insert(app, at: to)
    }

    func widgetAt(page: Int, row: Int, col: Int) -> WidgetPlacement? {
        widgets.first {
            $0.page == page &&
                row >= $0.row && row < $0.row + $0.kind.rows &&
                col >= $0.col && col < $0.col + $0.kind.cols
        }
    }

    private func freeCount(_ page: Int) -> Int {
        GridRows * GridColumns -
            widgets.filter { $0.page == page }.reduce(0) { $0 + $1.kind.cols * $1.kind.rows }
    }

    func pageCount() -> Int {
        let lastWidgetPage = widgets.map { $0.page }.max() ?? 0
        var total = 0
        var p = 0
        while true {
            total += freeCount(p)
            if total >= items.count && p >= lastWidgetPage { return p + 1 }
            p += 1
        }
    }

    private func ordinalOf(page: Int, row: Int, col: Int) -> Int {
        var n = 0
        for p in 0..<page { n += freeCount(p) }
        for r in 0..<GridRows {
            for c in 0..<GridColumns {
                if r == row && c == col { return n }
                if widgetAt(page: page, row: r, col: c) == nil { n += 1 }
            }
        }
        return n
    }

    func itemIndexAt(page: Int, row: Int, col: Int) -> Int? {
        widgetAt(page: page, row: row, col: col) != nil ? nil : ordinalOf(page: page, row: row, col: col)
    }

    func placedOn(page: Int) -> [PlacedItem] {
        var k = 0
        for p in 0..<page { k += freeCount(p) }
        var out: [PlacedItem] = []
        for r in 0..<GridRows {
            for c in 0..<GridColumns {
                if widgetAt(page: page, row: r, col: c) == nil {
                    if k < items.count { out.append(PlacedItem(item: items[k], row: r, col: c)) }
                    k += 1
                }
            }
        }
        return out
    }

    private func widgetFits(_ kind: WidgetKind, page: Int, row: Int, col: Int) -> Bool {
        !widgets.contains {
            $0.kind != kind && $0.page == page &&
                row < $0.row + $0.kind.rows && row + kind.rows > $0.row &&
                col < $0.col + $0.kind.cols && col + kind.cols > $0.col
        }
    }

    func dropWidget(_ kind: WidgetKind, page: Int, row: Int, col: Int) {
        guard let cur = widgets.firstIndex(where: { $0.kind == kind }) else { return }
        var best: WidgetPlacement?
        var bestDist = Int.max
        for r in 0...(GridRows - kind.rows) {
            for c in 0...(GridColumns - kind.cols) {
                if !widgetFits(kind, page: page, row: r, col: c) { continue }
                let d = abs(r - row) + abs(c - col)
                if d < bestDist {
                    bestDist = d
                    best = WidgetPlacement(kind: kind, page: page, row: r, col: c)
                }
            }
        }
        if let target = best { widgets[cur] = target }
    }

    func moveTo(_ key: String, target: Int) {
        let from = indexOfKey(key)
        if from < 0 { return }
        let to = min(max(target, 0), items.count - 1)
        if from == to { return }
        let item = items.remove(at: from)
        items.insert(item, at: to)
    }

    func clearDrag() {
        dragging = nil
        draggingWidget = nil
        hoverKey = nil
        mergeReady = false
        pendingMove = nil
    }

    func canMerge(dragged: HomeItem, target: HomeItem) -> Bool {
        guard case .app = dragged else { return false }
        if dragged.key == target.key { return false }
        switch target {
        case .app: return true
        case .folder(let f): return f.apps.count < FolderCapacity
        }
    }

    func mergeInto(dragged: AppId, targetKey: String) {
        let ti = indexOfKey(targetKey)
        let di = indexOfKey(HomeItem.appKey(dragged))
        if ti < 0 || di < 0 { return }
        switch items[ti] {
        case .folder(var f):
            if f.apps.count >= FolderCapacity { return }
            f.apps.append(dragged)
            items[ti] = .folder(f)
            items.remove(at: di)
        case .app(let target):
            let folder = FolderData(id: nextFolderId, name: DefaultFolderName, apps: [target, dragged])
            nextFolderId += 1
            items[ti] = .folder(folder)
            items.remove(at: di)
        }
    }

    func renameFolder(_ id: Int, name: String) {
        let i = indexOfFolder(id)
        if i < 0 { return }
        guard case .folder(var f) = items[i] else { return }
        f.name = String(name.prefix(FolderNameMax))
        items[i] = .folder(f)
    }

    func restore(savedItems: [HomeItem], savedWidgets: [WidgetPlacement], savedDock: [AppId]) {
        items = savedItems
        widgets = savedWidgets
        dock = savedDock
        var maxId = 0
        for case .folder(let f) in savedItems { maxId = max(maxId, f.id) }
        nextFolderId = maxId + 1
    }

    func closeFolder() {
        if let id = openFolderId {
            let i = indexOfFolder(id)
            if i >= 0, case .folder(var f) = items[i] {
                if f.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    f.name = DefaultFolderName
                    items[i] = .folder(f)
                }
            }
        }
        openFolderId = nil
    }

    func pullOut(_ id: Int, app: AppId) {
        let i = indexOfFolder(id)
        if i < 0 { return }
        guard case .folder(var f) = items[i] else { return }
        let rest = f.apps.filter { $0 != app }
        if rest.count >= 2 {
            f.apps = rest
            items[i] = .folder(f)
            items.insert(.app(app), at: i + 1)
        } else {
            items.remove(at: i)
            let expanded = rest.map { HomeItem.app($0) } + [HomeItem.app(app)]
            items.insert(contentsOf: expanded, at: i)
        }
        openFolderId = nil
    }

    func dissolveFolder(_ id: Int) {
        let i = indexOfFolder(id)
        if i < 0 { return }
        guard case .folder(let f) = items[i] else { return }
        items.remove(at: i)
        items.insert(contentsOf: f.apps.map { HomeItem.app($0) }, at: i)
        openFolderId = nil
    }
}
