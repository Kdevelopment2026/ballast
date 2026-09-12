import SwiftUI
import UIKit

/// Ballast's visual language: calm, steady, never punitive. There is no red
/// "you failed" state anywhere — the lowest consistency band is a muted
/// grey, not an alarm colour, on purpose.
enum BallastTheme {

    /// Consistency bands — deliberately calm across the whole range.
    ///
    /// Each band is a light/dark pair so the percentage text drawn in the band
    /// colour clears WCAG AA (≥4.5:1) on both the light and dark system
    /// backgrounds. Colour is never the only signal — every ring also shows
    /// the percentage as text.
    static func ringColor(for consistency: Double) -> Color {
        switch consistency {
        case 0.75...:
            return adaptive(light: (0.11, 0.42, 0.39), dark: (0.40, 0.78, 0.73)) // steady teal
        case 0.4..<0.75:
            return adaptive(light: (0.20, 0.37, 0.52), dark: (0.55, 0.72, 0.90)) // slate blue
        default:
            return adaptive(light: (0.38, 0.41, 0.46), dark: (0.68, 0.71, 0.76)) // muted grey — never red
        }
    }

    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let card: CGFloat = 18
    }

    /// Minimum tap target size (Apple HIG / WCAG 2.5.5).
    static let minimumTapTarget: CGFloat = 44

    private typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat)

    private static func adaptive(light: RGB, dark: RGB) -> Color {
        Color(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
        })
    }
}

/// Shared appearance setting, read by both the app root (to apply it) and
/// Settings (to let the user change it).
enum AppearanceOption: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
