import SwiftUI
import UniformTypeIdentifiers

struct FontsSubPage: View {
    let onClose: () -> Void

    private let store = AppearanceStore.shared

    var body: some View {
        FontListSubPage(
            pageTitle: "全局字体",
            cardTitle: "字体",
            fonts: store.fonts,
            activeId: store.activeFontId,
            onSelect: { store.selectFont($0) },
            onDelete: { store.removeFont($0) },
            onImport: { store.importFont(url: $0) },
            onClose: onClose
        )
    }
}

struct EmojiSubPage: View {
    let onClose: () -> Void

    private let store = AppearanceStore.shared

    var body: some View {
        FontListSubPage(
            pageTitle: "表情字体",
            cardTitle: "表情",
            fonts: store.emojis,
            activeId: store.activeEmojiId,
            onSelect: { store.selectEmoji($0) },
            onDelete: { store.removeEmoji($0) },
            onImport: { store.importEmoji(url: $0) },
            onClose: onClose
        )
    }
}

private struct FontListSubPage: View {
    let pageTitle: String
    let cardTitle: String
    let fonts: [FontEntry]
    let activeId: String?
    let onSelect: (String?) -> Void
    let onDelete: (String) -> Void
    let onImport: (URL) -> Bool
    let onClose: () -> Void

    @Environment(\.island) private var theme
    @State private var importing = false
    @State private var failed = false

    var body: some View {
        SubPageScaffold(title: pageTitle, onClose: onClose) {
            SettingCard(title: cardTitle) {
                VStack(spacing: 0) {
                    ChoiceRow(title: "系统默认", selected: activeId == nil) {
                        onSelect(nil)
                    }
                    ForEach(fonts) { entry in
                        ChoiceRow(
                            title: entry.name,
                            selected: activeId == entry.id,
                            onDelete: { onDelete(entry.id) }
                        ) {
                            onSelect(entry.id)
                        }
                    }
                }
            }
            PillButton(title: "添加字体") { importing = true }
        } overlay: {
            if failed {
                toast
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.item]) { result in
            if case .success(let url) = result {
                if !onImport(url) { showFailed() }
            }
        }
    }

    private var toast: some View {
        VStack {
            Spacer()
            GlassSurface(shape: Capsule(), elevation: 8) {
                IslandText("这个字体文件用不了", size: 15, color: theme.icon.label, lineLimit: 1, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .padding(.bottom, 90)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private func showFailed() {
        failed = true
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            failed = false
        }
    }
}
