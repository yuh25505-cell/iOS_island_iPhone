import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            Text("岛屿机")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    RootView()
}
