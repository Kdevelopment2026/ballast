import Foundation
import SwiftData

/// Something the user wants to show up for. Deliberately carries no running
/// tally of consecutive days — consistency is always computed on read from
/// `checkIns` via `ConsistencyCalculator`.
@Model
final class Habit {
    var id: UUID
    var name: String
    var emoji: String
    var createdAt: Date
    /// Time-of-day for a daily reminder. `nil` means no reminder is scheduled.
    var reminderTime: Date?
    var isArchived: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.habit)
    var checkIns: [CheckIn] = []

    init(
        name: String,
        emoji: String = "🟦",
        createdAt: Date = .now,
        reminderTime: Date? = nil,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.createdAt = createdAt
        self.reminderTime = reminderTime
        self.isArchived = isArchived
        self.sortOrder = sortOrder
    }
}
