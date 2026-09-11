import SwiftUI
import SwiftData

@main
struct BallastApp: App {
    @AppStorage("ballast.appearance") private var appearanceRawValue: String = AppearanceOption.system.rawValue

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Habit.self, CheckIn.self, Reflection.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create Ballast's on-device data store: \(error)")
        }
    }()

    private var appearance: AppearanceOption {
        AppearanceOption(rawValue: appearanceRawValue) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            TodayView()
                .preferredColorScheme(appearance.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
