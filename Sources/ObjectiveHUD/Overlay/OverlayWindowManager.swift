import AppKit
import SwiftUI
import Combine

@MainActor
final class OverlayWindowManager: NSObject, ObservableObject {
    @Published private(set) var isUserHidden: Bool = false

    private let store: ObjectivesStore
    private let panel: NSPanel
    private let hostingView: NSHostingView<AnyView>
    private var cancellables: Set<AnyCancellable> = []
    private let padding = NSEdgeInsets(top: 20, left: 20, bottom: 0, right: 24)

    init(store: ObjectivesStore) {
        self.store = store
        let rootView = AnyView(
            OverlayView()
                .environmentObject(store)
        )
        hostingView = NSHostingView(rootView: rootView)
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 160),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        super.init()
        configurePanel()
        observeStore()
        observeScreenChanges()

        Task { @MainActor [weak self] in
            self?.handleStoreUpdate()
        }
    }

    var isOverlaySuppressed: Bool {
        isUserHidden
    }

    func toggleOverlayVisibility() {
        isUserHidden.toggle()
        updateVisibility()
    }

    private func configurePanel() {
        panel.isReleasedWhenClosed = false
        panel.hasShadow = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .statusBar
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]
        panel.isMovable = false
        panel.hidesOnDeactivate = false
        panel.contentView = hostingView
    }

    private func observeStore() {
        store.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleStoreUpdate()
            }
            .store(in: &cancellables)
    }

    private func observeScreenChanges() {
        NotificationCenter.default.publisher(
            for: NSApplication.didChangeScreenParametersNotification
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.positionPanel()
        }
        .store(in: &cancellables)
    }

    private func handleStoreUpdate() {
        refreshLayout()
        updateVisibility()
    }

    private func refreshLayout() {
        hostingView.layoutSubtreeIfNeeded()
        let newSize = hostingView.fittingSize
        if newSize.width.isFinite && newSize.height.isFinite {
            panel.setContentSize(newSize)
        }
        positionPanel()
    }

    private func updateVisibility() {
        let shouldShow = store.hasVisibleObjectives && !isUserHidden
        if shouldShow {
            if !panel.isVisible {
                panel.orderFrontRegardless()
            }
            positionPanel()
        } else {
            panel.orderOut(nil)
        }
    }

    private func positionPanel() {
        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let size = panel.frame.size
        let origin = NSPoint(
            x: frame.minX + padding.left,
            y: frame.maxY - size.height - padding.top
        )
        panel.setFrameOrigin(origin)
    }
}
