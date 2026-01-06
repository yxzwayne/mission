import Foundation
import SwiftData

@Model
final class ObjectiveSection: Identifiable {
    var id: UUID
    var name: String
    var order: Int
    var isVisible: Bool
    var updatedAt: Date

    var objectives: [Objective]

    init(
        id: UUID = UUID(),
        name: String,
        order: Int,
        isVisible: Bool = true,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.isVisible = isVisible
        self.updatedAt = updatedAt
        self.objectives = []
    }
}

extension ObjectiveSection {
    var sortedObjectives: [Objective] {
        objectives.sorted { $0.order < $1.order }
    }

    var visibleObjectives: [Objective] {
        sortedObjectives.filter { $0.isVisible }
    }
}
