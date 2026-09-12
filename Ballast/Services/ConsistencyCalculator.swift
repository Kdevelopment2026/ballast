import Foundation

/// Computes a rolling consistency percentage for a habit.
///
/// This is Ballast's entire reason for existing: a missed day dents this number
/// a little, it never resets months of progress to zero, and there is no
/// "broken" state anywhere in the app. Kept as pure, dependency-free
/// logic (operating on plain `Date` arrays) so it's fully unit-testable
/// without a `ModelContainer`.
enum ConsistencyCalculator {

    /// Rolling window length in days, once a habit is at least this old.
    static let windowLength = 30

    /// Returns a value in `0...1`.
    ///
    /// - Parameters:
    ///   - checkInDates: every date the habit was completed (unsorted, may contain duplicates).
    ///   - createdAt: when the habit was created — the window can never be older than this.
    ///   - date: the reference "today" (injectable for testing).
    ///   - calendar: injectable for testing; defaults to the current calendar.
    static func consistency(
        checkInDates: [Date],
        createdAt: Date,
        asOf date: Date = .now,
        calendar: Calendar = .current
    ) -> Double {
        let today = calendar.startOfDay(for: date)
        let window = windowDays(createdAt: createdAt, asOf: date, calendar: calendar)
        guard window > 0,
              let windowStart = calendar.date(byAdding: .day, value: -(window - 1), to: today)
        else {
            return 0
        }

        let normalizedCheckIns = Set(checkInDates.map { calendar.startOfDay(for: $0) })
        let completed = normalizedCheckIns.filter { $0 >= windowStart && $0 <= today }.count

        return Double(completed) / Double(window)
    }

    /// How many days the percentage currently covers: the habit's age, capped
    /// at `windowLength`. Lets copy say "over 12 days so far" instead of
    /// pretending a five-day-old habit has 30 days of history.
    static func windowDays(
        createdAt: Date,
        asOf date: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let today = calendar.startOfDay(for: date)
        let created = calendar.startOfDay(for: createdAt)
        guard today >= created else { return 0 }
        let daysActive = (calendar.dateComponents([.day], from: created, to: today).day ?? 0) + 1
        return min(daysActive, windowLength)
    }

    /// Human copy for the window, e.g. "over the last 30 days" or
    /// "over 12 days so far". Shared by every caption so wording stays consistent.
    static func windowDescription(
        createdAt: Date,
        asOf date: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        let days = windowDays(createdAt: createdAt, asOf: date, calendar: calendar)
        switch days {
        case windowLength...: return "over the last \(windowLength) days"
        case 1: return "so far today"
        default: return "over \(days) days so far"
        }
    }

    /// Convenience overload for a `Habit` model instance.
    static func consistency(
        for habit: Habit,
        asOf date: Date = .now,
        calendar: Calendar = .current
    ) -> Double {
        consistency(
            checkInDates: habit.checkIns.map(\.date),
            createdAt: habit.createdAt,
            asOf: date,
            calendar: calendar
        )
    }

    /// The habit that most needs a weekly reflection prompt — the least
    /// consistent one right now. Returns `nil` if there are no active habits.
    static func leastConsistentHabit(
        among habits: [Habit],
        asOf date: Date = .now,
        calendar: Calendar = .current
    ) -> Habit? {
        habits
            .filter { !$0.isArchived }
            .min { lhs, rhs in
                consistency(for: lhs, asOf: date, calendar: calendar)
                    < consistency(for: rhs, asOf: date, calendar: calendar)
            }
    }
}
