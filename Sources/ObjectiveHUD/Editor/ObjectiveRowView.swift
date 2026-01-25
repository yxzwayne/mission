import SwiftUI
import SwiftData

struct ObjectiveRowView: View {
    @EnvironmentObject private var store: ObjectivesStore
    @Bindable var objective: Objective
    @State private var titleDraft: String
    @FocusState private var isTitleFocused: Bool
    @State private var showingDetail = false

    init(objective: Objective) {
        _objective = Bindable(objective)
        _titleDraft = State(initialValue: objective.title)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Toggle("", isOn: $objective.isCompleted)
                .toggleStyle(.checkbox)
                .labelsHidden()
                .onChange(of: objective.isCompleted) { _, _ in
                    store.persistObjective(objective)
                }

            TextField("Objective title", text: $titleDraft)
                .focused($isTitleFocused)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .onSubmit(commitTitle)
                .onChange(of: isTitleFocused) { _, focused in
                    if !focused {
                        commitTitle()
                    }
                }
                .onChange(of: objective.title) { _, newValue in
                    if !isTitleFocused && newValue != titleDraft {
                        titleDraft = newValue
                    }
                }

            Spacer()

            Button {
                store.toggleVisibility(objective)
            } label: {
                Image(systemName: objective.isVisible ? "eye" : "eye.slash")
                    .foregroundStyle(.secondary)
                    .help(objective.isVisible ? "Hide from overlay" : "Show on overlay")
            }
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                store.deleteObjective(objective)
            } label: {
                Image(systemName: "trash")
                    .help("Delete objective")
            }
            .buttonStyle(.borderless)

            Button {
                showingDetail = true
            } label: {
                Image(systemName: "pencil")
                    .help("Edit details")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            isTitleFocused = true
        }
        .onAppear {
            titleDraft = objective.title
        }
        .sheet(isPresented: $showingDetail) {
            ObjectiveDetailView(objective: objective)
                .environmentObject(store)
        }
    }

    private func commitTitle() {
        let sanitized = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTitle = sanitized.isEmpty ? "New Objective" : sanitized
        guard newTitle != objective.title else { return }
        titleDraft = newTitle
        store.updateTitle(objective, title: newTitle)
    }
}

