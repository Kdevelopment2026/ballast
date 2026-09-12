import SwiftUI

/// Sequences launch: splash over everything, onboarding on first run, then
/// Today. Onboarding state is the only thing persisted here.
struct RootView: View {
    @AppStorage("ballast.hasOnboarded") private var hasOnboarded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showingSplash = true
    @State private var addHabitRequested = false

    var body: some View {
        ZStack {
            if hasOnboarded {
                TodayView(addHabitRequested: $addHabitRequested)
                    .transition(.opacity)
            } else {
                OnboardingView { addHabit in
                    addHabitRequested = addHabit
                    if reduceMotion {
                        hasOnboarded = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.35)) { hasOnboarded = true }
                    }
                }
                .transition(.opacity)
            }

            if showingSplash {
                SplashView {
                    if reduceMotion {
                        showingSplash = false
                    } else {
                        withAnimation(.easeOut(duration: 0.45)) { showingSplash = false }
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear(perform: applyLaunchArguments)
    }

    private func applyLaunchArguments() {
        #if DEBUG
        let arguments = CommandLine.arguments
        // Screenshot and preview runs jump straight past the intro…
        if arguments.contains("-ballast-seed-demo") || arguments.contains("-ballast-open") {
            showingSplash = false
            hasOnboarded = true
        }
        // …unless the intro itself is what's being captured.
        if arguments.contains("-ballast-show-onboarding") {
            showingSplash = false
            hasOnboarded = false
        }
        if arguments.contains("-ballast-show-splash") {
            hasOnboarded = true
        }
        #endif
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Habit.self, CheckIn.self, Reflection.self], inMemory: true)
}
