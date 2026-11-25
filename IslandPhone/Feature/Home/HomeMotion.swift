import SwiftUI
import UIKit

var pageMotionOn: Bool {
    PageAnimation.enabled && !UIAccessibility.isReduceMotionEnabled
}

func withPageAnimation(_ animation: Animation = .spring(response: 0.35, dampingFraction: 0.85), _ body: () -> Void) {
    if pageMotionOn {
        withAnimation(animation, body)
    } else {
        body()
    }
}

func lerpValue(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    a + (b - a) * t
}

func smoothStep(_ t: CGFloat) -> CGFloat {
    let x = min(max(t, 0), 1)
    return x * x * (3 - 2 * x)
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
