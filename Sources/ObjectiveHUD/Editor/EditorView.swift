import SwiftUI
import AppKit

struct EditorView: View {
    @EnvironmentObject private var store: ObjectivesStore
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.sections) { section in
                    Section(header: sectionHeader(for: section)) {
                        ForEach(section.sortedObjectives) { objective in
                            ObjectiveRowView(objective: objective)
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

                        Button {
                            store.addObjective(to: section)
                        } label: {
                            Label("New Objective", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationTitle("ObjectiveHUD")
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
}
