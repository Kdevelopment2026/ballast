import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCheckedToday: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: BallastTheme.Spacing.md) {
            Button(action: onToggle) {
                Image(systemName: isCheckedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCheckedToday ? BallastTheme.ringColor(for: 1) : Color.secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(habit.emoji) \(habit.name)")
                    .font(.body.weight(.medium))
                Text(consistencyCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ConsistencyRing(consistency: ConsistencyCalculator.consistency(for: habit), size: 40)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: isCheckedToday ? "Mark not done" : "Mark done", onToggle)
    }

    private var consistencyCaption: String {
        let percent = Int((ConsistencyCalculator.consistency(for: habit) * 100).rounded())
        return "\(percent)% steady over the last 30 days"
    }
}
