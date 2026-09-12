import SwiftUI
import SwiftData

/// A 90-day dot grid. Filled = completed that day. Gaps are just gaps —
/// there is no highlighting of missed days anywhere.
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

    private var completedInWindow: Int {
        let window = Set(days)
        return completedDays.filter { window.contains($0) }.count
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { day in
                let isDone = completedDays.contains(day)
                RoundedRectangle(cornerRadius: 3)
                    .fill(isDone ? BallastTheme.ringColor(for: 1) : Color.secondary.opacity(0.15))
                    .frame(height: 14)
                    .accessibilityElement()
                    .accessibilityLabel(day.formatted(.dateTime.day().month(.wide)))
                    .accessibilityValue(isDone ? "Done" : "Not done")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Last 90 days: \(completedInWindow) days done")
    }
}

#if DEBUG
#Preview {
    HeatmapGridView(habit: DemoData.sampleHabit)
        .padding()
        .modelContainer(DemoData.previewContainer)
}
#endif
