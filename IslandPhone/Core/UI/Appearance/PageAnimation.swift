import SwiftUI

struct PageAnimationModifier<V: Equatable>: ViewModifier {
    let animation: Animation
    let value: V
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let on = AppearanceStore.shared.pageAnimation && !reduceMotion
        content.animation(on ? animation : nil, value: value)
    }
}

extension View {
    func pageAnimated<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(PageAnimationModifier(animation: animation, value: value))
    }
}

enum PageAnimation {
    static var enabled: Bool {
        AppearanceStore.shared.pageAnimation
    }
}
