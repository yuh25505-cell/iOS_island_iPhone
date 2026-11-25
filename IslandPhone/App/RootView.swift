import SwiftUI

struct RootView: View {
    private let store = AppearanceStore.shared

    var body: some View {
        IslandThemeProvider {
            IslandDesktopTheme {
                ZStack {
                    IslandWallpaper(useCustom: true)
                        .ignoresSafeArea()
                    HStack(spacing: 18) {
                        ForEach([AppId.chat, AppId.appearance, AppId.calendar, AppId.music], id: \.self) { app in
                            AppIconWithLabel(app: app)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(store.themeMode.colorScheme)
    }
}

#Preview {
    RootView()
}
