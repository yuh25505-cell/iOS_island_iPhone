import SwiftUI

struct WidgetContent: View {
    let kind: WidgetKind

    var body: some View {
        GlassSurface(cornerRadius: 28, elevation: 8) {
            Color.clear
        }
    }
}
