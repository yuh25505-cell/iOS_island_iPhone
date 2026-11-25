import SwiftUI
import UIKit

struct VinylWidget: View {
    @Environment(\.island) private var theme

    var body: some View {
        let cover = VinylStore.shared.cover
        let label = theme.icon.label
        GlassSurface(cornerRadius: 28, elevation: 10) {
            GeometryReader { geo in
                let u = min(geo.size.width, geo.size.height)
                let record = u * 0.76
                ZStack {
                    Canvas { context, size in
                        let r = size.width / 2
                        let center = CGPoint(x: r, y: r)
                        context.fill(circle(center, r), with: .color(label.opacity(0.08)))
                        for i in 0...6 {
                            context.stroke(
                                circle(center, r * (0.76 + CGFloat(i) * 0.033)),
                                with: .color(label.opacity(0.18)),
                                lineWidth: 0.7
                            )
                        }
                        context.stroke(
                            circle(center, r - 1),
                            with: .color(label.opacity(0.5)),
                            lineWidth: 1.6
                        )
                    }
                    .frame(width: record, height: record)
                    Circle()
                        .fill(label.opacity(0.22))
                        .overlay {
                            if let cover {
                                Image(uiImage: cover)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .clipShape(Circle())
                        .frame(width: record * 0.72, height: record * 0.72)
                    Canvas { context, size in
                        drawArm(context: context, size: size, color: label.opacity(0.9))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    private func drawArm(context: GraphicsContext, size: CGSize, color: Color) {
        let w = min(size.width, size.height)
        let ox = (size.width - w) / 2
        let oy = (size.height - w) / 2
        let armWidth = w * 0.022
        let ringRadius = w * 0.05
        let pivot = CGPoint(x: ox + w * 0.84, y: oy + w * 0.17)
        context.stroke(circle(pivot, ringRadius), with: .color(color), lineWidth: armWidth)
        context.fill(circle(pivot, w * 0.027), with: .color(color))
        var arm = Path()
        arm.move(to: CGPoint(x: ox + w * 0.84, y: oy + w * 0.17 + ringRadius))
        arm.addLine(to: CGPoint(x: ox + w * 0.84, y: oy + w * 0.575))
        arm.addQuadCurve(
            to: CGPoint(x: ox + w * 0.815, y: oy + w * 0.654),
            control: CGPoint(x: ox + w * 0.84, y: oy + w * 0.62)
        )
        arm.addLine(to: CGPoint(x: ox + w * 0.73, y: oy + w * 0.77))
        context.stroke(arm, with: .color(color), style: StrokeStyle(lineWidth: armWidth, lineCap: .butt, lineJoin: .round))
        var head = Path()
        head.move(to: CGPoint(x: ox + w * 0.73, y: oy + w * 0.77))
        head.addLine(to: CGPoint(x: ox + w * 0.705, y: oy + w * 0.805))
        context.stroke(head, with: .color(color), style: StrokeStyle(lineWidth: w * 0.045, lineCap: .round))
    }
}
