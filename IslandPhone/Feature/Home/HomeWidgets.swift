import Foundation

enum WidgetKind: String, CaseIterable, Codable {
    case clock = "CLOCK"
    case battery = "BATTERY"
    case weather = "WEATHER"
    case countdown = "COUNTDOWN"
    case photocard = "PHOTOCARD"
    case vinyl = "VINYL"

    var cols: Int {
        switch self {
        case .clock: return 4
        default: return 2
        }
    }

    var rows: Int { 2 }

    var title: String {
        switch self {
        case .clock: return "时钟"
        case .battery: return "电池"
        case .weather: return "天气"
        case .countdown: return "倒数日"
        case .photocard: return "拾光"
        case .vinyl: return "唱片"
        }
    }
}

struct WidgetPlacement: Equatable {
    var kind: WidgetKind
    var page: Int
    var row: Int
    var col: Int
}
