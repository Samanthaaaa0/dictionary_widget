import SwiftUI

struct DictionaryView: View {
    @State private var query = ""
    @State private var results: [ChineseWord] = []
    @State private var savedHanzi: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    ContentUnavailableView(
                        "Search the dictionary",
                        systemImage: "sparkle.magnifyingglass",
                        description: Text("Type a hanzi, pinyin, or English word ✦")
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, word in
                                NavigationLink(value: word) {
                                    DictionaryCard(
                                        word: word,
                                        isSaved: savedHanzi.contains(word.hanzi),
                                        onToggleSave: { toggleSave(word) },
                                        onSpeak: { SpeechHelper.shared.speak(word.hanzi) }
                                    )
                                }
                                .buttonStyle(.plain)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity
                                ))
                                .animation(.spring(response: 0.35, dampingFraction: 0.8).delay(Double(index) * 0.02), value: results)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
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
            .onAppear(perform: refreshSavedSet)
        }
    }

    private func search() async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { results = []; return }
        try? await Task.sleep(nanoseconds: 250_000_000) // debounce while typing
        guard !Task.isCancelled else { return }
        results = DictionaryLookup.shared.search(q)
    }

    private func refreshSavedSet() {
        savedHanzi = Set(WordStore.loadAll().map(\.hanzi))
    }

    private func toggleSave(_ word: ChineseWord) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        if savedHanzi.contains(word.hanzi) {
            if let existing = WordStore.loadAll().first(where: { $0.hanzi == word.hanzi }) {
                WordStore.delete(existing)
            }
            savedHanzi.remove(word.hanzi)
        } else {
            WordStore.add(word)
            savedHanzi.insert(word.hanzi)
        }
    }
}

private struct DictionaryCard: View {
    let word: ChineseWord
    let isSaved: Bool
    let onToggleSave: () -> Void
    let onSpeak: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(word.hanzi)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .frame(minWidth: 56, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(word.pinyinDisplay)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.turquoise)
                Text(word.englishShort)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Button(action: onSpeak) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.turquoise)
                    .padding(8)
                    .background(Theme.turquoise.opacity(0.14), in: Circle())
            }
            .buttonStyle(.plain)

            Button(action: onToggleSave) {
                Image(systemName: isSaved ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.amber)
                    .padding(8)
                    .background(Theme.amber.opacity(isSaved ? 0.22 : 0.1), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .y2kCard(cornerRadius: 18)
    }
}
