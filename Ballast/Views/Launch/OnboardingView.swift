import SwiftUI

/// Three short pages on first run only. Says what the number is, what the
/// app doesn't do, and ends on the one action that matters. Skippable from
/// the first page.
struct OnboardingView: View {
    /// `addHabit` is true when the user chose "Add your first habit".
    let onFinished: (_ addHabit: Bool) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var demoConsistency: Double = 1.0

    private let lastPage = 2

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { onFinished(false) }
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: BallastTheme.minimumTapTarget, minHeight: BallastTheme.minimumTapTarget)
                    .opacity(page == lastPage ? 0 : 1)
                    .accessibilityHidden(page == lastPage)
            }
            .padding(.horizontal)

            TabView(selection: $page) {
                numberPage.tag(0)
                privatePage.tag(1)
                startPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: advance) {
                Text(page == lastPage ? "Add your first habit" : "Continue")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: BallastTheme.minimumTapTarget + 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(BallastTheme.ringColor(for: 1))
            .padding(.horizontal, BallastTheme.Spacing.lg)
            .padding(.bottom, BallastTheme.Spacing.sm)

            Button("Not now, just look around") { onFinished(false) }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minHeight: BallastTheme.minimumTapTarget)
                .opacity(page == lastPage ? 1 : 0)
                .accessibilityHidden(page != lastPage)
                .padding(.bottom, BallastTheme.Spacing.sm)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear(perform: startDemo)
    }

    // MARK: Pages

    private var numberPage: some View {
        OnboardingPage(
            title: "One honest number",
            message: "Each habit shows how consistently you've shown up over the last 30 days. Miss a day and it dips a little. It never resets to zero."
        ) {
            ConsistencyRing(consistency: demoConsistency, lineWidth: 12, size: 150)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: demoConsistency)
                .accessibilityHidden(true)
        }
    }

    private var privatePage: some View {
        OnboardingPage(
            title: "Nothing leaves your phone",
            message: "No account, no cloud, no subscription. Ballast works in airplane mode forever, and you can export everything as a plain CSV whenever you like."
        ) {
            Image(systemName: "lock.shield")
                .font(.system(size: 96, weight: .light))
                .foregroundStyle(BallastTheme.ringColor(for: 1))
                .accessibilityHidden(true)
        }
    }

    private var startPage: some View {
        OnboardingPage(
            title: "Show up most days",
            message: "Not every day. Add something small you want to show up for, check in when you do, and let the number tell the truth."
        ) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 96, weight: .light))
                .foregroundStyle(BallastTheme.ringColor(for: 1))
                .accessibilityHidden(true)
        }
    }

    // MARK: Behaviour

    private func advance() {
        if page == lastPage {
            onFinished(true)
        } else if reduceMotion {
            page += 1
        } else {
            withAnimation { page += 1 }
        }
    }

    /// Dips the demo ring from 100% to 87% so the first page shows the idea
    /// rather than describing it. Skipped under Reduce Motion.
    private func startDemo() {
        guard !reduceMotion else { demoConsistency = 0.87; return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { demoConsistency = 0.87 }
    }
}

/// One onboarding page: hero, title, message — all centred, Dynamic Type friendly.
private struct OnboardingPage<Hero: View>: View {
    let title: String
    let message: String
    @ViewBuilder let hero: () -> Hero

    var body: some View {
        VStack(spacing: BallastTheme.Spacing.lg) {
            Spacer(minLength: 0)
            hero()
                .frame(height: 170)
            VStack(spacing: BallastTheme.Spacing.sm) {
                Text(title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, BallastTheme.Spacing.xl)
            Spacer(minLength: 0)
        }
        .padding(.bottom, BallastTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView(onFinished: { _ in })
}
