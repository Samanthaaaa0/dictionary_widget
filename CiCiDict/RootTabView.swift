import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DictionaryView()
                .tabItem { Label("Dictionary", systemImage: "character.book.closed.fill") }

            MyVocabularyView()
                .tabItem { Label("My Words", systemImage: "star.fill") }

            ReviewView()
                .tabItem { Label("Review", systemImage: "brain.head.profile") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.turquoise)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootTabView()
}
