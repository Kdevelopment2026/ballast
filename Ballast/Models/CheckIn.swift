import Foundation
import SwiftData

/// One completed day for one habit. Absence of a CheckIn is neutral — Ballast
/// never records or displays an explicit "missed" state, only what was done.
@Model
final class CheckIn {
    var id: UUID
    /// Always normalised to the start of the day (see `Calendar.startOfDay(for:)`).
    var date: Date
    var habit: Habit?

    init(date: Date, habit: Habit? = nil) {
        self.id = UUID()
        self.date = date
        self.habit = habit
    }
}
