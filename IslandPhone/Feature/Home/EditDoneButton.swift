import SwiftUI

struct EditDoneButton: View {
    let onClick: () -> Void

    @Environment(\.island) private var theme

    var body: some View {
        GlassSurface(shape: Capsule(), elevation: 4) {
            IslandText("完成", size: 15, color: theme.icon.label)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
        }
        .glassPressable(action: onClick)
    }
}
