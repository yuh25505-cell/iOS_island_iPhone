import SwiftUI
import Observation
import UIKit

@Observable
final class VinylStore {
    static let shared = VinylStore()

    private(set) var cover: UIImage?

    private init() {
        cover = WidgetImageFiles.load("vinyl_cover.jpg")
    }

    func importCover(_ data: Data) {
        if let image = WidgetImageFiles.save(data, as: "vinyl_cover.jpg") {
            cover = image
        }
    }

    func reset() {
        WidgetImageFiles.remove("vinyl_cover.jpg")
        cover = nil
    }
}
