import SwiftUI
import SwiftData

struct HabitRowView: View {
    let habit: Habit
    let isCheckedToday: Bool
    let onToggle: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var consistency: Double { ConsistencyCalculator.consistency(for: habit) }
    private var percent: Int { Int((consistency * 100).rounded()) }
    private var window: String { ConsistencyCalculator.windowDescription(createdAt: habit.createdAt) }

    var body: some View {
        HStack(spacing: BallastTheme.Spacing.md) {
            Button(action: onToggle) {
                Image(systemName: isCheckedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCheckedToday ? BallastTheme.ringColor(for: 1) : Color.secondary)
                    .symbolEffect(.bounce, options: .nonRepeating, value: isCheckedToday && !reduceMotion)
                    .frame(
                        minWidth: BallastTheme.minimumTapTarget,
                        minHeight: BallastTheme.minimumTapTarget
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityHidden(true) // the row's custom action covers this

            VStack(alignment: .leading, spacing: 2) {
                Text("\(habit.emoji) \(habit.name)")
                    .font(.body.weight(.medium))
                Text("\(percent)% steady \(window)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ConsistencyRing(consistency: consistency, windowDescription: window, size: 40)
                .accessibilityHidden(true) // folded into the row label below
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(habit.name), \(percent) percent consistent \(window)")
        .accessibilityValue(isCheckedToday ? "Done today" : "Not done today")
        .accessibilityAction(named: isCheckedToday ? "Mark not done" : "Mark done", onToggle)
    }
}

#Preview {
    List {
        HabitRowView(habit: DemoData.sampleHabit, isCheckedToday: true, onToggle: {})
        HabitRowView(habit: Habit(name: "Walk", emoji: "🏃"), isCheckedToday: false, onToggle: {})
    }
    .modelContainer(DemoData.previewContainer)
}
