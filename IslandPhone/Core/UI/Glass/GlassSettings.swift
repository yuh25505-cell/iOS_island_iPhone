import SwiftUI
import Observation

@Observable
final class GlassSettings {
    static let shared = GlassSettings()

    private(set) var tint: Double = 0.8
    private(set) var shadow: Double = 0.2
    private(set) var enabled: Bool = true

    @ObservationIgnored private let defaults = UserDefaults.standard

    private enum Key {
        static let tint = "glass_tint"
        static let shadow = "glass_shadow"
        static let enabled = "glass_enabled"
    }

    private init() {
        if let value = defaults.object(forKey: Key.tint) as? Double { tint = value }
        if let value = defaults.object(forKey: Key.shadow) as? Double { shadow = value }
        if let value = defaults.object(forKey: Key.enabled) as? Bool { enabled = value }
    }

    func setTint(_ value: Double) {
        tint = min(max(value, 0), 2)
        defaults.set(tint, forKey: Key.tint)
    }

    func setShadow(_ value: Double) {
        shadow = min(max(value, 0), 2)
        defaults.set(shadow, forKey: Key.shadow)
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        defaults.set(value, forKey: Key.enabled)
    }

    func reset() {
        tint = 0.8
        shadow = 0.2
        enabled = true
        defaults.removeObject(forKey: Key.tint)
        defaults.removeObject(forKey: Key.shadow)
        defaults.removeObject(forKey: Key.enabled)
    }
}
