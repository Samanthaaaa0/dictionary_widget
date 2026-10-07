import SwiftUI

struct RootTabView: View {
    @StateObject private var themeRefresh = ThemeRefreshTrigger.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "sparkles") }

            DictionaryView()
                .tabItem { Label("Dictionary", systemImage: "character.book.closed.fill") }

            MyVocabularyView()
                .tabItem { Label("My Words", systemImage: "star.fill") }

            SentencePracticeView()
                .tabItem { Label("Practice", systemImage: "text.bubble.fill") }

            ReviewView()
                .tabItem { Label("Review", systemImage: "brain.head.profile") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.turquoise)
        .preferredColorScheme(.dark)
        .id(themeRefresh.tick)
    }
}

#Preview {
    RootTabView()
}
