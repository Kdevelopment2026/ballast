import SwiftUI

/// A circular progress ring showing rolling consistency — never coloured red,
/// and always paired with the percentage as text so colour is never the only
/// signal.
struct ConsistencyRing: View {
    let consistency: Double // 0...1
    /// Copy for the window the number covers — see `ConsistencyCalculator.windowDescription`.
    var windowDescription: String = "over the last 30 days"
    var lineWidth: CGFloat = 6
    var size: CGFloat = 44

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var color: Color { BallastTheme.ringColor(for: consistency) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.02, min(1, consistency)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: consistency)

            Text("\(Int((consistency * 100).rounded()))%")
                .font(.system(size: size * 0.28, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int((consistency * 100).rounded())) percent consistent \(windowDescription)")
    }
}

#Preview {
    HStack(spacing: 20) {
        ConsistencyRing(consistency: 0.92)
        ConsistencyRing(consistency: 0.55)
        ConsistencyRing(consistency: 0.15)
    }
    .padding()
}
