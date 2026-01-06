import SwiftData

@MainActor
final class DataController {
    let container: ModelContainer

    var context: ModelContext {
        container.mainContext
    }

    init(inMemory: Bool = false) {
        let schema = Schema([
            Objective.self,
            ObjectiveSection.self
        ])
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: inMemory
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to set up SwiftData container: \(error)")
        }
    }
}
