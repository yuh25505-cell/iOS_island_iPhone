import SwiftUI
import UIKit
import CoreText
import Observation

struct FontEntry: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let postScript: String
}

@Observable
final class AppearanceStore {
    static let shared = AppearanceStore()

    private(set) var pageAnimation: Bool = true
    private(set) var themeMode: ThemeMode = .followSystem
    private(set) var fonts: [FontEntry] = []
    private(set) var emojis: [FontEntry] = []
    private(set) var activeFontId: String?
    private(set) var activeEmojiId: String?
    private(set) var wallpaper: UIImage?
    private(set) var wallpaperLuma: Double?
    private(set) var icons: [AppId: UIImage] = [:]

    @ObservationIgnored private let defaults = UserDefaults.standard
    @ObservationIgnored private let dir: URL
    @ObservationIgnored private let fontsDir: URL

    private enum Key {
        static let pageAnimation = "page_animation"
        static let themeMode = "theme_mode"
        static let fonts = "fonts_json"
        static let activeFont = "font_active"
        static let emojis = "emojis_json"
        static let activeEmoji = "emoji_active"
    }

    private static let wallpaperMaxSide: CGFloat = 2048
    private static let iconDecodeSide: CGFloat = 1024
    private static let iconMaxSide: CGFloat = 512

    private init() {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("appearance", isDirectory: true)
        let fontFolder = base.appendingPathComponent("fonts", isDirectory: true)
        dir = base
        fontsDir = fontFolder
        try? FileManager.default.createDirectory(at: fontFolder, withIntermediateDirectories: true)

        pageAnimation = (defaults.object(forKey: Key.pageAnimation) as? Bool) ?? true
        themeMode = ThemeMode(rawValue: defaults.string(forKey: Key.themeMode) ?? "") ?? .followSystem

        if let image = UIImage(contentsOfFile: wallpaperFile().path) {
            wallpaper = image
            wallpaperLuma = Self.luma(of: image)
        }
        for app in AppId.allCases {
            if let image = UIImage(contentsOfFile: iconFile(app).path) {
                icons[app] = image
            }
        }
        restoreFonts()
    }

    var hasCustomIcons: Bool { !icons.isEmpty }
    var hasCustomFont: Bool { activeFontId != nil }
    var hasEmojiFont: Bool { activeEmojiId != nil }
    var emojiFontName: String? {
        guard let id = activeEmojiId else { return nil }
        return emojis.first(where: { $0.id == id })?.name
    }

    func icon(for app: AppId) -> UIImage? { icons[app] }

    func setPageAnimation(_ enabled: Bool) {
        pageAnimation = enabled
        defaults.set(enabled, forKey: Key.pageAnimation)
    }

    func setThemeMode(_ mode: ThemeMode) {
        themeMode = mode
        defaults.set(mode.rawValue, forKey: Key.themeMode)
    }

    // MARK: 字体

    func importFont(url: URL) -> Bool {
        let id = Self.newId()
        guard let ps = copyFont(from: url, to: fontFile(id)) else { return false }
        fonts.append(FontEntry(id: id, name: Self.displayName(url, fallback: "字体 \(fonts.count + 1)"), postScript: ps))
        activeFontId = id
        saveFonts()
        return true
    }

    func selectFont(_ id: String?) {
        if let id, fonts.contains(where: { $0.id == id }) {
            activeFontId = id
        } else {
            activeFontId = nil
        }
        saveFonts()
    }

    func resetFont() { selectFont(nil) }

    func removeFont(_ id: String) {
        try? FileManager.default.removeItem(at: fontFile(id))
        fonts.removeAll { $0.id == id }
        if activeFontId == id { activeFontId = nil }
        saveFonts()
    }

    func importEmoji(url: URL) -> Bool {
        let id = Self.newId()
        guard let ps = copyFont(from: url, to: emojiFile(id)) else { return false }
        emojis.append(FontEntry(id: id, name: Self.displayName(url, fallback: "表情字体 \(emojis.count + 1)"), postScript: ps))
        activeEmojiId = id
        saveFonts()
        return true
    }

    func selectEmoji(_ id: String?) {
        if let id, emojis.contains(where: { $0.id == id }) {
            activeEmojiId = id
        } else {
            activeEmojiId = nil
        }
        saveFonts()
    }

    func resetEmoji() { selectEmoji(nil) }

    func removeEmoji(_ id: String) {
        try? FileManager.default.removeItem(at: emojiFile(id))
        emojis.removeAll { $0.id == id }
        if activeEmojiId == id { activeEmojiId = nil }
        saveFonts()
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let text = postScript(of: activeFontId, in: fonts)
        let emoji = postScript(of: activeEmojiId, in: emojis)
        if text == nil && emoji == nil {
            return Font.system(size: size, weight: weight)
        }
        var descriptor: UIFontDescriptor
        if let text {
            descriptor = UIFontDescriptor(fontAttributes: [.name: text])
        } else {
            descriptor = UIFont.systemFont(ofSize: size, weight: Self.uiWeight(weight)).fontDescriptor
        }
        if let emoji {
            let fallback = UIFontDescriptor(fontAttributes: [.name: emoji])
            descriptor = descriptor.addingAttributes([.cascadeList: [fallback]])
        }
        let uiFont = UIFont(descriptor: descriptor, size: size)
        let base = Font(uiFont as CTFont)
        return text != nil ? base.weight(weight) : base
    }

    // MARK: 壁纸和图标

    func importWallpaper(data: Data) -> Bool {
        guard let decoded = Self.decode(data, maxSide: Self.wallpaperMaxSide),
              let jpeg = decoded.jpegData(compressionQuality: 0.92) else { return false }
        do {
            try jpeg.write(to: wallpaperFile(), options: .atomic)
        } catch {
            return false
        }
        wallpaperLuma = Self.luma(of: decoded)
        wallpaper = decoded
        return true
    }

    func importIcon(_ app: AppId, data: Data) -> Bool {
        guard let decoded = Self.decode(data, maxSide: Self.iconDecodeSide) else { return false }
        let width = decoded.size.width
        let height = decoded.size.height
        let side = min(width, height)
        let target = min(side, Self.iconMaxSide)
        let k = target / side
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target), format: format)
        let square = renderer.image { _ in
            decoded.draw(in: CGRect(x: -(width - side) / 2 * k, y: -(height - side) / 2 * k, width: width * k, height: height * k))
        }
        guard let png = square.pngData() else { return false }
        do {
            try png.write(to: iconFile(app), options: .atomic)
        } catch {
            return false
        }
        icons[app] = square
        return true
    }

    func resetWallpaper() {
        try? FileManager.default.removeItem(at: wallpaperFile())
        wallpaper = nil
        wallpaperLuma = nil
    }

    func resetIcon(_ app: AppId) {
        try? FileManager.default.removeItem(at: iconFile(app))
        icons.removeValue(forKey: app)
    }

    func resetAllIcons() {
        for app in AppId.allCases {
            try? FileManager.default.removeItem(at: iconFile(app))
        }
        icons.removeAll()
    }

    // MARK: 内部

    private func wallpaperFile() -> URL { dir.appendingPathComponent("appearance_wallpaper.jpg") }
    private func iconFile(_ app: AppId) -> URL { dir.appendingPathComponent("appearance_icon_\(app.rawValue).png") }
    private func fontFile(_ id: String) -> URL { fontsDir.appendingPathComponent("font_\(id).ttf") }
    private func emojiFile(_ id: String) -> URL { fontsDir.appendingPathComponent("emoji_\(id).ttf") }

    private func postScript(of id: String?, in list: [FontEntry]) -> String? {
        guard let id else { return nil }
        return list.first(where: { $0.id == id })?.postScript
    }

    private static func newId() -> String {
        String(Int(Date().timeIntervalSince1970 * 1000))
    }

    private static func displayName(_ url: URL, fallback: String) -> String {
        let raw = url.deletingPathExtension().lastPathComponent.trimmingCharacters(in: .whitespaces)
        return raw.isEmpty ? fallback : raw
    }

    private static func uiWeight(_ weight: Font.Weight) -> UIFont.Weight {
        if weight == .ultraLight { return .ultraLight }
        if weight == .thin { return .thin }
        if weight == .light { return .light }
        if weight == .medium { return .medium }
        if weight == .semibold { return .semibold }
        if weight == .bold { return .bold }
        if weight == .heavy { return .heavy }
        if weight == .black { return .black }
        return .regular
    }

    private static func looksLikeFont(_ data: Data) -> Bool {
        guard data.count >= 4 else { return false }
        let head = [UInt8](data.prefix(4))
        let isTrueType = head == [0, 1, 0, 0]
        let tag = String(bytes: head, encoding: .isoLatin1) ?? ""
        return isTrueType || tag == "OTTO" || tag == "true" || tag == "ttcf"
    }

    private func registerFont(at url: URL) -> String? {
        guard let provider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(provider),
              let name = cgFont.postScriptName else { return nil }
        var error: Unmanaged<CFError>?
        _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        return name as String
    }

    private func copyFont(from url: URL, to target: URL) -> String? {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url), Self.looksLikeFont(data) else { return nil }
        do {
            try data.write(to: target, options: .atomic)
        } catch {
            return nil
        }
        guard let ps = registerFont(at: target) else {
            try? FileManager.default.removeItem(at: target)
            return nil
        }
        return ps
    }

    private func restoreFonts() {
        if let data = defaults.data(forKey: Key.fonts),
           let list = try? JSONDecoder().decode([FontEntry].self, from: data) {
            for entry in list where FileManager.default.fileExists(atPath: fontFile(entry.id).path) {
                _ = registerFont(at: fontFile(entry.id))
                fonts.append(entry)
            }
        }
        if let data = defaults.data(forKey: Key.emojis),
           let list = try? JSONDecoder().decode([FontEntry].self, from: data) {
            for entry in list where FileManager.default.fileExists(atPath: emojiFile(entry.id).path) {
                _ = registerFont(at: emojiFile(entry.id))
                emojis.append(entry)
            }
        }
        if let id = defaults.string(forKey: Key.activeFont), fonts.contains(where: { $0.id == id }) {
            activeFontId = id
        }
        if let id = defaults.string(forKey: Key.activeEmoji), emojis.contains(where: { $0.id == id }) {
            activeEmojiId = id
        }
    }

    private func saveFonts() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(fonts) { defaults.set(data, forKey: Key.fonts) }
        if let data = try? encoder.encode(emojis) { defaults.set(data, forKey: Key.emojis) }
        if let id = activeFontId { defaults.set(id, forKey: Key.activeFont) } else { defaults.removeObject(forKey: Key.activeFont) }
        if let id = activeEmojiId { defaults.set(id, forKey: Key.activeEmoji) } else { defaults.removeObject(forKey: Key.activeEmoji) }
    }

    private static func decode(_ data: Data, maxSide: CGFloat) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        guard longest > 0 else { return nil }
        let ratio = min(1, maxSide / longest)
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private static func luma(of image: UIImage) -> Double {
        guard let cg = image.cgImage else { return 0.5 }
        let n = 16
        var pixels = [UInt8](repeating: 0, count: n * n * 4)
        var result = 0.5
        pixels.withUnsafeMutableBytes { raw in
            guard let context = CGContext(
                data: raw.baseAddress,
                width: n,
                height: n,
                bitsPerComponent: 8,
                bytesPerRow: n * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            context.draw(cg, in: CGRect(x: 0, y: 0, width: n, height: n))
            let bytes = raw.bindMemory(to: UInt8.self)
            var sum = 0.0
            for i in 0..<(n * n) {
                let r = Double(bytes[i * 4])
                let g = Double(bytes[i * 4 + 1])
                let b = Double(bytes[i * 4 + 2])
                sum += (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            }
            result = sum / Double(n * n)
        }
        return result
    }
}
