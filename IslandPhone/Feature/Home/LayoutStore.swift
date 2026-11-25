import Foundation

enum LayoutStore {
    private static let key = "home_layout"
    private static let maxPage = 20

    private struct SavedItem: Codable {
        var t: String
        var app: String?
        var fid: Int?
        var name: String?
        var apps: [String]?
    }

    private struct SavedWidget: Codable {
        var k: String
        var p: Int
        var r: Int
        var c: Int
    }

    private struct SavedLayout: Codable {
        var v: Int
        var items: [SavedItem]
        var widgets: [SavedWidget]
        var dock: [String]
    }

    static func encode(_ state: HomeState) -> Data? {
        let items: [SavedItem] = state.items.map { item in
            switch item {
            case .app(let app):
                return SavedItem(t: "app", app: app.rawValue, fid: nil, name: nil, apps: nil)
            case .folder(let f):
                return SavedItem(t: "folder", app: nil, fid: f.id, name: f.name, apps: f.apps.map { $0.rawValue })
            }
        }
        let widgets = state.widgets.map { SavedWidget(k: $0.kind.rawValue, p: $0.page, r: $0.row, c: $0.col) }
        let layout = SavedLayout(v: 2, items: items, widgets: widgets, dock: state.dock.map { $0.rawValue })
        return try? JSONEncoder().encode(layout)
    }

    static func save(_ data: Data) {
        UserDefaults.standard.set(data, forKey: key)
    }

    static func restore(into state: HomeState) {
        guard let raw = UserDefaults.standard.data(forKey: key),
              let layout = try? JSONDecoder().decode(SavedLayout.self, from: raw) else { return }
        let dock = readDock(layout.dock)
        let items = readItems(layout.items, dock: dock)
        let widgets = readWidgets(layout.widgets, defaults: state.widgets)
        state.restore(savedItems: items, savedWidgets: widgets, savedDock: dock)
    }

    private static func appOf(_ name: String) -> AppId? { AppId(rawValue: name) }

    private static func readDock(_ names: [String]) -> [AppId] {
        var out: [AppId] = []
        for name in names {
            if let app = appOf(name), !out.contains(app), out.count < DockCapacity { out.append(app) }
        }
        return out
    }

    private static func readItems(_ saved: [SavedItem], dock: [AppId]) -> [HomeItem] {
        var seen = Set(dock)
        var usedIds = Set<Int>()
        var out: [HomeItem] = []
        for entry in saved {
            if entry.t == "app" {
                if let name = entry.app, let app = appOf(name), seen.insert(app).inserted {
                    out.append(.app(app))
                }
            } else {
                var apps: [AppId] = []
                for name in entry.apps ?? [] {
                    if let app = appOf(name), seen.insert(app).inserted { apps.append(app) }
                }
                if let id = entry.fid, apps.count >= 2, usedIds.insert(id).inserted {
                    out.append(.folder(FolderData(id: id, name: entry.name ?? DefaultFolderName, apps: apps)))
                } else {
                    apps.forEach { out.append(.app($0)) }
                }
            }
        }
        for app in AppId.allCases where !seen.contains(app) { out.append(.app(app)) }
        return out
    }

    private static func readWidgets(_ saved: [SavedWidget], defaults: [WidgetPlacement]) -> [WidgetPlacement] {
        var out: [WidgetPlacement] = []
        for entry in saved {
            guard let kind = WidgetKind(rawValue: entry.k) else { continue }
            if out.contains(where: { $0.kind == kind }) { return defaults }
            let placement = WidgetPlacement(kind: kind, page: entry.p, row: entry.r, col: entry.c)
            if !fits(placement, others: out) { return defaults }
            out.append(placement)
        }
        for d in defaults where !out.contains(where: { $0.kind == d.kind }) {
            if !fits(d, others: out) { return defaults }
            out.append(d)
        }
        return out
    }

    private static func fits(_ w: WidgetPlacement, others: [WidgetPlacement]) -> Bool {
        if w.page < 0 || w.page > maxPage { return false }
        if w.row < 0 || w.col < 0 { return false }
        if w.row + w.kind.rows > GridRows || w.col + w.kind.cols > GridColumns { return false }
        return !others.contains {
            $0.page == w.page &&
                w.row < $0.row + $0.kind.rows && w.row + w.kind.rows > $0.row &&
                w.col < $0.col + $0.kind.cols && w.col + w.kind.cols > $0.col
        }
    }
}
