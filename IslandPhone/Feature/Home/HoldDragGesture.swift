import SwiftUI
import UIKit

final class HoldTouch {
    var active = false
    var holding = false
    var moved = false
    var last: CGPoint = .zero
    var task: Task<Void, Never>?
}

struct HoldDragModifier: ViewModifier {
    let space: CoordinateSpace
    let onTap: (CGPoint) -> Void
    let onHoldStart: (CGPoint) -> Bool
    let onHoldMove: (CGPoint) -> Void
    let onHoldEnd: () -> Void
    let onSwipeChange: (CGFloat) -> Void
    let onSwipeEnd: (CGFloat, CGFloat) -> Void

    @State var touch = HoldTouch()
    @GestureState var isDown = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: space)
                    .updating($isDown) { _, state, _ in state = true }
                    .onChanged { value in handleChange(value) }
                    .onEnded { value in handleEnd(value) }
            )
            .onChange(of: isDown) { _, down in
                if !down { settleIfStuck() }
            }
    }

    private func handleChange(_ value: DragGesture.Value) {
        let t = touch
        if !t.active {
            t.active = true
            t.holding = false
            t.moved = false
            t.last = value.location
            t.task?.cancel()
            let start = onHoldStart
            t.task = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 400_000_000)
                if Task.isCancelled || t.moved || !t.active { return }
                if start(t.last) {
                    t.holding = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        t.last = value.location
        if t.holding {
            onHoldMove(value.location)
            return
        }
        let dist = hypot(value.translation.width, value.translation.height)
        if t.moved || dist > 10 {
            if !t.moved {
                t.moved = true
                t.task?.cancel()
            }
            onSwipeChange(value.translation.width)
        }
    }

    private func handleEnd(_ value: DragGesture.Value) {
        let t = touch
        t.task?.cancel()
        guard t.active else { return }
        let wasHolding = t.holding
        let moved = t.moved
        t.active = false
        t.holding = false
        t.moved = false
        if wasHolding {
            onHoldEnd()
        } else if moved {
            onSwipeEnd(value.translation.width, value.predictedEndTranslation.width)
        } else {
            onTap(value.location)
        }
    }

    private func settleIfStuck() {
        let t = touch
        guard t.active else { return }
        t.task?.cancel()
        let wasHolding = t.holding
        let moved = t.moved
        t.active = false
        t.holding = false
        t.moved = false
        if wasHolding {
            onHoldEnd()
        } else if moved {
            onSwipeEnd(0, 0)
        }
    }
}

extension View {
    func holdDrag(
        space: CoordinateSpace = .local,
        onTap: @escaping (CGPoint) -> Void = { _ in },
        onHoldStart: @escaping (CGPoint) -> Bool = { _ in false },
        onHoldMove: @escaping (CGPoint) -> Void = { _ in },
        onHoldEnd: @escaping () -> Void = {},
        onSwipeChange: @escaping (CGFloat) -> Void = { _ in },
        onSwipeEnd: @escaping (CGFloat, CGFloat) -> Void = { _, _ in }
    ) -> some View {
        modifier(HoldDragModifier(
            space: space,
            onTap: onTap,
            onHoldStart: onHoldStart,
            onHoldMove: onHoldMove,
            onHoldEnd: onHoldEnd,
            onSwipeChange: onSwipeChange,
            onSwipeEnd: onSwipeEnd
        ))
    }
}
