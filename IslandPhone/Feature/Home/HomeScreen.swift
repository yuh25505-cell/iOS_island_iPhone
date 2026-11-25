import SwiftUI

struct HomeScreen: View {
    @State private var state: HomeState
    @State private var launcher = LauncherState()

    @Environment(\.homeInsets) private var insets

    init() {
        let initial = HomeState(initial: GridApps)
        LayoutStore.restore(into: initial)
        _state = State(initialValue: initial)
    }

    var body: some View {
        let encoded = LayoutStore.encode(state)
        ZStack(alignment: .topLeading) {
            desktop
            if state.openFolderId != nil {
                FolderPopup(state: state)
            }
            AppLauncher(launcher: launcher)
        }
        .environment(\.launcher, launcher)
        .coordinateSpace(name: "home")
        .ignoresSafeArea()
        .onChange(of: encoded) { _, data in
            if let data { LayoutStore.save(data) }
        }
    }

    private var desktop: some View {
        IslandDesktopTheme {
            ZStack(alignment: .topLeading) {
                IslandWallpaper(useCustom: true)
                HomePager(state: state)
                    .padding(.top, insets.top + 48)
                    .padding(.bottom, insets.bottom + 118)
                    .zIndex(state.isDraggingAny ? 1 : 0)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Dock(state: state)
                        .padding(.horizontal, 16)
                        .padding(.bottom, insets.bottom + 10)
                }
                if state.editing {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer(minLength: 0)
                            EditDoneButton(onClick: { state.editing = false })
                        }
                        .padding(.top, insets.top + 6)
                        .padding(.trailing, 16)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
}
