import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Query(sort: \Reflection.createdAt, order: .reverse)
    private var reflections: [Reflection]

    @State private var showingAddHabit = false
    @State private var reflectionHabit: Habit?

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    emptyState
                } else {
                    List {
                        if shouldShowReflectionBanner {
                            Section {
                                reflectionBanner
                            }
                        }
                        Section {
                            ForEach(habits) { habit in
                                NavigationLink(value: habit) {
                                    HabitRowView(
                                        habit: habit,
                                        isCheckedToday: isCheckedToday(habit),
                                        onToggle: { toggleToday(habit) }
                                    )
                                }
                            }
                            .onDelete(perform: archiveHabits)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today")
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddEditHabitView(habit: nil)
            }
            .sheet(item: $reflectionHabit) { habit in
                WeeklyReflectionView(habit: habit)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No habits yet", systemImage: "circle.dashed")
        } description: {
            Text("Add something you want to show up for. Ballast tracks how steady you are — not how long your chain is.")
        } actions: {
            Button("Add your first habit") { showingAddHabit = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var currentWeekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? calendar.startOfDay(for: .now)
    }

    private var hasReflectedThisWeek: Bool {
        reflections.contains { calendar.isDate($0.weekStart, inSameDayAs: currentWeekStart) }
    }

    private var shouldShowReflectionBanner: Bool {
        // Friday through Sunday — a gentle end-of-week window, not a daily nag.
        let weekday = calendar.component(.weekday, from: .now) // 1 = Sunday ... 7 = Saturday
        let isWeekendWindow = weekday == 1 || weekday == 6 || weekday == 7
        return isWeekendWindow && !hasReflectedThisWeek && !habits.isEmpty
    }

    private var reflectionBanner: some View {
        Button {
            reflectionHabit = ConsistencyCalculator.leastConsistentHabit(among: habits) ?? habits.first
        } label: {
            Label("A quick weekly check-in is ready", systemImage: "leaf")
        }
    }

    private func isCheckedToday(_ habit: Habit) -> Bool {
        let today = calendar.startOfDay(for: .now)
        return habit.checkIns.contains { calendar.isDate($0.date, inSameDayAs: today) }
    }

    private func toggleToday(_ habit: Habit) {
        let today = calendar.startOfDay(for: .now)
        if let existing = habit.checkIns.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            modelContext.delete(existing)
        } else {
            let checkIn = CheckIn(date: today, habit: habit)
            modelContext.insert(checkIn)
        }
    }

    private func archiveHabits(at offsets: IndexSet) {
        for index in offsets {
            habits[index].isArchived = true
            ReminderScheduler.shared.cancelReminder(for: habits[index])
        }
    }
}
