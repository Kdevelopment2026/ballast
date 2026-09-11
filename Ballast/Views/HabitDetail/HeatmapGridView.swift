import SwiftUI

/// A 90-day dot grid. Filled = completed that day. Deliberately no
/// "streak broken" language or highlighting anywhere — gaps are just gaps.
struct HeatmapGridView: View {
    let habit: Habit

    private let dayCount = 90
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 15)

    private var calendar: Calendar { .current }

    private var completedDays: Set<Date> {
        Set(habit.checkIns.map { calendar.startOfDay(for: $0.date) })
    }

    private var days: [Date] {
        let today = calendar.startOfDay(for: .now)
        return (0..<dayCount).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { day in
                let isDone = completedDays.contains(day)
                RoundedRectangle(cornerRadius: 3)
                    .fill(isDone ? BallastTheme.ringColor(for: 1) : Color.secondary.opacity(0.15))
                    .frame(height: 14)
            }
        }
        .accessibilityLabel("Last 90 days: \(completedDays.count) days completed")
    }
}
