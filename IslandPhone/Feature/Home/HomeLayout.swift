import CoreGraphics

let DockApps: [AppId] = [.chat, .phone, .album, .settings]

let GridApps: [AppId] = AppId.allCases.filter { !DockApps.contains($0) }

let GridColumns = 4
let GridRows = 4
let AppsPerPage = GridColumns * GridRows

let GridPadH: CGFloat = 16
let GridPadV: CGFloat = 8
let CellHeight: CGFloat = 84
let RowGap: CGFloat = 22

let FolderColumns = 3
let FolderCapacity = 9
let FolderNameMax = 10
let DefaultFolderName = "文件夹"

let FolderCellW: CGFloat = 84
let FolderCellH: CGFloat = 98
let FolderPanelPad: CGFloat = 20
let FolderPanelWidth: CGFloat = FolderCellW * CGFloat(FolderColumns) + FolderPanelPad * 2

func paginate<T>(_ items: [T], perPage: Int = AppsPerPage) -> [[T]] {
    if items.isEmpty { return [[]] }
    var out: [[T]] = []
    var i = 0
    while i < items.count {
        out.append(Array(items[i..<min(i + perPage, items.count)]))
        i += perPage
    }
    return out
}
