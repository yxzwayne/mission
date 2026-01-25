import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct EditorView: View {
    @EnvironmentObject private var store: ObjectivesStore
    @State private var selectedObjectiveIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List(selection: $selectedObjectiveIDs) {
                ForEach(store.sections) { section in
                    Section(header: sectionHeader(for: section)) {
                        ForEach(section.sortedObjectives) { objective in
                            ObjectiveRowView(objective: objective)
                                .tag(objective.id)
                                .draggable(objectiveDragItem(for: objective))
                        }
                        .onMove { indices, newOffset in
                            store.moveObjectives(
                                in: section,
                                from: indices,
                                to: newOffset
                            )
                        }
                        .onDelete { indices in
                            store.deleteObjectives(at: indices, in: section)
                        }
                        .onInsert(of: [UTType.text.identifier]) { index, providers in
                            handleDrop(into: section, at: index, providers: providers)
                        }

                        Button {
                            store.addObjective(to: section)
                        } label: {
                            HStack {
                                Label("New Objective", systemImage: "plus")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .selectionDisabled(true)
                    }
                }
            }
            .navigationTitle("ObjectiveHUD")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addMainObjective()
                    } label: {
                        Label("New Main Objective", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: [.command])
                }
                // ToolbarItem(placement: .automatic) {
                //     Button(role: .destructive) {
                //         deleteSelectedObjectives()
                //     } label: {
                //         Label("Delete Selected Objectives", systemImage: "trash")
                //     }
                //     .keyboardShortcut(.delete, modifiers: [.command])
                //     .disabled(selectedObjectiveIDs.isEmpty)
                // }
            }
        }
        .frame(minWidth: 420, minHeight: 520)
        .onAppear {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
        .onDisappear {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    private func addMainObjective() {
        guard let mainSection = store.sections.first(where: {
            $0.name.compare("Main Objectives", options: .caseInsensitive) == .orderedSame
        }) else {
            return
        }
        store.addObjective(to: mainSection)
    }

    private func deleteSelectedObjectives() {
        guard !selectedObjectiveIDs.isEmpty else { return }
        for section in store.sections {
            let sorted = section.sortedObjectives
            let indices = IndexSet(
                sorted.enumerated().compactMap { index, objective in
                    selectedObjectiveIDs.contains(objective.id) ? index : nil
                }
            )
            if !indices.isEmpty {
                store.deleteObjectives(at: indices, in: section)
            }
        }
        selectedObjectiveIDs.removeAll()
    }

    @ViewBuilder
    private func sectionHeader(for section: ObjectiveSection) -> some View {
        HStack {
            Text(section.name)
                .textCase(.uppercase)
                .font(.headline)
            Spacer()
            if !section.isVisible {
                Text("Hidden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func objectiveDragItem(for objective: Objective) -> NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: UTType.text.identifier, visibility: .all) { completion in
            let data = objective.id.uuidString.data(using: .utf8) ?? Data()
            completion(data, nil)
            return nil
        }
        return provider
    }

    private func handleDrop(into targetSection: ObjectiveSection, at index: Int, providers: [NSItemProvider]) {
        let typeId = UTType.text.identifier
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(typeId) {
                _ = provider.loadDataRepresentation(forTypeIdentifier: typeId) { data, _ in
                    guard let data, let idString = String(data: data, encoding: .utf8), let uuid = UUID(uuidString: idString) else { return }
                    DispatchQueue.main.async {
                        // Find the objective by UUID across all sections
                        guard let objective = store.sections.flatMap({ $0.objectives }).first(where: { $0.id == uuid }) else { return }
                        store.moveObjective(objective, to: targetSection, to: index)
                    }
                }
            }
        }
    }
}
