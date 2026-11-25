import SwiftUI

struct WidgetCard: View {
    let value: String

    @Environment(\.island) private var theme

    var body: some View {
        GlassSurface(cornerRadius: 28, elevation: 10) {
            IslandText(value, size: 34, color: theme.icon.label, lineLimit: 1)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}
