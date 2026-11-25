import SwiftUI

typealias AppPage = (@escaping () -> Void) -> AnyView

private struct AppPagesKey: EnvironmentKey {
    static let defaultValue: [AppId: AppPage] = [:]
}

extension EnvironmentValues {
    var appPages: [AppId: AppPage] {
        get { self[AppPagesKey.self] }
        set { self[AppPagesKey.self] = newValue }
    }
}
