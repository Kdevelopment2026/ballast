import SwiftUI
import SwiftData

struct AddEditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// `nil` when creating a new habit; a live instance when editing one.
    let habit: Habit?

    @State private var name: String = ""
    @State private var emoji: String = "🟦"
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(
        bySettingHour: 20, minute: 0, second: 0, of: .now
    ) ?? .now

    private let emojiChoices = ["🟦", "🏃", "💧", "📖", "🧘", "🥗", "😴", "✍️", "🎯", "🌱", "🧹", "☎️"]

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you showing up for?") {
                    TextField("Habit name", text: $name)

                    Picker("Icon", selection: $emoji) {
                        ForEach(emojiChoices, id: \.self) { choice in
                            Text(choice).tag(choice)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Gentle reminder") {
                    Toggle("Daily reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section {
                    Text("Ballast never shows a red \"missed it\" state. Miss a day and the number dips a little — that's all.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(habit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: populateIfEditing)
        }
    }

    private func populateIfEditing() {
        guard let habit else { return }
        name = habit.name
        emoji = habit.emoji
        if let time = habit.reminderTime {
            reminderEnabled = true
            reminderTime = time
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedReminder = reminderEnabled ? reminderTime : nil

        if let habit {
            habit.name = trimmedName
            habit.emoji = emoji
            habit.reminderTime = resolvedReminder
            applyReminder(to: habit, enabled: reminderEnabled)
        } else {
            let newHabit = Habit(
                name: trimmedName,
                emoji: emoji,
                reminderTime: resolvedReminder,
                sortOrder: nextSortOrder()
            )
            modelContext.insert(newHabit)
            applyReminder(to: newHabit, enabled: reminderEnabled)
        }
        dismiss()
    }

    /// New habits go to the bottom of the Today list.
    private func nextSortOrder() -> Int {
        var descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
        descriptor.fetchLimit = 1
        let highest = (try? modelContext.fetch(descriptor).first?.sortOrder) ?? -1
        return highest + 1
    }

    private func applyReminder(to habit: Habit, enabled: Bool) {
        if enabled {
            Task {
                if await ReminderScheduler.shared.requestAuthorizationIfNeeded() {
                    ReminderScheduler.shared.scheduleReminder(for: habit)
                }
            }
        } else {
            ReminderScheduler.shared.cancelReminder(for: habit)
        }
    }
}

#if DEBUG
#Preview("New habit") {
    AddEditHabitView(habit: nil)
        .modelContainer(DemoData.previewContainer)
}

#Preview("Edit habit") {
    AddEditHabitView(habit: DemoData.sampleHabit)
        .modelContainer(DemoData.previewContainer)
}
#endif
