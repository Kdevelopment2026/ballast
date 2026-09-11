import SwiftUI

/// Ballast's visual language: calm, steady, never punitive. There is no red
/// "you failed" state anywhere — the lowest consistency band is a muted
/// slate, not an alarm colour, on purpose.
enum BallastTheme {

    /// Consistency bands — deliberately calm across the whole range.
    static func ringColor(for consistency: Double) -> Color {
        switch consistency {
        case 0.75...:
            return Color(red: 0.14, green: 0.47, blue: 0.44) // steady teal
        case 0.4..<0.75:
            return Color(red: 0.22, green: 0.40, blue: 0.55) // slate blue
        default:
            return Color(red: 0.47, green: 0.50, blue: 0.55) // muted grey — never red
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
