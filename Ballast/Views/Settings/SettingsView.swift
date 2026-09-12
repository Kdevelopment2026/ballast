import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    @AppStorage("ballast.appearance") private var appearanceRawValue: String = AppearanceOption.system.rawValue
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    private var archivedHabits: [Habit] { habits.filter(\.isArchived) }

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Appearance", selection: $appearanceRawValue) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            if !archivedHabits.isEmpty {
                Section {
                    ForEach(archivedHabits) { habit in
                        HStack {
                            Text("\(habit.emoji) \(habit.name)")
                            Spacer()
                            Button("Bring back") {
                                habit.isArchived = false
                                ReminderScheduler.shared.scheduleReminder(for: habit)
                            }
                            .buttonStyle(.borderless)
                        }
                        .accessibilityElement(children: .combine)
                    }
                } header: {
                    Text("Archived")
                } footer: {
                    Text("Archived habits keep their history. Bringing one back picks up where it left off.")
                }
            }

            Section("Your data") {
                NavigationLink {
                    ReflectionListView()
                } label: {
                    Label("Weekly notes", systemImage: "leaf")
                }
                Button {
                    exportURL = CSVExporter.writeToTemporaryFile(habits: habits)
                    showingShareSheet = exportURL != nil
                } label: {
                    Label("Export check-ins as CSV", systemImage: "square.and.arrow.up")
                }
                .disabled(habits.isEmpty)
            }

            Section {
                Label("No accounts. No cloud. No subscription.", systemImage: "lock.shield")
                Label("Everything stays on this device.", systemImage: "iphone")
                Label("One honest number. The number dips, it doesn't break.", systemImage: "chart.pie")
            } header: {
                Text("About Ballast")
            }

            // Plain links that hand off to Safari — the app itself never makes a request.
            Section {
                Link(destination: URL(string: "https://kdevelopment2026.github.io/ballast/privacy.html")!) {
                    Label("Privacy policy", systemImage: "hand.raised")
                }
                Link(destination: URL(string: "https://kdevelopment2026.github.io/ballast/support.html")!) {
                    Label("Support", systemImage: "questionmark.circle")
                }
            } footer: {
                Text("Ballast \(versionString)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, BallastTheme.Spacing.sm)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
    }
}

/// Thin UIKit bridge for the share sheet — SwiftUI has no native file-share view.
private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(DemoData.previewContainer)
}
#endif
