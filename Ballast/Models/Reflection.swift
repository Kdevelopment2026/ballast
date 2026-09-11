import Foundation
import SwiftData

/// A short, optional weekly note — Ballast's only "accountability" mechanic,
/// and entirely private and local. Never surfaced to anyone but the user.
@Model
final class Reflection {
    var id: UUID
    /// Start of the ISO week (Monday, per `Calendar.dateInterval(of: .weekOfYear:)`)
    /// this reflection belongs to.
    var weekStart: Date
    var habitName: String?
    var note: String
    var createdAt: Date

    init(weekStart: Date, habitName: String? = nil, note: String, createdAt: Date = .now) {
        self.id = UUID()
        self.weekStart = weekStart
        self.habitName = habitName
        self.note = note
        self.createdAt = createdAt
    }
}
