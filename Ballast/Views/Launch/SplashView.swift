import SwiftUI

/// The moment after launch: picks up exactly where the static launch screen
/// leaves off (same teal, same ring), draws the ring round, shows the
/// wordmark, then hands over to the app. Under Reduce Motion the ring is
/// already full and the whole thing simply fades.
struct SplashView: View {
    /// Called once the splash has finished and can be removed.
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringProgress: CGFloat = 0
    @State private var wordmarkVisible = false

    private let ringSize: CGFloat = 220
    private let lineWidth: CGFloat = 22
    private let fill = Color(red: 0.99, green: 0.98, blue: 0.95)

    var body: some View {
        ZStack {
            Color("LaunchBackground").ignoresSafeArea()

            VStack(spacing: BallastTheme.Spacing.xl) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: lineWidth)
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(fill, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: ringSize, height: ringSize)

                VStack(spacing: BallastTheme.Spacing.xs) {
                    Text("Ballast")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(fill)
                    Text("The number dips, it doesn't break.")
                        .font(.callout)
                        .foregroundStyle(fill.opacity(0.8))
                }
                .opacity(wordmarkVisible ? 1 : 0)
                .offset(y: wordmarkVisible || reduceMotion ? 0 : 8)
            }
            // Keep the ring where the launch screen drew it (screen centre)
            // by offsetting the wordmark's share of the stack height.
            .offset(y: 44)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ballast")
        .onAppear(perform: run)
    }

    private func run() {
        if reduceMotion {
            ringProgress = 0.82
            wordmarkVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: onFinished)
            return
        }
        withAnimation(.easeInOut(duration: 0.9)) { ringProgress = 0.82 }
        withAnimation(.easeOut(duration: 0.5).delay(0.45)) { wordmarkVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7, execute: onFinished)
    }
}

#Preview {
    SplashView(onFinished: {})
}
