import SwiftUI

struct ObjectiveDetailView: View {
    @EnvironmentObject private var store: ObjectivesStore
    @Environment(\.dismiss) private var dismiss
    @Bindable var objective: Objective
    @State private var countdownEnabled: Bool

    init(objective: Objective) {
        _objective = Bindable(objective)
        _countdownEnabled = State(initialValue: objective.countdownTarget != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: Binding(
                        get: { objective.title },
                        set: { store.updateTitle(objective, title: $0) }
                    ))
                    Toggle("Completed", isOn: $objective.isCompleted)
                        .onChange(of: objective.isCompleted) { _, _ in
                            store.persistObjective(objective)
                        }
                    Toggle("Visible", isOn: $objective.isVisible)
                        .onChange(of: objective.isVisible) { _, _ in
                            store.persistObjective(objective, forceRefresh: true)
                        }
                }

                Section("Section") {
                    Picker("Section", selection: sectionIDBinding) {
                        ForEach(store.sections) { section in
                            Text(section.name)
                                .tag(section.id as UUID?)
                        }
                    }
                }

                Section("Progress") {
                    HStack {
                        Text("Current")
                        TextField("Current", text: binding(for: \.progressCurrent))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Total")
                        TextField("Total", text: binding(for: \.progressTotal))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    Button("Clear Progress") {
                        objective.progressCurrent = nil
                        objective.progressTotal = nil
                        store.persistObjective(objective)
                    }
                }

                Section("Countdown") {
                    Toggle("Enable Countdown", isOn: $countdownEnabled)
                        .onChange(of: countdownEnabled) { _, newValue in
                            if newValue {
                                if objective.countdownTarget == nil {
                                    objective.countdownTarget = Date().addingTimeInterval(600)
                                }
                            } else {
                                objective.countdownTarget = nil
                                objective.countdownLabel = nil
                            }
                            store.persistObjective(objective)
                        }

                    if countdownEnabled {
                        DatePicker(
                            "Target",
                            selection: countdownDateBinding,
                            displayedComponents: [.hourAndMinute, .date]
                        )
                        TextField("Label (e.g. Purified)", text: countdownLabelBinding)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .navigationTitle("Objective Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 360, minHeight: 440)
        .onDisappear {
            store.persistObjective(objective, forceRefresh: true)
        }
    }

    private var sectionIDBinding: Binding<UUID?> {
        Binding<UUID?>(
            get: { objective.section?.id },
            set: { newID in
                if let id = newID, let match = store.sections.first(where: { $0.id == id }) {
                    objective.section = match
                } else {
                    objective.section = nil
                }
                store.persistObjective(objective, forceRefresh: true)
            }
        )
    }

    private func binding(for keyPath: ReferenceWritableKeyPath<Objective, Int?>) -> Binding<String> {
        Binding<String>(
            get: {
                if let value = objective[keyPath: keyPath] {
                    return String(value)
                }
                return ""
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    objective[keyPath: keyPath] = nil
                } else if let value = Int(trimmed) {
                    objective[keyPath: keyPath] = value
                }
                store.persistObjective(objective)
            }
        )
    }

    private var countdownDateBinding: Binding<Date> {
        Binding<Date>(
            get: {
                objective.countdownTarget ?? Date().addingTimeInterval(600)
            },
            set: { newDate in
                objective.countdownTarget = newDate
                store.persistObjective(objective)
            }
        )
    }

    private var countdownLabelBinding: Binding<String> {
        Binding<String>(
            get: { objective.countdownLabel ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                objective.countdownLabel = trimmed.isEmpty ? nil : trimmed
                store.persistObjective(objective)
            }
        )
    }
}
