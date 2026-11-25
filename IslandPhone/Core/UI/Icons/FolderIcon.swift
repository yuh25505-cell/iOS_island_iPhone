import SwiftUI

struct FolderIcon: View {
    let apps: [AppId]
    var size: CGFloat = 60

    @Environment(\.island) private var theme

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
        let pad = size * 0.11
        let gap = size * 0.04
        let cell = (size - pad * 2 - gap * 2) / 3
        GlassSurface(shape: shape, elevation: 6) {
            ZStack {
                Rectangle().fill(theme.icon.tileTint)
                VStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<3, id: \.self) { column in
                                miniTile(index: row * 3 + column, cell: cell)
                            }
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(shape)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func miniTile(index: Int, cell: CGFloat) -> some View {
        if index < apps.count {
            let app = apps[index]
            let tile = RoundedRectangle(cornerRadius: cell * 0.26, style: .continuous)
            ZStack {
                Rectangle().fill(theme.folder.miniTile)
                if let custom = AppearanceStore.shared.icon(for: app) {
                    CoverImage(image: custom)
                } else {
                    AppGlyph(app: app, color: theme.icon.glyph)
                }
            }
            .frame(width: cell, height: cell)
            .clipShape(tile)
        } else {
            Color.clear.frame(width: cell, height: cell)
        }
    }
}

struct FolderIconWithLabel: View {
    let name: String
    let apps: [AppId]
    var size: CGFloat = 60

    @Environment(\.island) private var theme

    var body: some View {
        VStack(spacing: 6) {
            FolderIcon(apps: apps, size: size)
            IslandText(
                name,
                size: 11,
                color: theme.icon.label,
                lineLimit: 1,
                alignment: .center,
                shadowColor: theme.icon.labelShadow,
                shadowRadius: 3
            )
        }
    }
}
