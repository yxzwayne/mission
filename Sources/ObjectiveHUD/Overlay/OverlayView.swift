import SwiftUI
import AppKit

struct OverlayView: View {
    @EnvironmentObject private var store: ObjectivesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(store.visibleSections) { section in
                if !section.visibleObjectives.isEmpty {
                    OverlaySectionView(section: section)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.85), radius: 6, x: 0, y: 0)
        .background(Color.clear)
        .allowsHitTesting(false)
    }
}

private struct OverlaySectionView: View {
    let section: ObjectiveSection

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                sectionIcon
                Text(section.name.capitalized)
                    .font(OverlayFont.sectionLabel())
                    .foregroundStyle(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(section.visibleObjectives) { objective in
                    OverlayObjectiveRow(objective: objective)
                }
            }
            .padding(.leading, 8)
        }
    }
}

private extension OverlaySectionView {
    var usesPointerIcon: Bool {
        sectionNameMatches("Main Objectives") || sectionNameMatches("Bonus Objectives")
    }

    @ViewBuilder
    var sectionIcon: some View {
        if usesPointerIcon, let triangleIcon = OverlayAssets.missionTriangle {
            Image(nsImage: triangleIcon)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 0)
        } else {
            Image(systemName: "triangle.fill")
                .font(OverlayFont.icon())
                .foregroundStyle(.cyan.opacity(0.9))
                .opacity(0.8)
        }
    }

    func sectionNameMatches(_ target: String) -> Bool {
        section.name.compare(target, options: .caseInsensitive) == .orderedSame
    }
}

private struct OverlayObjectiveRow: View {
    let objective: Objective

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: objective.isCompleted ? "largecircle.fill.circle" : "circle")
                .font(OverlayFont.icon())
                .foregroundStyle(objective.isCompleted ? .green.opacity(0.9) : .white.opacity(0.75))

            Text(objective.title)
                .font(OverlayFont.objectiveTitle())
                .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 0)
                .lineLimit(nil)

            if let suffix = objective.overlaySuffix {
                Spacer(minLength: 12)
                Text(suffix)
                    .font(OverlayFont.objectiveSuffix())
                    .foregroundStyle(.cyan)
            }
        }
    }
}
