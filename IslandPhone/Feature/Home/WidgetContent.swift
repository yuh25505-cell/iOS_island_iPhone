import SwiftUI

struct WidgetContent: View {
    let kind: WidgetKind

    var body: some View {
        switch kind {
        case .clock:
            ClockWidget()
        case .battery:
            BatteryWidget()
        case .weather:
            WidgetCard(value: "--°")
        case .countdown:
            WidgetCard(value: "--")
        case .photocard:
            PhotoCardWidget()
        case .vinyl:
            VinylWidget()
        }
    }
}
