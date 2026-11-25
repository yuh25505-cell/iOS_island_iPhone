import Foundation

struct FolderData: Equatable {
    var id: Int
    var name: String
    var apps: [AppId]
}

enum HomeItem: Equatable, Identifiable {
    case app(AppId)
    case folder(FolderData)

    static func appKey(_ app: AppId) -> String { "app:\(app.rawValue)" }

    var key: String {
        switch self {
        case .app(let app): return HomeItem.appKey(app)
        case .folder(let folder): return "folder:\(folder.id)"
        }
    }

    var id: String { key }
}
