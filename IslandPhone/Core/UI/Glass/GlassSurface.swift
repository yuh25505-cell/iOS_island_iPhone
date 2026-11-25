import SwiftUI

struct GlassSurface<S: Shape, Content: View>: View {
    private let shape: S
    private let elevation: CGFloat
    private let interactive: Bool
    private let content: Content

    init(shape: S, elevation: CGFloat = 14, interactive: Bool = false, @ViewBuilder content: () -> Content) {
        self.shape = shape
        self.elevation = elevation
        self.interactive = interactive
        self.content = content()
    }

    var body: some View {
        content.modifier(GlassFill(shape: shape, elevation: elevation, interactive: interactive))
    }
}

extension GlassSurface where S == RoundedRectangle {
    init(cornerRadius: CGFloat = 28, elevation: CGFloat = 14, interactive: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(
            shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            elevation: elevation,
            interactive: interactive,
            content: content
        )
    }
}

struct GlassFill<S: Shape>: ViewModifier {
    let shape: S
    let elevation: CGFloat
    let interactive: Bool

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.island) private var theme

    func body(content: Content) -> some View {
        let settings = GlassSettings.shared
        if reduceTransparency || !settings.enabled {
            content
                .background(shape.fill(theme.glass.tintFallback))
                .clipShape(shape)
        } else {
            nativeGlass(content, tintAmount: settings.tint, shadowAmount: settings.shadow)
        }
    }

    @ViewBuilder
    private func nativeGlass(_ content: Content, tintAmount: Double, shadowAmount: Double) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            let base = Glass.regular.tint(theme.glass.tint.opacity(tintAmount))
            if interactive {
                content.glassEffect(base.interactive(), in: shape)
            } else {
                content.glassEffect(base, in: shape)
            }
        } else {
            materialGlass(content, shadowAmount: shadowAmount)
        }
        #else
        materialGlass(content, shadowAmount: shadowAmount)
        #endif
    }

    private func materialGlass(_ content: Content, shadowAmount: Double) -> some View {
        content
            .background(.ultraThinMaterial, in: shape)
            .overlay(shape.fill(theme.glass.tint))
            .overlay(
                shape.stroke(
                    LinearGradient(
                        colors: [theme.glass.rimLight, theme.glass.rimDark, theme.glass.rimDark, theme.glass.rimLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
            )
            .clipShape(shape)
            .shadow(color: theme.glass.shadow, radius: elevation * shadowAmount, x: 0, y: elevation * shadowAmount * 0.4)
    }
}

struct GlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}
