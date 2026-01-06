import SwiftUI
import SwiftData
import AppKit

@main
struct ObjectiveHUDApp: App {
    @StateObject private var environment: AppEnvironment

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppFontRegistry.registerCustomFonts()
        _environment = StateObject(wrappedValue: AppEnvironment())
    }

    var body: some Scene {
        MenuBarExtra("ObjectiveHUD", systemImage: "target") {
            MenuBarView(overlayManager: environment.overlayManager)
                .environmentObject(environment.store)
        }
        .menuBarExtraStyle(.menu)
        .modelContainer(environment.dataController.container)

        Window(EditorWindow.title, id: EditorWindow.identifier) {
            EditorView()
                .environmentObject(environment.store)
        }
        .modelContainer(environment.dataController.container)
        .defaultSize(width: 460, height: 560)
    }
}

enum EditorWindow {
    static let identifier = "objectivehud.editor"
    static let title = "Edit Objectives"
}
