import SwiftUI

typealias AppPage = (@escaping () -> Void) -> AnyView

enum AppPageRegistry {
    static let all: [AppId: AppPage] = [
        .appearance: { onBack in AnyView(AppearancePage(onBack: onBack)) }
    ]
}

private struct AppPagesKey: EnvironmentKey {
    static let defaultValue: [AppId: AppPage] = AppPageRegistry.all
}

extension EnvironmentValues {
    var appPages: [AppId: AppPage] {
        get { self[AppPagesKey.self] }
        set { self[AppPagesKey.self] = newValue }
    }
}
