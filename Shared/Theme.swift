import SwiftUI

/// Y2K-inspired theme, now customizable — all values forward to whichever
/// Y2KThemePreset is currently selected (see Y2KThemeStore), so this file
/// is the only thing that changed to make theming possible. Every other
/// view still just calls Theme.turquoise, Theme.background, etc. as before.
enum Theme {
    static var background: Color { Y2KThemeStore.currentPalette.background }
    static var surface: Color { Y2KThemeStore.currentPalette.surface }
    static var surfaceBorder: Color { Y2KThemeStore.currentPalette.surfaceBorder }

    static var turquoise: Color { Y2KThemeStore.currentPalette.turquoise }
    static var turquoiseDim: Color { turquoise.opacity(0.55) }

    static var magenta: Color { Y2KThemeStore.currentPalette.magenta }
    static var purple: Color { Y2KThemeStore.currentPalette.purple }
    static var lime: Color { Y2KThemeStore.currentPalette.lime }
    static var amber: Color { Y2KThemeStore.currentPalette.amber }

    static var textPrimary: Color { Y2KThemeStore.currentPalette.textPrimary }
    static var textSecondary: Color { Y2KThemeStore.currentPalette.textSecondary }

    static var glow: Color { turquoise.opacity(0.45) }
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
