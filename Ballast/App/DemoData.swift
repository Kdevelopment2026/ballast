#if DEBUG
import Foundation
import SwiftData

/// Demo habits at different consistency levels so every `#Preview` is
/// inspectable without data entry. Debug builds only — never ships.
///
/// Also used when the app is launched with `-ballast-seed-demo` (see
/// `BallastApp`) so screens can be checked on a simulator with real data.
enum DemoData {

    /// An in-memory container pre-seeded with demo habits.
    @MainActor
    static var previewContainer: ModelContainer = {
        let schema = Schema([Habit.self, CheckIn.self, Reflection.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        seed(into: container.mainContext)
        return container
    }()

    /// The first demo habit — handy for detail/edit previews.
    @MainActor
    static var sampleHabit: Habit {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
        return (try? previewContainer.mainContext.fetch(descriptor).first) ?? Habit(name: "Reading", emoji: "📖")
    }

    /// Inserts three habits: steady, middling and struggling.
    @MainActor
    static func seed(into context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        func day(_ daysAgo: Int) -> Date {
            calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
        }

        let habits: [(name: String, emoji: String, ageInDays: Int, completedDaysAgo: [Int], sortOrder: Int)] = [
            ("Reading", "📖", 120, Array(0..<90).filter { $0 % 7 != 3 }, 0),
            ("Walk", "🏃", 45, Array(0..<45).filter { $0 % 2 == 0 }, 1),
            ("Stretch", "🧘", 12, [1, 5, 9], 2),
        ]

        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today) ?? today
        let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: lastWeek)?.start ?? lastWeek
        context.insert(Reflection(
            weekStart: lastWeekStart,
            habitName: "Stretch",
            note: "Evenings got busy. Try five minutes after lunch instead."
        ))

        for entry in habits {
            let habit = Habit(
                name: entry.name,
                emoji: entry.emoji,
                createdAt: day(entry.ageInDays),
                sortOrder: entry.sortOrder
            )
            context.insert(habit)
            for daysAgo in entry.completedDaysAgo {
                context.insert(CheckIn(date: day(daysAgo), habit: habit))
            }
        }
    }
}
#endif
