import SwiftUI

enum ThemeMode: String, CaseIterable, Codable {
    case followSystem = "FOLLOW_SYSTEM"
    case day = "DAY"
    case night = "NIGHT"

    var colorScheme: ColorScheme? {
        switch self {
        case .followSystem: return nil
        case .day: return .light
        case .night: return .dark
        }
    }
}

struct IslandTheme {
    var dark: Bool
    var glass: GlassTokens
    var wallpaper: WallpaperTokens
    var icon: IconTokens
    var dots: PageDotTokens
    var folder: FolderTokens
    var widget: WidgetTokens

    static let day = IslandTheme(
        dark: false,
        glass: .day,
        wallpaper: .day,
        icon: .day,
        dots: .day,
        folder: .day,
        widget: .day
    )

    static let night = IslandTheme(
        dark: true,
        glass: .night,
        wallpaper: .night,
        icon: .night,
        dots: .night,
        folder: .night,
        widget: .night
    )
}

private struct IslandThemeKey: EnvironmentKey {
    static let defaultValue = IslandTheme.day
}

extension EnvironmentValues {
    var island: IslandTheme {
        get { self[IslandThemeKey.self] }
        set { self[IslandThemeKey.self] = newValue }
    }
}

struct IslandThemeProvider<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private func resolveDark() -> Bool {
        switch AppearanceStore.shared.themeMode {
        case .day: return false
        case .night: return true
        case .followSystem: return scheme == .dark
        }
    }

    var body: some View {
        content.environment(\.island, resolveDark() ? IslandTheme.night : IslandTheme.day)
    }
}

struct IslandDesktopTheme<Content: View>: View {
    @Environment(\.island) private var base
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private func resolved() -> IslandTheme {
        var theme = base
        guard let luma = AppearanceStore.shared.wallpaperLuma else { return theme }
        let effective = base.dark ? luma * 0.7 : luma
        if effective < 0.55 {
            theme.icon.label = Color.white
            theme.icon.labelShadow = Color(argb: 0x66000000)
        } else {
            theme.icon.label = Color(argb: 0xFF2B2F38)
            theme.icon.labelShadow = Color.clear
        }
        return theme
    }

    var body: some View {
        content.environment(\.island, resolved())
    }
}
