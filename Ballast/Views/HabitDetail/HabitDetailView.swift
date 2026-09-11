import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: BallastTheme.Spacing.lg) {
                VStack(spacing: BallastTheme.Spacing.sm) {
                    ConsistencyRing(
                        consistency: ConsistencyCalculator.consistency(for: habit),
                        lineWidth: 10,
                        size: 110
                    )
                    Text("Rolling 30-day consistency")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, BallastTheme.Spacing.lg)

                VStack(alignment: .leading, spacing: BallastTheme.Spacing.sm) {
                    Text("Last 90 days")
                        .font(.headline)
                    HeatmapGridView(habit: habit)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: BallastTheme.Spacing.xs) {
                    Text("No streaks here")
                        .font(.headline)
                    Text("A missed day dents this number a little. It never resets it to zero. Show up when you can.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BallastTheme.cardBackground, in: RoundedRectangle(cornerRadius: BallastTheme.CornerRadius.card))
                .padding(.horizontal)
            }
            .padding(.bottom, BallastTheme.Spacing.xl)
        }
        .navigationTitle("\(habit.emoji) \(habit.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Button(habit.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox") {
                        habit.isArchived.toggle()
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditHabitView(habit: habit)
        }
        .confirmationDialog(
            "Delete this habit and all its history?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                ReminderScheduler.shared.cancelReminder(for: habit)
                modelContext.delete(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
