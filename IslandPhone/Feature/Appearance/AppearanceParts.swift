import SwiftUI

struct PillLabel: View {
    let title: String
    var enabled: Bool = true

    @Environment(\.island) private var theme

    var body: some View {
        GlassSurface(shape: Capsule(), elevation: 4) {
            IslandText(title, size: 15, color: theme.icon.label, lineLimit: 1, alignment: .center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .opacity(enabled ? 1 : 0.45)
    }
}

struct PillButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        PillLabel(title: title, enabled: enabled)
            .glassPressable { if enabled { action() } }
    }
}

struct SettingCard<Action: View, Content: View>: View {
    let title: String
    let action: Action
    let content: Content

    @Environment(\.island) private var theme

    init(title: String, @ViewBuilder action: () -> Action, @ViewBuilder content: () -> Content) {
        self.title = title
        self.action = action()
        self.content = content()
    }

    var body: some View {
        GlassSurface(cornerRadius: 28, elevation: 8) {
            VStack(spacing: 0) {
                HStack {
                    IslandText(title, size: 14, weight: .medium, color: theme.icon.label.opacity(0.5), lineLimit: 1)
                    Spacer(minLength: 0)
                    action
                }
                .frame(minHeight: 34)
                content
            }
            .padding(.leading, 18)
            .padding(.trailing, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
        }
    }
}

extension SettingCard where Action == EmptyView {
    init(title: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, action: { EmptyView() }, content: content)
    }
}

struct MinusButton: View {
    var enabled: Bool = true
    let action: () -> Void

    @Environment(\.island) private var theme

    var body: some View {
        let color = theme.icon.label
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(color.opacity(0.08))
            .frame(width: 40, height: 32)
            .overlay {
                Capsule().fill(color).frame(width: 14, height: 2)
            }
            .opacity(enabled ? 1 : 0.4)
            .glassPressable { if enabled { action() } }
    }
}

private struct Chevron: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.1))
            path.addLine(to: CGPoint(x: size.width * 0.85, y: size.height * 0.5))
            path.addLine(to: CGPoint(x: size.width * 0.15, y: size.height * 0.9))
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 8, height: 14)
    }
}

struct EntryRowLabel<Trailing: View>: View {
    let title: String
    let trailing: Trailing

    @Environment(\.island) private var theme

    init(title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 10) {
            IslandText(title, size: 17, weight: .semibold, color: theme.icon.label, lineLimit: 1)
            Spacer(minLength: 0)
            trailing
            Chevron(color: theme.icon.label.opacity(0.35))
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

extension EntryRowLabel where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title, trailing: { EmptyView() })
    }
}

struct EntryRow<Trailing: View>: View {
    let title: String
    let trailing: Trailing
    let action: () -> Void

    init(title: String, action: @escaping () -> Void, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.action = action
        self.trailing = trailing()
    }

    var body: some View {
        EntryRowLabel(title: title) { trailing }
            .glassPressable(action: action)
    }
}

extension EntryRow where Trailing == EmptyView {
    init(title: String, action: @escaping () -> Void) {
        self.init(title: title, action: action, trailing: { EmptyView() })
    }
}

private struct GlassSwitch: View {
    let checked: Bool
    let offColor: Color

    var body: some View {
        Capsule()
            .fill(checked ? Color(argb: 0xFF34C759) : offColor.opacity(0.18))
            .frame(width: 52, height: 32)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .padding(2)
                    .offset(x: checked ? 20 : 0)
            }
            .pageAnimated(.spring(response: 0.3, dampingFraction: 0.7), value: checked)
    }
}

struct SwitchRow: View {
    let title: String
    let checked: Bool
    let onChange: (Bool) -> Void

    @Environment(\.island) private var theme

    var body: some View {
        HStack(spacing: 10) {
            IslandText(title, size: 17, weight: .semibold, color: theme.icon.label, lineLimit: 1)
            Spacer(minLength: 0)
            GlassSwitch(checked: checked, offColor: theme.icon.label)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .glassPressable { onChange(!checked) }
    }
}

private struct CheckMark: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.55))
            path.addLine(to: CGPoint(x: size.width * 0.38, y: size.height * 0.85))
            path.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.18))
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 18, height: 18)
    }
}

struct ChoiceRow: View {
    let title: String
    let selected: Bool
    var onDelete: (() -> Void)? = nil
    let onSelect: () -> Void

    @Environment(\.island) private var theme

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                IslandText(title, size: 17, weight: .semibold, color: theme.icon.label, lineLimit: 1)
                Spacer(minLength: 0)
                if selected {
                    CheckMark(color: theme.icon.label)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .glassPressable(action: onSelect)
            if let onDelete {
                MinusButton(action: onDelete)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WallpaperThumb: View {
    @Environment(\.island) private var theme

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        IslandWallpaper(useCustom: true)
            .frame(width: 38, height: 60)
            .clipShape(shape)
            .overlay(shape.stroke(theme.icon.label.opacity(0.15), lineWidth: 1))
    }
}
