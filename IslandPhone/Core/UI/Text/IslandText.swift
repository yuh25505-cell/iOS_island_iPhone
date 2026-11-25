import SwiftUI

struct IslandText: View {
    private let text: String
    private let size: CGFloat
    private let weight: Font.Weight
    private let color: Color?
    private let lineLimit: Int?
    private let alignment: TextAlignment
    private let shadowColor: Color
    private let shadowRadius: CGFloat

    init(
        _ text: String,
        size: CGFloat = 17,
        weight: Font.Weight = .regular,
        color: Color? = nil,
        lineLimit: Int? = nil,
        alignment: TextAlignment = .leading,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 3
    ) {
        self.text = text
        self.size = size
        self.weight = weight
        self.color = color
        self.lineLimit = lineLimit
        self.alignment = alignment
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
    }

    var body: some View {
        Text(text)
            .font(AppearanceStore.shared.font(size: size, weight: weight))
            .foregroundStyle(color ?? Color.primary)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 1)
    }
}

struct IslandTextField: View {
    private let placeholder: String
    private let text: Binding<String>
    private let size: CGFloat
    private let color: Color?
    private let axis: Axis
    private let maxLines: Int

    init(
        _ placeholder: String,
        text: Binding<String>,
        size: CGFloat = 17,
        color: Color? = nil,
        axis: Axis = .horizontal,
        maxLines: Int = 3
    ) {
        self.placeholder = placeholder
        self.text = text
        self.size = size
        self.color = color
        self.axis = axis
        self.maxLines = maxLines
    }

    var body: some View {
        if axis == .vertical {
            TextField(placeholder, text: text, axis: .vertical)
                .font(AppearanceStore.shared.font(size: size))
                .foregroundStyle(color ?? Color.primary)
                .lineLimit(1...max(maxLines, 1))
        } else {
            TextField(placeholder, text: text)
                .font(AppearanceStore.shared.font(size: size))
                .foregroundStyle(color ?? Color.primary)
        }
    }
}
