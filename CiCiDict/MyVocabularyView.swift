import SwiftUI

struct MyVocabularyView: View {
    @State private var words: [ChineseWord] = WordStore.loadAll()
    @State private var searchText = ""
    @State private var showingAdd = false
    @State private var selectedCategory: WordCategory?

    private let orderedCategories: [WordCategory] =
        WordCategory.allCases.filter { $0 != .uncategorized } + [.uncategorized]

    private var searchFiltered: [ChineseWord] {
        guard !searchText.isEmpty else { return words }
        return words.filter {
            $0.hanzi.contains(searchText) ||
            $0.pinyinDisplay.localizedCaseInsensitiveContains(searchText) ||
            $0.englishShort.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filtered: [ChineseWord] {
        guard let selectedCategory else { return searchFiltered }
        return searchFiltered.filter { $0.category == selectedCategory }
    }

    /// Only categories that actually have a word in them show up as chips —
    /// no point offering 15 empty filters on day one.
    private var categoriesPresent: [WordCategory] {
        orderedCategories.filter { cat in words.contains { $0.category == cat } }
    }

    private var groups: [(category: WordCategory, words: [ChineseWord])] {
        orderedCategories.compactMap { cat in
            let matches = filtered.filter { $0.category == cat }
            return matches.isEmpty ? nil : (cat, matches)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackground()

                if words.isEmpty {
                    ContentUnavailableView(
                        "No words yet",
                        systemImage: "star",
                        description: Text("Add words from the Dictionary tab, or tap + here ✦")
                    )
                } else {
                    VStack(spacing: 0) {
                        if categoriesPresent.count > 1 {
                            categoryChips
                                .padding(.vertical, 10)
                        }

                        if filtered.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        } else {
                            List {
                                ForEach(groups, id: \.category) { group in
                                    Section {
                                        ForEach(group.words) { word in
                                            NavigationLink(value: word) {
                                                WordCard(word: word)
                                            }
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        }
                                        .onDelete { indexSet in
                                            for i in indexSet { WordStore.delete(group.words[i]) }
                                            words = WordStore.loadAll()
                                        }
                                    } header: {
                                        CategoryHeader(category: group.category, count: group.words.count)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
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

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: "All", icon: "square.grid.2x2.fill", color: Theme.textPrimary, isSelected: selectedCategory == nil) {
                    withAnimation(.easeInOut(duration: 0.15)) { selectedCategory = nil }
                }
                ForEach(categoriesPresent) { cat in
                    chip(label: cat.label, icon: cat.icon, color: cat.color, isSelected: selectedCategory == cat) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func chip(label: String, icon: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? Theme.background : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? color : color.opacity(0.14), in: Capsule())
                .overlay(Capsule().stroke(color, lineWidth: isSelected ? 0 : 1))
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryHeader: View {
    let category: WordCategory
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.caption)
            Text(category.label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.1)
            Text("· \(count)")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .foregroundStyle(category.color)
        .padding(.vertical, 2)
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 4, trailing: 16))
    }
}

private struct WordCard: View {
    let word: ChineseWord

    private var masteryColor: Color {
        switch word.masteryLabel {
        case "Mastered": return Theme.lime
        case "Familiar": return Theme.turquoise
        case "Learning": return Theme.amber
        default: return Theme.purple
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(masteryColor)
                .frame(width: 3)
                .padding(.vertical, 4)

            Text(word.hanzi)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .frame(minWidth: 48, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(word.pinyinDisplay)
                        .font(.subheadline)
                        .foregroundStyle(Theme.turquoise)
                    if let level = word.hskLevel {
                        Text("HSK\(level)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Theme.background)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Theme.lime, in: Capsule())
                    }
                }
                Text(word.englishShort)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(spacing: 4) {
                if word.isPinnedToWidget {
                    Image(systemName: "pin.fill").foregroundStyle(Theme.turquoise).font(.caption2)
                }
                if word.isFavorite {
                    Image(systemName: "heart.fill").foregroundStyle(Theme.magenta).font(.caption2)
                }
            }
        }
        .padding(10)
        .y2kCard(cornerRadius: 16)
    }
}
