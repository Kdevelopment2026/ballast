import Foundation

/// The single gate for any future paid feature. Ballast ships v1 as a plain
/// one-time purchase with nothing gated — but the seam is here so a Pro tier
/// (e.g. unlimited habits, extra themes) can be added later without touching
/// a single view. Never inspect StoreKit transactions directly in a view —
/// always go through this object.
@Observable
final class ProStatus {
    static let shared = ProStatus()

    /// v1: always true. No paywall, no feature gating, no StoreKit calls yet.
    var isUnlocked: Bool = true

    private init() {}
}
