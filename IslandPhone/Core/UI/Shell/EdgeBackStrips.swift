import SwiftUI

struct EdgeBackStrips: View {
    let onProgress: (CGFloat) -> Void
    let onCommit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            strip(sign: 1)
            Spacer(minLength: 0)
            strip(sign: -1)
        }
        .frame(maxHeight: .infinity)
    }

    private func strip(sign: CGFloat) -> some View {
        Color.clear
            .frame(width: 18)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onProgress(progress(value.translation.width, sign: sign))
                    }
                    .onEnded { value in
                        if progress(value.translation.width, sign: sign) >= 0.4 {
                            onCommit()
                        } else {
                            onProgress(0)
                        }
                    }
            )
    }

    private func progress(_ dx: CGFloat, sign: CGFloat) -> CGFloat {
        min(max(dx * sign / 140, 0), 1)
    }
}
