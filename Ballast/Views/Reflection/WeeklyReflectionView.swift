import SwiftUI
import SwiftData

struct WeeklyReflectionView: View {
    let habit: Habit

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""

    private var weekStart: Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start
            ?? Calendar.current.startOfDay(for: .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("\(habit.emoji) \(habit.name) has been the hardest to keep up this week.")
                        .font(.headline)
                    Text("No judgement — just noticing. What got in the way, or what would help next week?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("This week") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("Optional. A sentence is plenty.")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("This week's note")
                        .accessibilityHint("Optional. A sentence is plenty.")
                }
            }
            .navigationTitle("Weekly check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let reflection = Reflection(weekStart: weekStart, habitName: habit.name, note: note)
        modelContext.insert(reflection)
        dismiss()
    }
}

#if DEBUG
#Preview {
    WeeklyReflectionView(habit: DemoData.sampleHabit)
        .modelContainer(DemoData.previewContainer)
}
#endif
