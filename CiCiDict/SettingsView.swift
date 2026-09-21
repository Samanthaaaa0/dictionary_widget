import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey) ?? ""
    @State private var saved = false
    @State private var showAdvanced = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                Form {
                    Section {
                        DisclosureGroup("AI-generated words (optional)", isExpanded: $showAdvanced) {
                            SecureField("Anthropic API key", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                            Text("Optional. Lets you add words that aren't in the dictionary without typing them in by hand. Stored on this device only — you don't need this to use the app.")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)

                            Button("Save key") {
                                KeychainHelper.save(key: KeychainHelper.anthropicAPIKeyKey, value: apiKey)
                                saved = true
                            }

                            if saved {
                                Text("Saved ✓").font(.caption).foregroundStyle(Theme.turquoise)
                            }
                        }
                    }
                    .listRowBackground(Theme.surface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}
