import SwiftUI

struct MyVocabularyView: View {
    @State private var words: [ChineseWord] = WordStore.loadAll()
    @State private var searchText = ""
    @State private var showingAdd = false

    var filtered: [ChineseWord] {
        guard !searchText.isEmpty else { return words }
        return words.filter {
            $0.hanzi.contains(searchText) ||
            $0.pinyinDisplay.localizedCaseInsensitiveContains(searchText) ||
            $0.englishShort.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if words.isEmpty {
                    ContentUnavailableView(
                        "No words yet",
                        systemImage: "star",
                        description: Text("Add words from the Dictionary tab, or tap + here ✦")
                    )
                } else {
                    List {
                        ForEach(filtered) { word in
                            NavigationLink(value: word) {
                                WordRow(word: word)
                            }
                            .listRowBackground(Theme.surface)
                        }
                        .onDelete { indexSet in
                            for i in indexSet { WordStore.delete(filtered[i]) }
                            words = WordStore.loadAll()
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Words")
            .searchable(text: $searchText, prompt: "Search your words")
            .navigationDestination(for: ChineseWord.self) { word in
                WordDetailView(word: word)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .tint(Theme.turquoise)
                }
            }
            .sheet(isPresented: $showingAdd, onDismiss: { words = WordStore.loadAll() }) {
                AddWordView()
            }
            .onAppear { words = WordStore.loadAll() }
        }
    }
}

private struct WordRow: View {
    let word: ChineseWord
    var body: some View {
        HStack(spacing: 12) {
            Text(word.hanzi)
                .font(.system(size: 28, weight: .bold, design: .rounded))
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
            Spacer()
            if word.isPinnedToWidget {
                Image(systemName: "pin.fill").foregroundStyle(Theme.turquoise).font(.caption)
            }
            if word.isFavorite {
                Image(systemName: "heart.fill").foregroundStyle(.pink).font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
