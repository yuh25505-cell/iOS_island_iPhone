import SwiftUI

struct OwnBackdrop<Source: View, Content: View>: View {
    private let source: Source
    private let content: Content

    init(@ViewBuilder source: () -> Source, @ViewBuilder content: () -> Content) {
        self.source = source()
        self.content = content()
    }

    var body: some View {
        ZStack {
            source
            content
        }
    }
}

struct PopupBackdrop<Content: View>: View {
    @Environment(\.island) private var theme
    private let cornerRadius: CGFloat
    private let content: Content

    init(cornerRadius: CGFloat = 28, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(theme.wallpaper.top)
        )
    }
}
