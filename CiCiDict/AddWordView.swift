import SwiftUI

struct AddWordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var input = ""
    @State private var preview: ChineseWord?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showManualEntry = false

    // Manual entry — the default path when a word isn't in the dictionary
    // and you haven't set up an AI key. No AI knowledge required.
    @State private var manualPinyin = ""
    @State private var manualEnglish = ""

    // Optional example sentence, added by hand.
    @State private var exampleHanzi = ""
    @State private var examplePinyin = ""
    @State private var exampleEnglish = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Chinese word") {
                    TextField("e.g. 加油", text: $input)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if let preview {
                    Section("Preview") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(preview.hanzi).font(.system(size: 34, weight: .bold, design: .rounded))
                            Text(preview.pinyinDisplay).foregroundStyle(Theme.turquoise)
                            Text(preview.englishShort).foregroundStyle(.secondary)
                            Label(sourceLabel(preview.source), systemImage: sourceIcon(preview.source))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Section("Example (optional)") {
                        TextField("Example sentence in hanzi", text: $exampleHanzi)
                        TextField("Pinyin, e.g. wo3 men2 jia1 you2", text: $examplePinyin)
                            .textInputAutocapitalization(.never)
                        TextField("English translation", text: $exampleEnglish)
                    }
                }

                if showManualEntry {
                    Section("Not in the dictionary — enter it yourself") {
                        TextField("Pinyin, e.g. jia1 you2", text: $manualPinyin)
                            .textInputAutocapitalization(.never)
                        TextField("Short English meaning", text: $manualEnglish)
                        Button("Use this") {
                            preview = ChineseWord(
                                hanzi: input.trimmingCharacters(in: .whitespacesAndNewlines),
                                pinyinNumbered: manualPinyin,
                                englishShort: manualEnglish,
                                source: .manual
                            )
                            errorMessage = nil
                        }
                        .disabled(manualPinyin.isEmpty || manualEnglish.isEmpty)
                    }
                }

                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red).font(.footnote) }
                }

                Section {
                    Button {
                        Task { await lookup() }
                    } label: {
                        if isGenerating { ProgressView() } else { Text("Look up") }
                    }
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isGenerating)

                    if preview != nil {
                        Button("Save") { save() }.fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Add word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func lookup() async {
        errorMessage = nil
        preview = nil
        showManualEntry = false
        isGenerating = true
        defer { isGenerating = false }

        let word = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Free, offline dictionary.
        if let found = DictionaryLookup.shared.lookup(word) {
            preview = found
            return
        }

        // 2. No API key set up? Just offer manual entry — no AI needed.
        guard let key = KeychainHelper.load(key: KeychainHelper.anthropicAPIKeyKey), !key.isEmpty else {
            errorMessage = "Not in the dictionary yet."
            showManualEntry = true
            return
        }

        // 3. Optional AI fallback, only if you've added a key in Settings.
        do {
            preview = try await AIWordGenerator.generate(for: word)
        } catch {
            errorMessage = "Couldn't generate this word — you can enter it manually instead."
            showManualEntry = true
        }
    }

    private func save() {
        guard var preview else { return }
        if !exampleHanzi.trimmingCharacters(in: .whitespaces).isEmpty {
            preview.exampleHanzi = exampleHanzi
            preview.examplePinyinNumbered = examplePinyin
            preview.exampleEnglish = exampleEnglish
        }
        WordStore.add(preview)
        dismiss()
    }

    private func sourceLabel(_ source: WordSource) -> String {
        switch source {
        case .ai: return "Generated by AI"
        case .manual: return "Entered manually"
        case .dictionary: return "From dictionary"
        }
    }

    private func sourceIcon(_ source: WordSource) -> String {
        switch source {
        case .ai: return "sparkles"
        case .manual: return "pencil"
        case .dictionary: return "book"
        }
    }
}
