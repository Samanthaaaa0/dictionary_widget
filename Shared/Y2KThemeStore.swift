import Foundation
import WidgetKit

/// Reads/writes the selected theme through the same App Group UserDefaults
/// as WordStore, so the widget (a separate process) sees the same choice.
/// Always reads fresh from UserDefaults rather than caching in memory —
/// the widget extension doesn't stay running, so each timeline refresh needs
/// to see the latest value, and the cost of reading UserDefaults is tiny.
enum Y2KThemeStore {
    private static let key = "cicidict.selectedTheme"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.id) ?? .standard
    }

    static var currentPreset: Y2KThemePreset {
        get { Y2KThemePreset(rawValue: defaults.string(forKey: key) ?? "") ?? .cyberTurquoise }
        set {
            defaults.set(newValue.rawValue, forKey: key)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var currentPalette: Y2KColorPalette {
        currentPreset.palette
    }
}
