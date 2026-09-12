import SwiftUI
import SwiftData

@main
struct BallastApp: App {
    @AppStorage("ballast.appearance") private var appearanceRawValue: String = AppearanceOption.system.rawValue

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Habit.self, CheckIn.self, Reflection.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            #if DEBUG
            // `xcrun simctl launch booted com.kayode.ballast -ballast-seed-demo`
            // fills an empty store with demo habits for screen checks.
            if CommandLine.arguments.contains("-ballast-seed-demo") {
                MainActor.assumeIsolated {
                    let context = container.mainContext
                    if (try? context.fetchCount(FetchDescriptor<Habit>())) == 0 {
                        DemoData.seed(into: context)
                    }
                }
            }
            #endif
            return container
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
