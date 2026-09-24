import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey) ?? ""
    @State private var saved = false
    @State private var showAdvanced = false

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                Form {
                    Section("Dictionary") {
                        dictionaryStatusRow
                    }
                    .listRowBackground(Theme.surface)

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

    @ViewBuilder
    private var dictionaryStatusRow: some View {
        switch DictionaryLookup.shared.loadStatus {
        case .loaded(let count) where count > 200:
            Label("Full dictionary loaded (\(count) entries)", systemImage: "checkmark.seal.fill")
                .foregroundStyle(Theme.lime)
            Text("Dictionary data © CC-CEDICT contributors, CC BY-SA 4.0.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        case .loaded(let count):
            // Loaded *something*, but a suspiciously small number — the
            // bundled file exists but likely isn't the real CC-CEDICT text.
            Label("Only \(count) entries loaded — check the bundled file", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.amber)
        case .fileNotFoundInBundle:
            Label("Using built-in ~56 words only", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.amber)
            Text("cedict_ts.u8 wasn't found in the app bundle. Double-check its name (no extra .txt) and that Target Membership is checked for CiCiDict under Build Phases → Copy Bundle Resources.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        case .notLoadedYet:
            Label("Checking dictionary…", systemImage: "hourglass")
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
