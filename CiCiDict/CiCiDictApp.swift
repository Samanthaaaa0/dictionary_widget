import SwiftUI

@main
struct CiCiDictApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    await DictionaryLookup.shared.loadIfNeeded()
                }
        }
    }
}
