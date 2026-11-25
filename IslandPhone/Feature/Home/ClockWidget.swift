import SwiftUI

struct ClockWidget: View {
    @Environment(\.island) private var theme

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()

    var body: some View {
        let color = theme.widget.clockText
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let unit = geo.size.width
                VStack(spacing: 0) {
                    IslandText(
                        Self.dateFormatter.string(from: context.date),
                        size: unit * 0.072,
                        weight: .semibold,
                        color: color,
                        lineLimit: 1,
                        alignment: .center
                    )
                    IslandText(
                        timeText(context.date),
                        size: unit * 0.32,
                        weight: .bold,
                        color: color,
                        lineLimit: 1,
                        alignment: .center
                    )
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private func timeText(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
    }
}
