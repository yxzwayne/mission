import Foundation
import SwiftData

@MainActor
final class ObjectivesStore: ObservableObject {
    @Published private(set) var sections: [ObjectiveSection] = []

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        ensureDefaultSections()
        refresh()
    }

    var visibleSections: [ObjectiveSection] {
        sections
            .filter { $0.isVisible }
            .sorted { $0.order < $1.order }
    }

    var hasVisibleObjectives: Bool {
        visibleSections.contains { !$0.visibleObjectives.isEmpty }
    }

    func refresh() {
        do {
            var descriptor = FetchDescriptor<ObjectiveSection>(
                sortBy: [SortDescriptor(\ObjectiveSection.order)]
            )
            descriptor.relationshipKeyPathsForPrefetching = [\.objectives]
            let fetched = try context.fetch(descriptor)
            fetched.forEach { section in
                section.objectives.sort { $0.order < $1.order }
            }
            sections = fetched
        } catch {
            print("Failed to fetch sections: \(error)")
        }
    }

    @discardableResult
    func addObjective(to section: ObjectiveSection) -> Objective {
        let nextOrder = (section.sortedObjectives.last?.order ?? -1) + 1
        let objective = Objective(title: "New Objective", order: nextOrder, section: section)
        section.objectives.append(objective)
        context.insert(objective)
        persistObjective(objective, forceRefresh: true)
        return objective
    }

    func deleteObjectives(at offsets: IndexSet, in section: ObjectiveSection) {
        let sorted = section.sortedObjectives
        for index in offsets.sorted(by: >) {
            guard sorted.indices.contains(index) else { continue }
            context.delete(sorted[index])
        }
        persistChanges(forceRefresh: true)
    }

    func deleteObjective(_ objective: Objective) {
        context.delete(objective)
        persistChanges(forceRefresh: true)
    }

    func moveObjectives(in section: ObjectiveSection, from source: IndexSet, to destination: Int) {
        var sorted = section.sortedObjectives
        sorted.move(fromOffsets: source, toOffset: destination)
        for (idx, objective) in sorted.enumerated() {
            objective.order = idx
            objective.touch()
        }
        section.objectives = sorted
        persistChanges(forceRefresh: true)
    }

    func toggleCompletion(_ objective: Objective) {
        objective.isCompleted.toggle()
        persistObjective(objective)
    }

    func toggleVisibility(_ objective: Objective) {
        objective.isVisible.toggle()
        persistObjective(objective, forceRefresh: true)
    }

    func updateTitle(_ objective: Objective, title: String) {
        objective.title = title
        persistObjective(objective)
    }

    func persistObjective(_ objective: Objective, forceRefresh: Bool = false) {
        objective.touch()
        persistChanges(forceRefresh: forceRefresh)
    }

    private func persistChanges(forceRefresh: Bool) {
        do {
            try context.save()
            if forceRefresh {
                refresh()
            } else {
                objectWillChange.send()
            }
        } catch {
            print("Failed to save ObjectiveHUD data: \(error)")
        }
    }

    private func ensureDefaultSections() {
        let defaults = [
            (name: "Main Objectives", order: 0),
            (name: "Bonus Objectives", order: 1)
        ]

        let descriptor = FetchDescriptor<ObjectiveSection>()
        let existingSections = (try? context.fetch(descriptor)) ?? []
        let existingNames = Set(existingSections.map(\.name))

        defaults
            .filter { !existingNames.contains($0.name) }
            .forEach { entry in
                let section = ObjectiveSection(name: entry.name, order: entry.order)
                context.insert(section)
            }

        if context.hasChanges {
            try? context.save()
        }
    }
}
