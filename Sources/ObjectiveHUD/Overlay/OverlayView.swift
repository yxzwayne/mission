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
        .kerning(1)
        .shadow(color: .black.opacity(0.85), radius: 6, x: 0, y: 0)
        .background(Color.clear)
        .allowsHitTesting(false)
    }
}

private struct OverlaySectionView: View {
    let section: ObjectiveSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                sectionIcon
                sectionTitle
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(sortedObjectives) { objective in
                    OverlayObjectiveRow(objective: objective)
                }
            }
            .padding(.leading, 8)
        }
    }
}

private extension OverlaySectionView {
    var isMainObjectives: Bool {
        sectionNameMatches("Main Objectives")
    }

    var isBonusObjectives: Bool {
        sectionNameMatches("Bonus Objectives")
    }

    var usesPointerIcon: Bool {
        isMainObjectives || isBonusObjectives
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

    @ViewBuilder
    var sectionTitle: some View {
        let baseTitle = Text(section.name.capitalized)
            .font(OverlayFont.sectionLabel())
            .foregroundStyle(.white)

        if isMainObjectives || isBonusObjectives {
            baseTitle.shadow(
                color: Color(red: 72.0 / 255.0, green: 192.0 / 255.0, blue: 219.0 / 255.0).opacity(1),
                radius: 5,
                x: 0,
                y: 0
            )
        } else {
            baseTitle
        }
    }

    func sectionNameMatches(_ target: String) -> Bool {
        section.name.compare(target, options: .caseInsensitive) == .orderedSame
    }
    
    var sortedObjectives: [Objective] {
        section.visibleObjectives.enumerated().sorted { lhs, rhs in
            if lhs.element.isCompleted != rhs.element.isCompleted {
                return lhs.element.isCompleted == false
            }
            return lhs.offset < rhs.offset
        }.map { $0.element }
    }
}

private struct OverlayObjectiveRow: View {
    let objective: Objective

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: objective.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(OverlayFont.icon())
                .foregroundStyle(objective.isCompleted ? .green.opacity(0.9) : .white.opacity(0.75))

            Text(objective.title)
                .font(OverlayFont.objectiveTitle())
                .foregroundStyle(objective.isCompleted ? Color.white.opacity(0.65) : .white)
                .strikethrough(objective.isCompleted, color: Color.white.opacity(0.65))
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

