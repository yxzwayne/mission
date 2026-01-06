import Foundation
import SwiftData

@Model
final class Objective: Identifiable {
    var id: UUID
    var title: String
    var order: Int
    var isCompleted: Bool
    var isVisible: Bool
    var progressCurrent: Int?
    var progressTotal: Int?
    var countdownTarget: Date?
    var countdownLabel: String?
    var updatedAt: Date

    var section: ObjectiveSection?

    init(
        id: UUID = UUID(),
        title: String,
        order: Int,
        isCompleted: Bool = false,
        isVisible: Bool = true,
        progressCurrent: Int? = nil,
        progressTotal: Int? = nil,
        countdownTarget: Date? = nil,
        countdownLabel: String? = nil,
        updatedAt: Date = .now,
        section: ObjectiveSection? = nil
    ) {
        self.id = id
        self.title = title
        self.order = order
        self.isCompleted = isCompleted
        self.isVisible = isVisible
        self.progressCurrent = progressCurrent
        self.progressTotal = progressTotal
        self.countdownTarget = countdownTarget
        self.countdownLabel = countdownLabel
        self.updatedAt = updatedAt
        self.section = section
    }
}

extension Objective {
    var progressSummary: String? {
        guard
            let current = progressCurrent,
            let total = progressTotal,
            total > 0
        else {
            return nil
        }
        return "\(current)/\(total)"
    }

    var countdownSummary: String? {
        guard let target = countdownTarget else {
            return nil
        }
        let remaining = Int(target.timeIntervalSinceNow.rounded(.down))
        guard remaining > 0 else { return countdownLabel }
        let minutes = remaining / 60
        let seconds = remaining % 60
        let prefix = countdownLabel.map { "\($0) in" } ?? "in"
        return "\(prefix) \(minutes):" + String(format: "%02d", seconds)
    }

    var overlaySuffix: String? {
        if let progressSummary {
            return "(\(progressSummary))"
        }
        if let countdownSummary {
            return "(\(countdownSummary))"
        }
        return nil
    }

    func touch() {
        updatedAt = .now
    }
}
