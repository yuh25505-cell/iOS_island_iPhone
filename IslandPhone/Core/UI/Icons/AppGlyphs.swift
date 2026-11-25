import SwiftUI

struct AppGlyph: View {
    let app: AppId
    let color: Color

    var body: some View {
        Canvas { context, size in
            GlyphPainter.draw(app, color: color, in: &context, side: min(size.width, size.height))
        }
    }
}

enum GlyphPainter {
    static func draw(_ app: AppId, color c: Color, in ctx: inout GraphicsContext, side: CGFloat) {
        let k = Double(side) / 100.0
        ctx.scaleBy(x: k, y: k)
        switch app {
        case .auth:
            var shackle = Path()
            shackle.move(to: pt(38, 48))
            shackle.addLine(to: pt(38, 38))
            addArc(&shackle, 50, 38, 12, 180, 180)
            shackle.addLine(to: pt(62, 48))
            strokePath(&ctx, shackle, c, 8)
            let hole = pUnion(circlePath(50, 59, 5.5), roundPath(47, 60, 53, 72, 3))
            fillPath(&ctx, pDiff(roundPath(28, 44, 72, 82, 10), hole), c)

        case .chat:
            var tail = Path()
            tail.move(to: pt(30, 58))
            tail.addCurve(to: pt(22, 80), control1: pt(31, 70), control2: pt(29, 76))
            tail.addCurve(to: pt(54, 64), control1: pt(36, 80), control2: pt(46, 74))
            tail.closeSubpath()
            let dots = pUnion(circlePath(36, 45, 4.5), circlePath(50, 45, 4.5), circlePath(64, 45, 4.5))
            let bubble = pUnion(roundPath(20, 24, 80, 66, 18), tail)
            fillPath(&ctx, pDiff(bubble, dots), c)

        case .appearance:
            fillPath(&ctx, circlePath(40, 42, 24).symmetricDifference(circlePath(60, 58, 24)), c)

        case .growth:
            fillPath(&ctx, roundPath(46, 54, 54, 84, 4), c)
            var leafA = Path()
            leafA.move(to: pt(50, 58))
            leafA.addCurve(to: pt(80, 30), control1: pt(50, 44), control2: pt(60, 33))
            leafA.addCurve(to: pt(50, 58), control1: pt(82, 48), control2: pt(70, 61))
            leafA.closeSubpath()
            fillPath(&ctx, leafA, c)
            var leafB = Path()
            leafB.move(to: pt(50, 68))
            leafB.addCurve(to: pt(22, 44), control1: pt(50, 56), control2: pt(40, 47))
            leafB.addCurve(to: pt(50, 68), control1: pt(20, 61), control2: pt(32, 71))
            leafB.closeSubpath()
            fillPath(&ctx, leafB, c)

        case .album:
            var petals = circlePath(69, 50, 12)
            for i in 1..<8 {
                let a = Double(i) * Double.pi / 4.0
                petals = petals.union(circlePath(50 + 19 * cos(a), 50 + 19 * sin(a), 12))
            }
            fillPath(&ctx, pDiff(petals, circlePath(50, 50, 6.5)), c)

        case .calendar:
            fillPath(&ctx, pDiff(roundPath(20, 26, 80, 82, 13), roundPath(29, 48, 71, 74, 5)), c)
            fillPath(&ctx, roundPath(31, 17, 39, 33, 4), c)
            fillPath(&ctx, roundPath(61, 17, 69, 33, 4), c)
            disc(&ctx, c, 39, 61, 4)
            disc(&ctx, c, 50, 61, 4)
            disc(&ctx, c, 61, 61, 4)

        case .memo:
            let lines = pUnion(
                roundPath(37, 35, 63, 41, 3),
                roundPath(37, 48, 63, 54, 3),
                roundPath(37, 61, 53, 67, 3)
            )
            fillPath(&ctx, pDiff(roundPath(26, 18, 74, 82, 11), lines), c)

        case .weather:
            disc(&ctx, c.opacity(0.7), 32, 34, 9)
            let cloud = pUnion(
                roundPath(24, 58, 84, 78, 10),
                circlePath(40, 61, 14),
                circlePath(58, 52, 18),
                circlePath(72, 64, 12)
            )
            ctx.fill(cloud, with: .color(c))

        case .clock:
            let hands = pUnion(roundPath(46.5, 28, 53.5, 53, 3.5), roundPath(46.5, 46.5, 68, 53.5, 3.5))
            fillPath(&ctx, pDiff(circlePath(50, 50, 32), hands), c)

        case .settings:
            var gear = Path()
            for i in 0..<8 {
                let a = Double(i) * 45.0 - 90.0
                let pts = [
                    polar(27, a - 12),
                    polar(35, a - 8),
                    polar(35, a + 8),
                    polar(27, a + 12),
                    polar(27, a + 22.5)
                ]
                for (index, p) in pts.enumerated() {
                    if i == 0 && index == 0 { gear.move(to: p) } else { gear.addLine(to: p) }
                }
            }
            gear.closeSubpath()
            fillPath(&ctx, pDiff(gear, circlePath(50, 50, 11)), c, soften: 2.5)

        case .phone:
            var handset = Path()
            handset.move(to: pt(6.62, 10.79))
            handset.rCubic(1.44, 2.83, 3.76, 5.14, 6.59, 6.59)
            handset.rLine(2.2, -2.2)
            handset.rCubic(0.27, -0.27, 0.67, -0.36, 1.02, -0.24)
            handset.rCubic(1.12, 0.37, 2.33, 0.57, 3.57, 0.57)
            handset.rCubic(0.55, 0, 1, 0.45, 1, 1)
            handset.addLine(to: pt(21, 20))
            handset.rCubic(0, 0.55, -0.45, 1, -1, 1)
            handset.rCubic(-9.39, 0, -17, -7.61, -17, -17)
            handset.rCubic(0, -0.55, 0.45, -1, 1, -1)
            handset.rLine(3.5, 0)
            handset.rCubic(0.55, 0, 1, 0.45, 1, 1)
            handset.rCubic(0, 1.25, 0.2, 2.45, 0.57, 3.57)
            handset.rCubic(0.11, 0.35, 0.03, 0.74, -0.25, 1.02)
            handset.rLine(-2.2, 2.2)
            handset.closeSubpath()
            var inner = ctx
            inner.translateBy(x: 6.8, y: 6.8)
            inner.scaleBy(x: 3.6, y: 3.6)
            fillPath(&inner, handset, c, soften: 0.5)

        case .countdown:
            var glass = Path()
            glass.move(to: pt(34, 30))
            glass.addLine(to: pt(66, 30))
            glass.addCurve(to: pt(54, 50), control1: pt(66, 42), control2: pt(56, 46))
            glass.addCurve(to: pt(66, 70), control1: pt(56, 54), control2: pt(66, 58))
            glass.addLine(to: pt(34, 70))
            glass.addCurve(to: pt(46, 50), control1: pt(34, 58), control2: pt(44, 54))
            glass.addCurve(to: pt(34, 30), control1: pt(44, 46), control2: pt(34, 42))
            glass.closeSubpath()
            fillPath(&ctx, glass, c)
            line(&ctx, c, 30, 22, 70, 22, 8)
            line(&ctx, c, 30, 78, 70, 78, 8)

        case .worldbook:
            var left = Path()
            left.move(to: pt(48, 32))
            left.addCurve(to: pt(20, 30), control1: pt(40, 26), control2: pt(28, 26))
            left.addLine(to: pt(20, 72))
            left.addCurve(to: pt(48, 74), control1: pt(28, 68), control2: pt(40, 68))
            left.closeSubpath()
            fillPath(&ctx, left, c)
            var right = Path()
            right.move(to: pt(52, 32))
            right.addCurve(to: pt(80, 30), control1: pt(60, 26), control2: pt(72, 26))
            right.addLine(to: pt(80, 72))
            right.addCurve(to: pt(52, 74), control1: pt(72, 68), control2: pt(60, 68))
            right.closeSubpath()
            fillPath(&ctx, right, c)

        case .music:
            var flag = Path()
            flag.move(to: pt(49, 68))
            flag.addLine(to: pt(49, 22))
            flag.addCurve(to: pt(71, 52), control1: pt(58, 26), control2: pt(70, 32))
            flag.addCurve(to: pt(57, 42), control1: pt(66, 45), control2: pt(61, 43))
            flag.addLine(to: pt(57, 68))
            flag.closeSubpath()
            let note = pUnion(flag, circlePath(43, 68, 13))
            var moved = ctx
            moved.translateBy(x: 2, y: 0)
            fillPath(&moved, note, c, soften: 1.5)

        case .meet:
            var pin = Path()
            pin.move(to: pt(50, 82))
            pin.addCurve(to: pt(27, 43), control1: pt(41, 73), control2: pt(27, 59))
            addArc(&pin, 50, 43, 23, 180, 180)
            pin.addCurve(to: pt(50, 82), control1: pt(73, 59), control2: pt(59, 73))
            pin.closeSubpath()
            fillPath(&ctx, pDiff(pin, circlePath(50, 43, 9)), c)

        case .link:
            fillPath(&ctx, circlePath(36, 50, 24).symmetricDifference(circlePath(64, 50, 24)), c)

        case .forum:
            line(&ctx, c, 44, 22, 38, 78, 8)
            line(&ctx, c, 64, 22, 58, 78, 8)
            line(&ctx, c, 22, 39, 78, 39, 8)
            line(&ctx, c, 22, 61, 78, 61, 8)

        case .novel:
            let cuts = pUnion(
                roundPath(35, 26, 40, 74, 2.5),
                roundPath(47, 38, 64, 43, 2.5),
                roundPath(47, 50, 64, 55, 2.5)
            )
            fillPath(&ctx, pDiff(roundPath(26, 18, 74, 82, 10), cuts), c)

        case .couple:
            var heart = Path()
            heart.move(to: pt(50, 82))
            heart.addCurve(to: pt(16, 36), control1: pt(24, 64), control2: pt(16, 48))
            heart.addCurve(to: pt(33, 18), control1: pt(16, 25), control2: pt(24, 18))
            heart.addCurve(to: pt(50, 29), control1: pt(41, 18), control2: pt(47, 22))
            heart.addCurve(to: pt(67, 18), control1: pt(53, 22), control2: pt(59, 18))
            heart.addCurve(to: pt(84, 36), control1: pt(76, 18), control2: pt(84, 25))
            heart.addCurve(to: pt(50, 82), control1: pt(84, 48), control2: pt(76, 64))
            heart.closeSubpath()
            fillPath(&ctx, heart, c, soften: 4)

        case .preset:
            line(&ctx, c, 24, 32, 76, 32, 8)
            line(&ctx, c, 24, 50, 76, 50, 8)
            line(&ctx, c, 24, 68, 76, 68, 8)
            disc(&ctx, c, 40, 32, 10)
            disc(&ctx, c, 60, 50, 10)
            disc(&ctx, c, 46, 68, 10)

        case .sideline:
            var flap = Path()
            flap.move(to: pt(24, 33))
            flap.addLine(to: pt(50, 53))
            flap.addLine(to: pt(76, 33))
            flap.addLine(to: pt(76, 41))
            flap.addLine(to: pt(50, 61))
            flap.addLine(to: pt(24, 41))
            flap.closeSubpath()
            fillPath(&ctx, pDiff(roundPath(18, 26, 82, 74, 10), flap), c)

        case .shop:
            var handle = Path()
            handle.move(to: pt(38, 42))
            handle.addLine(to: pt(38, 32))
            addArc(&handle, 50, 32, 12, 180, 180)
            handle.addLine(to: pt(62, 42))
            strokePath(&ctx, handle, c, 7)
            let eyes = pUnion(circlePath(40, 52, 4), circlePath(60, 52, 4))
            fillPath(&ctx, pDiff(roundPath(24, 38, 76, 82, 11), eyes), c)

        case .dream:
            let moon = circlePath(46, 52, 26).subtracting(circlePath(60, 42, 21))
            fillPath(&ctx, moon, c)
            disc(&ctx, c, 73, 27, 4)
        }
    }

    private static func pt(_ x: Double, _ y: Double) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    private static func polar(_ r: Double, _ deg: Double) -> CGPoint {
        let rad = deg * Double.pi / 180.0
        return CGPoint(x: 50 + r * cos(rad), y: 50 + r * sin(rad))
    }

    private static func addArc(_ p: inout Path, _ cx: Double, _ cy: Double, _ r: Double, _ from: Double, _ sweep: Double) {
        let steps = max(8, Int(abs(sweep) / 4.0))
        for i in 0...steps {
            let a = (from + sweep * Double(i) / Double(steps)) * Double.pi / 180.0
            let point = CGPoint(x: cx + r * cos(a), y: cy + r * sin(a))
            if p.isEmpty {
                p.move(to: point)
            } else {
                p.addLine(to: point)
            }
        }
    }

    private static func circlePath(_ x: Double, _ y: Double, _ r: Double) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    private static func roundPath(_ l: Double, _ t: Double, _ r: Double, _ b: Double, _ rad: Double) -> Path {
        Path(roundedRect: CGRect(x: l, y: t, width: r - l, height: b - t), cornerRadius: rad)
    }

    private static func pUnion(_ parts: Path...) -> Path {
        var out = parts[0]
        for index in 1..<parts.count {
            out = out.union(parts[index])
        }
        return out
    }

    private static func pDiff(_ a: Path, _ b: Path) -> Path {
        a.subtracting(b)
    }

    private static func pen(_ w: Double) -> StrokeStyle {
        StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round)
    }

    private static func fillPath(_ ctx: inout GraphicsContext, _ path: Path, _ c: Color, soften: Double = 2) {
        ctx.fill(path, with: .color(c))
        ctx.stroke(path, with: .color(c), style: pen(soften))
    }

    private static func strokePath(_ ctx: inout GraphicsContext, _ path: Path, _ c: Color, _ w: Double) {
        ctx.stroke(path, with: .color(c), style: pen(w))
    }

    private static func line(_ ctx: inout GraphicsContext, _ c: Color, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ w: Double) {
        var p = Path()
        p.move(to: CGPoint(x: x1, y: y1))
        p.addLine(to: CGPoint(x: x2, y: y2))
        ctx.stroke(p, with: .color(c), style: StrokeStyle(lineWidth: w, lineCap: .round))
    }

    private static func disc(_ ctx: inout GraphicsContext, _ c: Color, _ x: Double, _ y: Double, _ r: Double) {
        ctx.fill(circlePath(x, y, r), with: .color(c))
    }
}

private extension Path {
    mutating func rCubic(_ dx1: Double, _ dy1: Double, _ dx2: Double, _ dy2: Double, _ dx: Double, _ dy: Double) {
        let p = currentPoint ?? .zero
        addCurve(
            to: CGPoint(x: p.x + dx, y: p.y + dy),
            control1: CGPoint(x: p.x + dx1, y: p.y + dy1),
            control2: CGPoint(x: p.x + dx2, y: p.y + dy2)
        )
    }

    mutating func rLine(_ dx: Double, _ dy: Double) {
        let p = currentPoint ?? .zero
        addLine(to: CGPoint(x: p.x + dx, y: p.y + dy))
    }
}
