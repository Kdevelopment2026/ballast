import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Query private var habits: [Habit]

    @AppStorage("ballast.appearance") private var appearanceRawValue: String = AppearanceOption.system.rawValue
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

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

            Section("Your data") {
                Button {
                    exportURL = CSVExporter.writeToTemporaryFile(habits: habits)
                    showingShareSheet = exportURL != nil
                } label: {
                    Label("Export check-ins as CSV", systemImage: "square.and.arrow.up")
                }
                .disabled(habits.isEmpty)
            }

            Section("About Ballast") {
                Label("No accounts. No cloud. No subscription.", systemImage: "lock.shield")
                Label("Everything stays on this device.", systemImage: "iphone")
                Label("One honest number, not a streak to protect.", systemImage: "chart.pie")
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
