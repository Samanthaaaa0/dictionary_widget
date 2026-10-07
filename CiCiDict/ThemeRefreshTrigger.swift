import SwiftUI

/// Bumping `tick` and applying `.id(tick)` to the root view is the simplest
/// reliable way to make a global color-theme swap show up immediately
/// everywhere — Theme's colors are plain static values, not something each
/// view observes individually, so SwiftUI has no other reason to re-read
/// them. This does reset navigation/scroll position in every tab, which is
/// an acceptable trade-off for a deliberate, rare action like picking a theme.
final class ThemeRefreshTrigger: ObservableObject {
    static let shared = ThemeRefreshTrigger()
    @Published var tick = 0
    private init() {}
    func bump() { tick += 1 }
}
