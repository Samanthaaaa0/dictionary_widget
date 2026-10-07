import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey) ?? ""
    @State private var saved = false
    @State private var showAdvanced = false
    @State private var selectedTheme: Y2KThemePreset = Y2KThemeStore.currentPreset

    private let columns = [GridItem(.adaptive(minimum: 84), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                Form {
                    Section("Theme") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Y2KThemePreset.allCases) { preset in
                                themeSwatch(preset)
                            }
                        }
                        .padding(.vertical, 6)

                        Text("Also changes your Home Screen widget's colors.")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.surface)

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

    private func themeSwatch(_ preset: Y2KThemePreset) -> some View {
        let (primary, secondary) = preset.previewPair
        let isSelected = selectedTheme == preset

        return Button {
            selectedTheme = preset
            Y2KThemeStore.currentPreset = preset
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            ThemeRefreshTrigger.shared.bump()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(preset.palette.background)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .fill(primary)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: 0.5, to: 1)
                        .fill(secondary)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                }
                .overlay(
                    Circle().stroke(isSelected ? Theme.textPrimary : Color.clear, lineWidth: 2)
                        .frame(width: 50, height: 50)
                )

                Text(preset.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
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
