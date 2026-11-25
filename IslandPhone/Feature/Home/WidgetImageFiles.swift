import UIKit

enum WidgetImageFiles {
    static let maxSide: CGFloat = 1280

    static func url(_ name: String) -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(name)
    }

    static func load(_ name: String) -> UIImage? {
        UIImage(contentsOfFile: url(name).path)
    }

    static func save(_ data: Data, as name: String) -> UIImage? {
        guard let source = UIImage(data: data) else { return nil }
        let longest = max(source.size.width, source.size.height)
        guard longest > 0 else { return nil }
        let scale = longest > maxSide ? maxSide / longest : 1
        let target = CGSize(width: source.size.width * scale, height: source.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let prepared = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            source.draw(in: CGRect(origin: .zero, size: target))
        }
        guard let jpeg = prepared.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try jpeg.write(to: url(name), options: .atomic)
        } catch {
            return nil
        }
        return prepared
    }

    static func remove(_ name: String) {
        try? FileManager.default.removeItem(at: url(name))
    }
}
