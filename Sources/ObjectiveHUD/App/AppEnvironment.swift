import SwiftUI
import SwiftData

@MainActor
final class AppEnvironment: ObservableObject {
    let dataController: DataController
    let store: ObjectivesStore
    let overlayManager: OverlayWindowManager

    init() {
        dataController = DataController()
        store = ObjectivesStore(context: dataController.context)
        overlayManager = OverlayWindowManager(store: store)
    }
}
