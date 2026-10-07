import SwiftUI

struct PhrasebookView: View {
    @State private var searchText = ""

    private var filtered: [Phrase] {
        guard !searchText.isEmpty else { return Phrasebook.phrases }
        return Phrasebook.phrases.filter {
            $0.hanzi.contains(searchText) ||
            $0.pinyinDisplay.localizedCaseInsensitiveContains(searchText) ||
            $0.english.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groups: [(category: PhraseCategory, phrases: [Phrase])] {
        PhraseCategory.allCases.compactMap { cat in
            let matches = filtered.filter { $0.category == cat }
            return matches.isEmpty ? nil : (cat, matches)
        }
    }

    var body: some View {
        ZStack {
            Y2KBackground()

            if filtered.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(groups, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Label(group.category.label, systemImage: group.category.icon)
                                    .font(.caption.weight(.bold))
                                    .tracking(1.0)
                                    .foregroundStyle(Theme.turquoise)
                                    .padding(.horizontal)

                                VStack(spacing: 8) {
                                    ForEach(group.phrases) { phrase in
                                        PhraseRow(phrase: phrase)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("Phrasebook")
        .searchable(text: $searchText, prompt: "Search phrases")
    }
}

private struct PhraseRow: View {
    let phrase: Phrase

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(phrase.hanzi)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(phrase.pinyinDisplay)
                    .font(.footnote)
                    .foregroundStyle(Theme.turquoise)
                Text(phrase.english)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button {
                SpeechHelper.shared.speak(phrase.hanzi)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.turquoise)
                    .padding(8)
                    .background(Theme.turquoise.opacity(0.14), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .y2kCard(cornerRadius: 16)
    }
}
