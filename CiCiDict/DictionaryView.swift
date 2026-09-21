import SwiftUI

struct DictionaryView: View {
    @State private var query = ""
    @State private var results: [ChineseWord] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    ContentUnavailableView(
                        "Search the dictionary",
                        systemImage: "magnifyingglass",
                        description: Text("Type a hanzi, pinyin, or English word ✦")
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    List {
                        ForEach(results) { word in
                            NavigationLink(value: word) {
                                DictionaryRow(word: word)
                            }
                            .listRowBackground(Theme.surface)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Dictionary")
            .searchable(text: $query, prompt: "Search hanzi, pinyin, or English")
            .navigationDestination(for: ChineseWord.self) { word in
                WordDetailView(word: word)
            }
            .task(id: query) {
                await search()
            }
        }
    }

    private func search() async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { results = []; return }
        try? await Task.sleep(nanoseconds: 250_000_000) // debounce while typing
        guard !Task.isCancelled else { return }
        results = DictionaryLookup.shared.search(q)
    }
}

private struct DictionaryRow: View {
    let word: ChineseWord
    var body: some View {
        HStack(spacing: 12) {
            Text(word.hanzi)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text(word.pinyinDisplay)
                    .font(.subheadline)
                    .foregroundStyle(Theme.turquoise)
                Text(word.englishShort)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
