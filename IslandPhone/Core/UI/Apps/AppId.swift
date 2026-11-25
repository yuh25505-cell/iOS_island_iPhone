import Foundation

enum AppId: String, CaseIterable, Codable, Hashable {
    case auth = "AUTH"
    case chat = "CHAT"
    case appearance = "APPEARANCE"
    case growth = "GROWTH"
    case album = "ALBUM"
    case calendar = "CALENDAR"
    case memo = "MEMO"
    case weather = "WEATHER"
    case clock = "CLOCK"
    case settings = "SETTINGS"
    case phone = "PHONE"
    case countdown = "COUNTDOWN"
    case worldbook = "WORLDBOOK"
    case music = "MUSIC"
    case meet = "MEET"
    case link = "LINK"
    case forum = "FORUM"
    case novel = "NOVEL"
    case couple = "COUPLE"
    case preset = "PRESET"
    case sideline = "SIDELINE"
    case shop = "SHOP"
    case dream = "DREAM"

    var label: String {
        switch self {
        case .auth: return "登录系统"
        case .chat: return "聊天"
        case .appearance: return "外观"
        case .growth: return "屿年"
        case .album: return "相册"
        case .calendar: return "日历"
        case .memo: return "备忘录"
        case .weather: return "天气"
        case .clock: return "时钟"
        case .settings: return "设置"
        case .phone: return "电话"
        case .countdown: return "倒数日"
        case .worldbook: return "世界书"
        case .music: return "音乐"
        case .meet: return "相遇"
        case .link: return "关联账号"
        case .forum: return "论坛"
        case .novel: return "文学城"
        case .couple: return "情侣空间"
        case .preset: return "预设"
        case .sideline: return "番外笺"
        case .shop: return "美团"
        case .dream: return "栖迟"
        }
    }

    var adminOnly: Bool { self == .auth }
}
