import SwiftUI
import UIKit

struct BatteryWidget: View {
    @Environment(\.island) private var theme
    @State private var level = 100
    @State private var charging = false

    var body: some View {
        let tokens = theme.widget
        let label = theme.icon.label
        let ringColor = (level <= 20 && !charging) ? tokens.ringRed : tokens.ringGreen
        let current = level
        let isCharging = charging
        GlassSurface(cornerRadius: 28, elevation: 10) {
            GeometryReader { geo in
                let unit = geo.size.width
                let ringSize = unit * 0.4
                VStack(alignment: .leading, spacing: 0) {
                    BatteryRing(
                        size: ringSize,
                        level: current,
                        color: ringColor,
                        track: tokens.ringTrack,
                        glyph: label
                    )
                    Spacer(minLength: 0)
                    HStack(spacing: 3) {
                        if isCharging {
                            BoltGlyph(color: tokens.ringGreen)
                                .frame(width: unit * 0.07, height: unit * 0.1)
                        }
                        IslandText("\(current)%", size: unit * 0.25, color: label, lineLimit: 1)
                    }
                }
                .padding(unit * 0.09)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
        }
        .onAppear { startMonitoring() }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)) { _ in
            refresh()
        }
    }

    private func startMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        refresh()
    }

    private func refresh() {
        let value = UIDevice.current.batteryLevel
        if value >= 0 {
            level = Int((value * 100).rounded())
        }
        let state = UIDevice.current.batteryState
        charging = state == .charging || state == .full
    }
}

private struct BatteryRing: View {
    let size: CGFloat
    let level: Int
    let color: Color
    let track: Color
    let glyph: Color

    var body: some View {
        let stroke = size * 0.11
        ZStack {
            Circle()
                .inset(by: stroke / 2)
                .stroke(track, lineWidth: stroke)
            Circle()
                .inset(by: stroke / 2)
                .trim(from: 0, to: CGFloat(level) / 100)
                .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
            BatteryGlyph(color: glyph)
                .frame(width: size * 0.27, height: size * 0.46)
        }
        .frame(width: size, height: size)
    }
}

private struct BatteryGlyph: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let sw = w * 0.1
            let outline = Path(
                roundedRect: CGRect(x: sw / 2, y: sw / 2, width: w - sw, height: h - sw),
                cornerRadius: w * 0.3
            )
            context.stroke(outline, with: .color(color), lineWidth: sw)
            let top = Path(
                roundedRect: CGRect(x: w * 0.34, y: sw * 1.7, width: w * 0.32, height: sw),
                cornerRadius: sw / 2
            )
            context.fill(top, with: .color(color))
            let bottom = Path(
                roundedRect: CGRect(x: w * 0.3, y: h - sw * 2.7, width: w * 0.4, height: sw),
                cornerRadius: sw / 2
            )
            context.fill(bottom, with: .color(color))
        }
    }
}

private struct BoltGlyph: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var bolt = Path()
            bolt.move(to: CGPoint(x: w * 0.6, y: 0))
            bolt.addLine(to: CGPoint(x: 0, y: h * 0.58))
            bolt.addLine(to: CGPoint(x: w * 0.46, y: h * 0.58))
            bolt.addLine(to: CGPoint(x: w * 0.36, y: h))
            bolt.addLine(to: CGPoint(x: w, y: h * 0.38))
            bolt.addLine(to: CGPoint(x: w * 0.54, y: h * 0.38))
            bolt.closeSubpath()
            context.fill(bolt, with: .color(color))
        }
    }
}
