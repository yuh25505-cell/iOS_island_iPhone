import SwiftUI
import UIKit

struct PhotoCardWidget: View {
    @Environment(\.island) private var theme

    var body: some View {
        let store = PhotoCardStore.shared
        let name = store.name
        let topic = store.topic
        let bodyText = store.body
        let music = store.music
        let avatar = store.avatar
        let photo = store.photo
        let label = theme.icon.label
        let soft = label.opacity(0.62)
        let faint = label.opacity(0.3)
        GlassSurface(cornerRadius: 28, elevation: 10) {
            GeometryReader { geo in
                let u = geo.size.width
                let avatarSize = u * 0.17
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        CardAvatar(image: avatar, size: avatarSize, fill: faint)
                        Spacer().frame(width: u * 0.04)
                        IslandText(name, size: u * 0.065, weight: .semibold, color: label, lineLimit: 1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        IslandText(topic, size: u * 0.048, color: soft, lineLimit: 1)
                    }
                    HStack(alignment: .top, spacing: 0) {
                        Rectangle()
                            .fill(faint)
                            .frame(width: 1)
                            .frame(width: avatarSize)
                            .frame(maxHeight: .infinity)
                        Spacer().frame(width: u * 0.03)
                        VStack(alignment: .leading, spacing: 0) {
                            IslandText(bodyText, size: u * 0.05, color: label, lineLimit: 2)
                                .lineSpacing(u * 0.008)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer().frame(height: u * 0.025)
                            IslandText("♬ \(music)", size: u * 0.046, color: soft, lineLimit: 1)
                            Spacer().frame(height: u * 0.025)
                            RoundedRectangle(cornerRadius: u * 0.04, style: .continuous)
                                .fill(label.opacity(0.12))
                                .overlay {
                                    if let photo {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: u * 0.04, style: .continuous))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Spacer().frame(height: u * 0.025)
                            CardBottomBar(u: u, color: soft)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .padding(.top, u * 0.025)
                    .frame(maxHeight: .infinity)
                }
                .padding(u * 0.07)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
        }
    }
}

struct CardAvatar: View {
    let image: UIImage?
    let size: CGFloat
    let fill: Color

    var body: some View {
        Circle()
            .fill(fill.opacity(0.4))
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(Circle())
            .frame(width: size, height: size)
    }
}

private struct CardBottomBar: View {
    let u: CGFloat
    let color: Color

    var body: some View {
        let iconH = u * 0.062
        HStack(spacing: 0) {
            CardGlyph(kind: .bookmark, color: color)
                .frame(width: u * 0.044, height: iconH)
            Spacer().frame(width: u * 0.04)
            CardGlyph(kind: .plane, color: color)
                .frame(width: iconH, height: iconH)
            Spacer().frame(width: u * 0.04)
            CardGlyph(kind: .star, color: color)
                .frame(width: iconH, height: iconH)
            Spacer(minLength: 0)
        }
        .frame(height: u * 0.075)
    }
}

private struct CardGlyph: View {
    enum Kind {
        case bookmark
        case plane
        case star
    }

    let kind: Kind
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let style = StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round)
            switch kind {
            case .bookmark:
                var path = Path()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: w / 2, y: h * 0.72))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.closeSubpath()
                context.stroke(path, with: .color(color), style: style)
            case .plane:
                var path = Path()
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: 0, y: h * 0.46))
                path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.6))
                path.addLine(to: CGPoint(x: w * 0.56, y: h))
                path.closeSubpath()
                context.stroke(path, with: .color(color), style: style)
                var fold = Path()
                fold.move(to: CGPoint(x: w, y: 0))
                fold.addLine(to: CGPoint(x: w * 0.42, y: h * 0.6))
                context.stroke(fold, with: .color(color), style: StrokeStyle(lineWidth: 1.1))
            case .star:
                let cx = w / 2
                let cy = h / 2
                let outer = w / 2
                let inner = outer * 0.45
                var path = Path()
                for i in 0..<10 {
                    let r = i % 2 == 0 ? outer : inner
                    let angle = -Double.pi / 2 + Double(i) * Double.pi / 5
                    let point = CGPoint(x: cx + r * CGFloat(cos(angle)), y: cy + r * CGFloat(sin(angle)))
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
                context.stroke(path, with: .color(color), style: style)
            }
        }
    }
}
