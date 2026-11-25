import SwiftUI
import PhotosUI

struct AppearancePage: View {
    let onBack: () -> Void

    private let store = AppearanceStore.shared
    private let glass = GlassSettings.shared

    @Environment(\.island) private var theme
    @State private var iconsOpen = false
    @State private var fontsOpen = false
    @State private var emojiOpen = false
    @State private var glassOpen = false
    @State private var wallpaperItem: PhotosPickerItem?

    private var glassIsDefault: Bool {
        abs(glass.tint - 0.8) < 0.001 && abs(glass.shadow - 0.2) < 0.001 && glass.enabled
    }

    var body: some View {
        ZStack {
            AppShell(title: "外观", onBack: onBack) {
                ScrollView {
                    VStack(spacing: 16) {
                        modeCard
                        wallpaperCard
                        glassCard
                        iconsCard
                        fontCard
                        emojiCard
                        animationCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            if iconsOpen {
                IconsSubPage(onClose: { iconsOpen = false })
            }
            if fontsOpen {
                FontsSubPage(onClose: { fontsOpen = false })
            }
            if emojiOpen {
                EmojiSubPage(onClose: { emojiOpen = false })
            }
            if glassOpen {
                GlassSubPage(onClose: { glassOpen = false })
            }
        }
        .onChange(of: wallpaperItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    _ = store.importWallpaper(data: data)
                }
                wallpaperItem = nil
            }
        }
    }

    private var modeCard: some View {
        SettingCard(title: "显示模式") {
            VStack(spacing: 0) {
                ChoiceRow(title: "跟随系统", selected: store.themeMode == .followSystem) {
                    store.setThemeMode(.followSystem)
                }
                ChoiceRow(title: "日间", selected: store.themeMode == .day) {
                    store.setThemeMode(.day)
                }
                ChoiceRow(title: "夜间", selected: store.themeMode == .night) {
                    store.setThemeMode(.night)
                }
            }
        }
    }

    private var wallpaperCard: some View {
        SettingCard(
            title: "壁纸",
            action: { MinusButton(enabled: store.wallpaper != nil) { store.resetWallpaper() } },
            content: {
                PhotosPicker(selection: $wallpaperItem, matching: .images) {
                    EntryRowLabel(title: "主页背景") { WallpaperThumb() }
                }
                .buttonStyle(GlassPressableStyle())
            }
        )
    }

    private var glassCard: some View {
        SettingCard(
            title: "玻璃",
            action: { MinusButton(enabled: !glassIsDefault) { glass.reset() } },
            content: {
                EntryRow(title: "液态玻璃", action: { glassOpen = true })
            }
        )
    }

    private var iconsCard: some View {
        SettingCard(title: "图标") {
            EntryRow(title: "应用图标", action: { iconsOpen = true })
        }
    }

    private var fontCard: some View {
        SettingCard(
            title: "字体",
            action: { MinusButton(enabled: store.hasCustomFont) { store.resetFont() } },
            content: {
                EntryRow(title: "全局字体", action: { fontsOpen = true }, trailing: {
                    IslandText("Aa字", size: 15, color: theme.icon.label.opacity(0.6))
                })
            }
        )
    }

    private var emojiCard: some View {
        SettingCard(
            title: "表情",
            action: { MinusButton(enabled: store.hasEmojiFont) { store.resetEmoji() } },
            content: {
                EntryRow(title: "表情字体", action: { emojiOpen = true }, trailing: {
                    IslandText("😀", size: 17)
                })
            }
        )
    }

    private var animationCard: some View {
        SettingCard(title: "动画") {
            SwitchRow(title: "进出与返回动画", checked: store.pageAnimation) { value in
                store.setPageAnimation(value)
            }
        }
    }
}
