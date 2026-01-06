import SwiftUI
import AppKit

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var overlayManager: OverlayWindowManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Edit Objectives…") {
                openEditorWindow()
            }

            Button(overlayManager.isOverlaySuppressed ? "Show Overlay" : "Hide Overlay") {
                overlayManager.toggleOverlayVisibility()
            }

            Divider()

            Button("Quit ObjectiveHUD") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(minWidth: 200)
    }

    private func openEditorWindow() {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: EditorWindow.identifier)
    }
}
