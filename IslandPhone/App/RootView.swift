import SwiftUI

struct RootView: View {
    private let store = AppearanceStore.shared

    var body: some View {
        IslandThemeProvider {
            GeometryReader { geo in
                HomeScreen()
                    .environment(\.homeInsets, geo.safeAreaInsets)
            }
        }
        .preferredColorScheme(store.themeMode.colorScheme)
    }
}

#Preview {
    RootView()
}
