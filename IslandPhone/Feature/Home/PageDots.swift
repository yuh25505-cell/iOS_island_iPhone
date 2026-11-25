import SwiftUI

struct PageDots: View {
    let count: Int
    let current: Int

    @Environment(\.island) private var theme

    var body: some View {
        HStack(spacing: 9) {
            ForEach(0..<max(count, 0), id: \.self) { index in
                Circle()
                    .fill(index == current ? theme.dots.active : theme.dots.inactive)
                    .frame(width: 8, height: 8)
            }
        }
        .pageAnimated(.easeInOut(duration: 0.2), value: current)
    }
}
