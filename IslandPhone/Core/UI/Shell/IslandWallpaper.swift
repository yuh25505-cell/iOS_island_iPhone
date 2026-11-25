import SwiftUI

struct IslandWallpaper: View {
    var useCustom: Bool = false

    @Environment(\.island) private var theme

    var body: some View {
        let tokens = theme.wallpaper
        let custom = useCustom ? AppearanceStore.shared.wallpaper : nil
        if let custom {
            ZStack {
                CoverImage(image: custom)
                if theme.dark {
                    Color.black.opacity(0.3)
                }
            }
        } else {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let base = min(w, h)
                ZStack {
                    LinearGradient(colors: [tokens.top, tokens.bottom], startPoint: .top, endPoint: .bottom)
                    blob(tokens.blobA, x: w * 0.2, y: h * 0.22, radius: base * 0.75)
                    blob(tokens.blobB, x: w * 0.85, y: h * 0.5, radius: base * 0.8)
                    blob(tokens.blobC, x: w * 0.3, y: h * 0.85, radius: base * 0.7)
                }
            }
        }
    }

    private func blob(_ color: Color, x: CGFloat, y: CGFloat, radius: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.85), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
            .frame(width: radius * 2, height: radius * 2)
            .position(x: x, y: y)
    }
}
