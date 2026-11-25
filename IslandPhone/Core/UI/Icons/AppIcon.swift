import SwiftUI

struct AppIcon: View {
    let app: AppId
    var size: CGFloat = 60

    @Environment(\.island) private var theme

    var body: some View {
        let custom = AppearanceStore.shared.icon(for: app)
        let shape = RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
        GlassSurface(shape: shape, elevation: 6) {
            ZStack {
                if let custom {
                    CoverImage(image: custom)
                } else {
                    Rectangle().fill(theme.icon.tileTint)
                    AppGlyph(app: app, color: theme.icon.glyphShadow)
                        .offset(y: size * 0.015)
                    AppGlyph(app: app, color: theme.icon.glyph)
                }
            }
            .frame(width: size, height: size)
            .clipShape(shape)
        }
        .frame(width: size, height: size)
    }
}

struct AppIconWithLabel: View {
    let app: AppId
    var size: CGFloat = 60

    @Environment(\.island) private var theme

    var body: some View {
        VStack(spacing: 6) {
            AppIcon(app: app, size: size)
            IslandText(
                app.label,
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
