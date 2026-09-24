import SwiftUI

/// Minimal Y2K-inspired theme — near-black background, a single turquoise
/// accent used sparingly, soft glow on key text. Not loud, not neon-everywhere.
enum Theme {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.07)   // near-black w/ a hint of blue
    static let surface = Color(red: 0.09, green: 0.10, blue: 0.14)      // card background
    static let surfaceBorder = Color(red: 0.20, green: 0.22, blue: 0.26)

    static let turquoise = Color(red: 0.20, green: 0.93, blue: 0.86)    // primary accent
    static let turquoiseDim = turquoise.opacity(0.55)

    // Secondary Y2K cyber accents — used purposefully, not everywhere:
    // magenta for your own input/creations, lime for "correct", amber for streaks/highlights.
    static let magenta = Color(red: 0.98, green: 0.25, blue: 0.72)
    static let purple = Color(red: 0.55, green: 0.36, blue: 0.95)
    static let lime = Color(red: 0.68, green: 0.98, blue: 0.35)
    static let amber = Color(red: 1.0, green: 0.78, blue: 0.30)

    static let textPrimary = Color(white: 0.96)
    static let textSecondary = Color(white: 0.62)

    static let glow = turquoise.opacity(0.45)
}

extension View {
    /// The app's signature surface: rounded card, thin border, dark fill.
    func y2kCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.surfaceBorder, lineWidth: 1)
            )
    }

    /// Soft turquoise glow, used sparingly on hero text.
    func y2kGlowText() -> some View {
        self.shadow(color: Theme.glow, radius: 8)
    }
}

/// Pill button — filled turquoise for primary actions, outlined for secondary.
struct Y2KButtonStyle: ButtonStyle {
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded).weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .foregroundStyle(filled ? Theme.background : Theme.turquoise)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(filled ? Theme.turquoise : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.turquoise, lineWidth: filled ? 0 : 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
