import SwiftUI

struct GlassSubPage: View {
    let onClose: () -> Void

    private let glass = GlassSettings.shared

    private var isDefault: Bool {
        abs(glass.tint - 0.8) < 0.001 && abs(glass.shadow - 0.2) < 0.001 && glass.enabled
    }

    var body: some View {
        SubPageScaffold(title: "液态玻璃", onClose: onClose) {
            GlassPreview()
            SettingCard(
                title: "玻璃",
                action: { MinusButton(enabled: !isDefault) { glass.reset() } },
                content: {
                    VStack(spacing: 0) {
                        SwitchRow(title: "玻璃效果", checked: glass.enabled) { value in
                            glass.setEnabled(value)
                        }
                        GlassSliderRow(
                            title: "着色",
                            value: Binding(get: { glass.tint }, set: { glass.setTint($0) })
                        )
                        GlassSliderRow(
                            title: "阴影",
                            value: Binding(get: { glass.shadow }, set: { glass.setShadow($0) })
                        )
                    }
                }
            )
        }
    }
}

private struct GlassSliderRow: View {
    let title: String
    @Binding var value: Double

    @Environment(\.island) private var theme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                IslandText(title, size: 17, weight: .semibold, color: theme.icon.label, lineLimit: 1)
                Spacer(minLength: 0)
                IslandText("\(Int((value * 100).rounded()))%", size: 15, color: theme.icon.label.opacity(0.6), lineLimit: 1)
            }
            Slider(value: $value, in: 0...2)
                .tint(theme.icon.label.opacity(0.55))
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }
}

private struct GlassPreview: View {
    @State private var merged = false

    var body: some View {
        OwnBackdrop {
            background
        } content: {
            GlassGroup(spacing: 60) {
                HStack(spacing: merged ? -24 : 32) {
                    GlassSurface(cornerRadius: 40, elevation: 10) {
                        Color.clear.frame(width: 104, height: 80)
                    }
                    GlassSurface(cornerRadius: 40, elevation: 10) {
                        Color.clear.frame(width: 104, height: 80)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            PageAnimation.perform(.spring(response: 0.45, dampingFraction: 0.72)) {
                merged.toggle()
            }
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(argb: 0xFFFF7A59), Color(argb: 0xFF7B61FF), Color(argb: 0xFF2EC4B6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                let step = size.width / 14
                var x: CGFloat = 0
                while x < size.width {
                    context.fill(
                        Path(CGRect(x: x, y: 0, width: step * 0.35, height: size.height)),
                        with: .color(Color.white.opacity(0.5))
                    )
                    x += step
                }
                let big = size.height * 0.22
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.22 - big, y: size.height * 0.35 - big, width: big * 2, height: big * 2)),
                    with: .color(Color(argb: 0xFFFFE066))
                )
                let small = size.height * 0.16
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.8 - small, y: size.height * 0.7 - small, width: small * 2, height: small * 2)),
                    with: .color(Color(argb: 0xFF1B1B3A))
                )
            }
        }
    }
}
