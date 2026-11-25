import SwiftUI
import Observation

@Observable
final class LauncherState {
    var app: AppId?
    var origin: CGRect = .zero

    func open(_ app: AppId, origin: CGRect) {
        if self.app != nil { return }
        self.origin = origin
        self.app = app
    }

    func close() {
        app = nil
    }
}

private struct LauncherKey: EnvironmentKey {
    static let defaultValue = LauncherState()
}

extension EnvironmentValues {
    var launcher: LauncherState {
        get { self[LauncherKey.self] }
        set { self[LauncherKey.self] = newValue }
    }
}

struct AppLauncher: View {
    let launcher: LauncherState

    var body: some View {
        if let app = launcher.app {
            AppLauncherLayer(app: app, launcher: launcher)
                .id(app)
        }
    }
}

private struct AppLauncherLayer: View {
    let app: AppId
    let launcher: LauncherState

    @Environment(\.appPages) private var pages
    @Environment(\.homeInsets) private var insets
    @State private var open: CGFloat
    @State private var closing = false
    @State private var backTarget: CGFloat = 0
    @State private var overlayState = ShellOverlayState()

    init(app: AppId, launcher: LauncherState) {
        self.app = app
        self.launcher = launcher
        _open = State(initialValue: pageMotionOn ? 0 : 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear.contentShape(Rectangle())
                appFrame(size: geo.size)
                if !closing && overlayState.count == 0 {
                    EdgeBackStrips(
                        onProgress: { value in backTarget = value },
                        onCommit: { requestClose() }
                    )
                }
            }
        }
        .onAppear {
            if pageMotionOn {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) { open = 1 }
            } else {
                open = 1
            }
        }
    }

    private func appFrame(size: CGSize) -> some View {
        let origin = launcher.origin
        let p = min(max(open, 0), 1)
        let frame = CGRect(
            x: lerpValue(origin.minX, 0, p),
            y: lerpValue(origin.minY, 0, p),
            width: lerpValue(origin.width, size.width, p),
            height: lerpValue(origin.height, size.height, p)
        )
        let back: CGFloat = pageMotionOn ? backTarget : 0
        let radius = lerpValue(origin.width * 0.22, 0, p) + 28 * back
        return pageStack(size: size)
            .opacity(smoothStep((p - 0.15) / 0.5))
            .frame(width: frame.width, height: frame.height)
            .overlay {
                AppIcon(app: app)
                    .scaleEffect(frame.width / 60)
                    .opacity(1 - min(p / 0.3, 1))
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .scaleEffect(1 - 0.08 * back)
            .animation(pageMotionOn ? .spring(response: 0.2, dampingFraction: 0.9) : nil, value: backTarget)
            .position(x: frame.midX, y: frame.midY)
    }

    private func pageStack(size: CGSize) -> some View {
        ZStack {
            IslandWallpaper()
            pageView
                .padding(.top, insets.top)
                .padding(.bottom, insets.bottom)
        }
        .frame(width: size.width, height: size.height)
    }

    @ViewBuilder
    private var pageView: some View {
        if let page = pages[app] {
            page({ requestClose() })
                .environment(\.shellOverlay, overlayState)
        } else {
            AppShell(title: app.label, onBack: { requestClose() }) {
                AppIcon(app: app, size: 96)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .environment(\.shellOverlay, overlayState)
        }
    }

    private func requestClose() {
        if closing { return }
        closing = true
        backTarget = 0
        if pageMotionOn {
            withAnimation(.spring(response: 0.31, dampingFraction: 1), completionCriteria: .logicallyComplete) {
                open = 0
            } completion: {
                launcher.close()
            }
        } else {
            open = 0
            launcher.close()
        }
    }
}
