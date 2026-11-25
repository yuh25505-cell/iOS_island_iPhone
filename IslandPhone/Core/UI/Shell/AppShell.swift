import SwiftUI

struct AppShell<Content: View, Overlay: View>: View {
    private let title: String
    private let onBack: () -> Void
    private let content: Content
    private let overlay: Overlay

    @Environment(\.island) private var theme

    init(
        title: String,
        onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.title = title
        self.onBack = onBack
        self.content = content()
        self.overlay = overlay()
    }

    var body: some View {
        OwnBackdrop {
            IslandWallpaper().ignoresSafeArea()
        } content: {
            ZStack(alignment: .top) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 56)
                header
                overlay
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                GlassSurface(shape: Circle(), elevation: 4) {
                    Canvas { context, size in
                        let w = size.width
                        let h = size.height
                        var chevron = Path()
                        chevron.move(to: CGPoint(x: w * 0.58, y: h * 0.3))
                        chevron.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
                        chevron.addLine(to: CGPoint(x: w * 0.58, y: h * 0.7))
                        context.stroke(
                            chevron,
                            with: .color(theme.icon.label),
                            style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
                        )
                    }
                    .frame(width: 40, height: 40)
                }
                .frame(width: 40, height: 40)
                .glassPressable(action: onBack)
                Spacer()
            }
            IslandText(
                title,
                size: 18,
                weight: .semibold,
                color: theme.icon.label,
                lineLimit: 1,
                alignment: .center
            )
            .padding(.horizontal, 56)
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
    }
}

extension AppShell where Overlay == EmptyView {
    init(title: String, onBack: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.init(title: title, onBack: onBack, content: content, overlay: { EmptyView() })
    }
}
