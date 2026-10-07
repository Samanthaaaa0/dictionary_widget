import SwiftUI

/// The actual color values for one theme. Field names match Theme's existing
/// properties 1:1 — Theme just forwards to whichever palette is selected, so
/// nothing else in the app needs to change.
struct Y2KColorPalette {
    let background: Color
    let surface: Color
    let surfaceBorder: Color
    let turquoise: Color
    let magenta: Color
    let purple: Color
    let lime: Color
    let amber: Color
    let textPrimary: Color
    let textSecondary: Color
}

/// 10 preset Y2K palettes, each built around a contrasting color pair
/// (complementary or near-complementary hues) so they read as genuinely
/// different vibes rather than 10 shades of the same thing.
enum Y2KThemePreset: String, CaseIterable, Identifiable, Codable, Equatable {
    case cyberTurquoise
    case sunsetArcade
    case bubblegumPop
    case grapeSoda
    case neonMall
    case chromeDream
    case candyLab
    case retroSunset
    case holographic
    case tokyoNight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cyberTurquoise: return "Cyber Turquoise"
        case .sunsetArcade: return "Sunset Arcade"
        case .bubblegumPop: return "Bubblegum Pop"
        case .grapeSoda: return "Grape Soda"
        case .neonMall: return "Neon Mall"
        case .chromeDream: return "Chrome Dream"
        case .candyLab: return "Candy Lab"
        case .retroSunset: return "Retro Sunset"
        case .holographic: return "Holographic"
        case .tokyoNight: return "Tokyo Night"
        }
    }

    /// The two colors shown on the little swatch preview in Settings —
    /// the contrasting pair the theme is built around.
    var previewPair: (Color, Color) { (palette.turquoise, palette.magenta) }

    var palette: Y2KColorPalette {
        switch self {
        case .cyberTurquoise:
            return Y2KColorPalette(
                background: Color(red: 0.04, green: 0.04, blue: 0.07),
                surface: Color(red: 0.09, green: 0.10, blue: 0.14),
                surfaceBorder: Color(red: 0.20, green: 0.22, blue: 0.26),
                turquoise: Color(red: 0.20, green: 0.93, blue: 0.86),
                magenta: Color(red: 0.98, green: 0.25, blue: 0.72),
                purple: Color(red: 0.55, green: 0.36, blue: 0.95),
                lime: Color(red: 0.68, green: 0.98, blue: 0.35),
                amber: Color(red: 1.0, green: 0.78, blue: 0.30),
                textPrimary: Color(white: 0.96),
                textSecondary: Color(white: 0.62)
            )
        case .sunsetArcade: // blue + orange
            return Y2KColorPalette(
                background: Color(red: 0.03, green: 0.05, blue: 0.11),
                surface: Color(red: 0.07, green: 0.10, blue: 0.18),
                surfaceBorder: Color(red: 0.18, green: 0.24, blue: 0.34),
                turquoise: Color(red: 1.0, green: 0.55, blue: 0.15),   // orange (primary)
                magenta: Color(red: 0.30, green: 0.60, blue: 1.0),    // electric blue
                purple: Color(red: 0.55, green: 0.40, blue: 0.95),
                lime: Color(red: 0.70, green: 0.95, blue: 0.40),
                amber: Color(red: 1.0, green: 0.82, blue: 0.25),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .bubblegumPop: // pink + turquoise
            return Y2KColorPalette(
                background: Color(red: 0.08, green: 0.03, blue: 0.08),
                surface: Color(red: 0.14, green: 0.07, blue: 0.14),
                surfaceBorder: Color(red: 0.30, green: 0.18, blue: 0.28),
                turquoise: Color(red: 1.0, green: 0.35, blue: 0.70),  // pink (primary)
                magenta: Color(red: 0.25, green: 0.92, blue: 0.85),  // turquoise
                purple: Color(red: 0.75, green: 0.45, blue: 0.95),
                lime: Color(red: 0.55, green: 0.98, blue: 0.75),
                amber: Color(red: 1.0, green: 0.80, blue: 0.35),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .grapeSoda: // purple + lime
            return Y2KColorPalette(
                background: Color(red: 0.05, green: 0.03, blue: 0.09),
                surface: Color(red: 0.11, green: 0.08, blue: 0.17),
                surfaceBorder: Color(red: 0.26, green: 0.20, blue: 0.36),
                turquoise: Color(red: 0.62, green: 0.40, blue: 0.98), // violet (primary)
                magenta: Color(red: 0.75, green: 0.98, blue: 0.30),  // lime
                purple: Color(red: 0.95, green: 0.35, blue: 0.75),
                lime: Color(red: 0.45, green: 0.95, blue: 0.65),
                amber: Color(red: 1.0, green: 0.78, blue: 0.30),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .neonMall: // hot magenta + cyan
            return Y2KColorPalette(
                background: Color(red: 0.05, green: 0.02, blue: 0.06),
                surface: Color(red: 0.12, green: 0.05, blue: 0.13),
                surfaceBorder: Color(red: 0.32, green: 0.15, blue: 0.30),
                turquoise: Color(red: 1.0, green: 0.15, blue: 0.65), // hot magenta (primary)
                magenta: Color(red: 0.20, green: 0.95, blue: 0.98), // cyan
                purple: Color(red: 0.65, green: 0.35, blue: 0.98),
                lime: Color(red: 0.70, green: 0.98, blue: 0.35),
                amber: Color(red: 1.0, green: 0.75, blue: 0.25),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .chromeDream: // icy blue + hot pink
            return Y2KColorPalette(
                background: Color(red: 0.05, green: 0.07, blue: 0.10),
                surface: Color(red: 0.10, green: 0.13, blue: 0.17),
                surfaceBorder: Color(red: 0.24, green: 0.30, blue: 0.36),
                turquoise: Color(red: 0.55, green: 0.80, blue: 1.0), // icy blue (primary)
                magenta: Color(red: 1.0, green: 0.30, blue: 0.65),  // hot pink
                purple: Color(red: 0.60, green: 0.50, blue: 0.95),
                lime: Color(red: 0.50, green: 0.95, blue: 0.80),
                amber: Color(red: 1.0, green: 0.80, blue: 0.35),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .candyLab: // lime + purple
            return Y2KColorPalette(
                background: Color(red: 0.03, green: 0.07, blue: 0.05),
                surface: Color(red: 0.08, green: 0.14, blue: 0.10),
                surfaceBorder: Color(red: 0.20, green: 0.34, blue: 0.24),
                turquoise: Color(red: 0.65, green: 0.98, blue: 0.30), // lime (primary)
                magenta: Color(red: 0.68, green: 0.40, blue: 0.98),  // purple
                purple: Color(red: 0.95, green: 0.35, blue: 0.75),
                lime: Color(red: 0.30, green: 0.90, blue: 0.85),
                amber: Color(red: 1.0, green: 0.80, blue: 0.30),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .retroSunset: // coral + teal
            return Y2KColorPalette(
                background: Color(red: 0.08, green: 0.04, blue: 0.04),
                surface: Color(red: 0.16, green: 0.09, blue: 0.08),
                surfaceBorder: Color(red: 0.36, green: 0.22, blue: 0.18),
                turquoise: Color(red: 1.0, green: 0.45, blue: 0.35), // coral (primary)
                magenta: Color(red: 0.25, green: 0.85, blue: 0.78), // teal
                purple: Color(red: 1.0, green: 0.80, blue: 0.30),
                lime: Color(red: 0.50, green: 0.95, blue: 0.70),
                amber: Color(red: 1.0, green: 0.75, blue: 0.25),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .holographic: // violet + pink
            return Y2KColorPalette(
                background: Color(red: 0.06, green: 0.04, blue: 0.09),
                surface: Color(red: 0.13, green: 0.09, blue: 0.18),
                surfaceBorder: Color(red: 0.30, green: 0.22, blue: 0.38),
                turquoise: Color(red: 0.70, green: 0.45, blue: 1.0), // violet (primary)
                magenta: Color(red: 1.0, green: 0.45, blue: 0.80),  // pink
                purple: Color(red: 0.45, green: 0.90, blue: 0.95),
                lime: Color(red: 0.55, green: 0.95, blue: 0.80),
                amber: Color(red: 1.0, green: 0.82, blue: 0.35),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        case .tokyoNight: // gold + indigo
            return Y2KColorPalette(
                background: Color(red: 0.04, green: 0.04, blue: 0.09),
                surface: Color(red: 0.09, green: 0.09, blue: 0.17),
                surfaceBorder: Color(red: 0.22, green: 0.22, blue: 0.36),
                turquoise: Color(red: 1.0, green: 0.78, blue: 0.30),  // gold (primary)
                magenta: Color(red: 0.45, green: 0.45, blue: 0.98), // indigo
                purple: Color(red: 0.95, green: 0.35, blue: 0.70),
                lime: Color(red: 0.65, green: 0.95, blue: 0.40),
                amber: Color(red: 1.0, green: 0.55, blue: 0.40),
                textPrimary: Color(white: 0.97),
                textSecondary: Color(white: 0.64)
            )
        }
    }
}
