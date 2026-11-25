import SwiftUI
import Observation
import UIKit

let CardDefaultName = "我的名字"
let CardDefaultTopic = ">添加话题"
let CardDefaultBody = "在这里写下你想说的话"
let CardDefaultMusic = "添加音乐"

@Observable
final class PhotoCardStore {
    static let shared = PhotoCardStore()
    static let avatarKey = "avatar"
    static let photoKey = "photo"

    private(set) var name: String
    private(set) var topic: String
    private(set) var body: String
    private(set) var music: String
    private(set) var avatar: UIImage?
    private(set) var photo: UIImage?

    private init() {
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: "photo_card.name") ?? CardDefaultName
        topic = defaults.string(forKey: "photo_card.topic") ?? CardDefaultTopic
        body = defaults.string(forKey: "photo_card.body") ?? CardDefaultBody
        music = defaults.string(forKey: "photo_card.music") ?? CardDefaultMusic
        avatar = WidgetImageFiles.load("photo_card_avatar.jpg")
        photo = WidgetImageFiles.load("photo_card_photo.jpg")
    }

    func updateName(_ value: String) {
        name = value
        UserDefaults.standard.set(value, forKey: "photo_card.name")
    }

    func updateTopic(_ value: String) {
        topic = value
        UserDefaults.standard.set(value, forKey: "photo_card.topic")
    }

    func updateBody(_ value: String) {
        body = value
        UserDefaults.standard.set(value, forKey: "photo_card.body")
    }

    func updateMusic(_ value: String) {
        music = value
        UserDefaults.standard.set(value, forKey: "photo_card.music")
    }

    func importImage(_ data: Data, key: String) {
        guard let image = WidgetImageFiles.save(data, as: "photo_card_\(key).jpg") else { return }
        if key == Self.avatarKey {
            avatar = image
        } else {
            photo = image
        }
    }

    func reset() {
        let defaults = UserDefaults.standard
        for key in ["name", "topic", "body", "music"] {
            defaults.removeObject(forKey: "photo_card.\(key)")
        }
        WidgetImageFiles.remove("photo_card_avatar.jpg")
        WidgetImageFiles.remove("photo_card_photo.jpg")
        name = CardDefaultName
        topic = CardDefaultTopic
        body = CardDefaultBody
        music = CardDefaultMusic
        avatar = nil
        photo = nil
    }
}
