import SwiftUI
import SwiftData

/// Every past weekly note, newest first. Private and local — the only reader
/// is the person who wrote them.
struct ReflectionListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Reflection.weekStart, order: .reverse)
    private var reflections: [Reflection]

    var body: some View {
        Group {
            if reflections.isEmpty {
                ContentUnavailableView {
                    Label("No notes yet", systemImage: "leaf")
                } description: {
                    Text("A short weekly check-in appears on Today from Friday to Sunday. Anything you write lands here.")
                }
            } else {
                List {
                    ForEach(reflections) { reflection in
                        VStack(alignment: .leading, spacing: BallastTheme.Spacing.xs) {
                            HStack {
                                Text("Week of \(reflection.weekStart.formatted(.dateTime.day().month(.wide)))")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                if let habitName = reflection.habitName {
                                    Text(habitName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(reflection.note.isEmpty ? "Checked in, no note." : reflection.note)
                                .font(.body)
                                .foregroundStyle(reflection.note.isEmpty ? .secondary : .primary)
                        }
                        .padding(.vertical, BallastTheme.Spacing.xs)
                        .accessibilityElement(children: .combine)
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Weekly notes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(reflections[index])
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReflectionListView()
    }
    .modelContainer(DemoData.previewContainer)
}
#endif
